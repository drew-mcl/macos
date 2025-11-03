#!/usr/bin/env bash
set -Eeuo pipefail

log() { printf '[%(%Y-%m-%dT%H:%M:%S%z)T] %s\n' -1 "$*"; }
die() { log "ERROR: $*"; exit 1; }

# ---- static paths/values injected by Ansible
CONFIG_DIR="{{ config_dir }}"            # legacy fallback only
CURRENT_LINK="{{ current_dir }}"         # -> releases/<ver>
INSTANCE_ID="{{ _neuron_instance_id }}"
JAVA_FALLBACK="{{ _java_bin_fallback }}"
FAIL_ON_HOOK="{{ _fail_on_hook_error }}"
RUN_DIR="{{ run_dir }}"
PID_FILE="{{ _pid_file }}"
STDOUT="{{ _stdout }}"
STDERR="{{ _stderr }}"
DEFAULT_FG="{{ _default_fg }}"

# ---- helpers
realpath_portable() {
  if command -v readlink >/dev/null 2>&1; then readlink -f -- "$1" 2>/dev/null && return 0; fi
  if command -v realpath >/dev/null 2>&1; then realpath "$1" && return 0; fi
  (cd "$(dirname "$1")" && dir=$(pwd -P) && echo "${dir}/$(basename "$1")")
}
require_path() {
  local p="$1" msg="$2"; [[ -e "$p" ]] || die "$msg ($p)"
}

# ---- resolve active release
require_path "$CURRENT_LINK" "current symlink missing; cannot resolve active release"
CODE_DIR="$(realpath_portable "${CURRENT_LINK}")" || die "failed to resolve current symlink"
require_path "$CODE_DIR" "resolved current does not exist"
RELEASE_VER="$(basename -- "${CODE_DIR}")"

# per-release, per-instance generated config
CLS_VER_DIR="${CODE_DIR}/cls/${INSTANCE_ID}/latest"
# release-scoped overrides
OVR_ROOT="${CODE_DIR}/overrides"

# ensure run dir exists (restrictive perms)
umask 027
mkdir -p "${RUN_DIR}"

# ---- environment assembly
load_env() {
  # non-exported (instance-local first), then release env.local overrides
  if [[ -f "${CLS_VER_DIR}/state.local.env" ]]; then
    # shellcheck disable=SC1090
    source "${CLS_VER_DIR}/state.local.env"; log "loaded cls state.local.env"
  fi
  if [[ -d "${OVR_ROOT}/env.local" ]]; then
    # shellcheck disable=SC1090
    while IFS= read -r -d '' f; do source "$f"; log "loaded override env.local: $(basename "$f")"; done < <(find "${OVR_ROOT}/env.local" -maxdepth 1 -type f -name '*.env' -print0 | sort -z)
  fi
  # exported (instance preferred; legacy fallback), then release env overrides
  if [[ -f "${CLS_VER_DIR}/state.env" ]]; then
    set -a; # shellcheck disable=SC1090
    source "${CLS_VER_DIR}/state.env"; set +a; log "loaded cls state.env (exported)"
  elif [[ -f "${CONFIG_DIR}/state.env" ]]; then
    set -a; # shellcheck disable=SC1090
    source "${CONFIG_DIR}/state.env"; set +a; log "loaded legacy config/state.env (exported)"
  else
    log "no state.env for release=${RELEASE_VER}"
  fi
  if [[ -d "${OVR_ROOT}/env" ]]; then
    set -a
    # shellcheck disable=SC1090
    while IFS= read -r -d '' f; do source "$f"; log "loaded override env: $(basename "$f")"; done < <(find "${OVR_ROOT}/env" -maxdepth 1 -type f -name '*.env' -print0 | sort -z)
    set +a
  fi
}

# ---- JVM args: baseline -> instance jvm.cls.args -> release fragments OR full replacement
build_jvm_args() {
  JVM_ARGS=()

  # 0) full replacement from release
  if [[ -f "${OVR_ROOT}/jvm/jvm.args" ]]; then
    while IFS= read -r l; do [[ -z "$l" || "$l" =~ ^[[:space:]]*# ]] && continue; JVM_ARGS+=("$l"); done < "${OVR_ROOT}/jvm/jvm.args"
    log "using overrides/jvm/jvm.args (replacement)"
    { umask 027; printf "%s\n" "${JVM_ARGS[@]}" > "${RUN_DIR}/jvm.args.effective" 2>/dev/null || true; } || true
    return
  fi

  # 1) baseline shipped in release
  if [[ -f "${CODE_DIR}/config/jvm.args" ]]; then
    while IFS= read -r l; do [[ -z "$l" || "$l" =~ ^[[:space:]]*# ]] && continue; JVM_ARGS+=("$l"); done < "${CODE_DIR}/config/jvm.args"
    log "loaded baseline jvm.args"
  fi

  # 2) instance inventory-derived for THIS release
  if [[ -f "${CLS_VER_DIR}/jvm.cls.args" ]]; then
    while IFS= read -r l; do [[ -z "$l" || "$l" =~ ^[[:space:]]*# ]] && continue; JVM_ARGS+=("$l"); done < "${CLS_VER_DIR}/jvm.cls.args"
    log "applied instance jvm controls (jvm.cls.args)"
  fi

  # 3) fragments from release overrides (*.args)
  if [[ -d "${OVR_ROOT}/jvm" ]]; then
    while IFS= read -r -d '' f; do
      [[ "$(basename "$f")" == "jvm.args" ]] && die "fragments conflict with replacement jvm.args"
      while IFS= read -r l; do [[ -z "$l" || "$l" =~ ^[[:space:]]*# ]] && continue; JVM_ARGS+=("$l"); done < "$f"
      log "applied JVM fragment: $(basename "$f")"
    done < <(find "${OVR_ROOT}/jvm" -maxdepth 1 -type f -name '*.args' -print0 | sort -z)
  fi

  # persist effective view for ops
  { umask 027; printf "%s\n" "${JVM_ARGS[@]}" > "${RUN_DIR}/jvm.args.effective" 2>/dev/null || true; } || true
}

# ---- hooks (release-scoped; follow current)
run_hooks() {
  local phase="$1"
  local dir="${OVR_ROOT}/hooks/${phase}.d"
  [[ -d "$dir" ]] || { log "no ${phase} hooks"; return 0; }
  while IFS= read -r -d '' f; do
    [[ -x "$f" ]] || chmod +x "$f"
    log "running ${phase} hook: $(basename "$f")"
    set +e; "$f"; local rc=$?; set -e
    if [[ "${FAIL_ON_HOOK}" == "True" || "${FAIL_ON_HOOK}" == "true" ]]; then
      [[ $rc -ne 0 ]] && die "${phase} hook failed: $(basename "$f") (rc=$rc)"
    fi
  done < <(find "$dir" -maxdepth 1 -type f -name '*.sh' -print0 | sort -z)
}

# ---- java & launch
java_bin() {
  if [[ -n "${JAVA_HOME:-}" && -x "${JAVA_HOME}/bin/java" ]]; then echo "${JAVA_HOME}/bin/java"
  elif command -v java >/dev/null 2>&1; then command -v java
  else echo "{{ _java_bin_fallback }}"; fi
}
derive_classpath() { echo "${CODE_DIR}/lib/*:${CODE_DIR}/config"; }

# global command array
declare -a CMD
build_cmd() {
  CMD=( "$(java_bin)" "${JVM_ARGS[@]}" )
  case "{{ _cls_mode }}" in
    class)
      export CLASSPATH="$(derive_classpath)"
      {% if _cls_param|length > 0 %}
      CMD+=( "{{ _cls_param }}" "{{ _cls_main }}" )
      {% else %}
      CMD+=( "{{ _cls_main }}" )
      {% endif %}
      ;;
    jar)
      local JAR="{{ _cls_jar }}"
      [[ -f "$JAR" ]] || die "jar not found: $JAR"
      CMD+=( -jar "$JAR" )
      ;;
    *) die "unknown mode '{{ _cls_mode }}'";;
  esac
  # forward user args to the Java program
  CMD+=( "$@" )
}

start_fg() {
  { printf '===== %s start (release=%s inst=%s) [fg] =====\n' "$(date -Is)" "${RELEASE_VER}" "${INSTANCE_ID}"; } >> "${STDOUT}" 2>&1 || true
  build_cmd "$@"
  log "starting in foreground (release=${RELEASE_VER} inst=${INSTANCE_ID})"
  exec "${CMD[@]}"
}

start_bg() {
  # session header; also redirect the launcher's own logs from here on
  { printf '===== %s start (release=%s inst=%s) =====\n' "$(date -Is)" "${RELEASE_VER}" "${INSTANCE_ID}"; } >> "${STDOUT}" 2>&1 || true
  exec >> "${STDOUT}" 2>&1

  build_cmd "$@"
  log "starting in background → PID file ${PID_FILE}"
  nohup "${CMD[@]}" >>"${STDOUT}" 2>&1 &
  pid=$!
  echo "${pid}" > "${PID_FILE}"

  # quick health probe
  sleep 0.2
  if ! kill -0 "${pid}" 2>/dev/null; then
    log "process died immediately; check ${STDOUT}"
    exit 1
  fi

  log "started pid=${pid}"
  run_hooks post || true
  exit 0
}

case "${1:-}" in
  --pre-only)  load_env; run_hooks pre; exit 0 ;;
  --post-only) run_hooks post; exit 0 ;;
  --fg)        shift; load_env; run_hooks pre; build_jvm_args; start_fg "$@" ;;
  --bg)        shift; load_env; run_hooks pre; build_jvm_args; start_bg "$@" ;;
  *)
    load_env; run_hooks pre; build_jvm_args
    if [[ "${DEFAULT_FG}" == "True" || "${DEFAULT_FG}" == "true" ]]; then
      start_fg "$@"
    else
      start_bg "$@"
    fi
    ;;
esac
