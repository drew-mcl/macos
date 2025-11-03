#!/usr/bin/env bash
set -Eeuo pipefail

log() { printf '[%(%Y-%m-%dT%H:%M:%S%z)T] %s\n' -1 "$*"; }
die() { log "ERROR: $*"; exit 1; }

CONFIG_DIR="{{ config_dir }}"            # legacy fallback only
CURRENT_LINK="{{ current_dir }}"         # -> releases/<ver>
INSTANCE_ID="{{ _neuron_instance_id }}"
JAVA_FALLBACK="{{ _java_bin_fallback }}"
FAIL_ON_HOOK="{{ _fail_on_hook_error }}"

# ----- helpers
realpath_portable() {
  if command -v readlink >/dev/null 2>&1; then readlink -f -- "$1" 2>/dev/null && return 0; fi
  if command -v realpath >/dev/null 2>&1; then realpath "$1" && return 0; fi
  (cd "$(dirname "$1")" && dir=$(pwd -P) && echo "${dir}/$(basename "$1")")
}

require_path() {
  local p="$1" msg="$2"
  [[ -e "$p" ]] || die "$msg ($p)"
}

# ----- resolve current release and per-instance cls path
require_path "$CURRENT_LINK" "current symlink missing; cannot resolve active release"
CODE_DIR="$(realpath_portable "${CURRENT_LINK}")" || die "failed to resolve current symlink"
require_path "$CODE_DIR" "resolved current does not exist"

RELEASE_VER="$(basename -- "${CODE_DIR}")"
CLS_VER_DIR="${CODE_DIR}/cls/${INSTANCE_ID}/latest"
OVR_ROOT="${CODE_DIR}/overrides"    # release-scoped overrides

# ----- environment assembly
load_env() {
  # Non-exported (instance revision), then release env.local overrides
  if [[ -f "${CLS_VER_DIR}/state.local.env" ]]; then
    # shellcheck disable=SC1090
    source "${CLS_VER_DIR}/state.local.env"
    log "loaded cls state.local.env (non-exported)"
  fi
  if [[ -d "${OVR_ROOT}/env.local" ]]; then
    for f in $(find "${OVR_ROOT}/env.local" -maxdepth 1 -type f -name '*.env' | sort); do
      # shellcheck disable=SC1090
      source "$f"
      log "loaded override env.local: $(basename "$f")"
    done
  fi

  # Exported (instance revision preferred, fallback to legacy instance config), then release overrides
  if [[ -f "${CLS_VER_DIR}/state.env" ]]; then
    set -a; source "${CLS_VER_DIR}/state.env"; set +a
    log "loaded cls state.env (exported)"
  elif [[ -f "${CONFIG_DIR}/state.env" ]]; then
    set -a; source "${CONFIG_DIR}/state.env"; set +a
    log "loaded legacy config/state.env (exported)"
  else
    log "no state.env found for release=${RELEASE_VER}; continuing without exported vars"
  fi

  if [[ -d "${OVR_ROOT}/env" ]]; then
    for f in $(find "${OVR_ROOT}/env" -maxdepth 1 -type f -name '*.env' | sort); do
      set -a; source "$f"; set +a
      log "loaded override env: $(basename "$f")"
    done
  fi
}

# ----- jvm args assembly
build_jvm_args() {
  JVM_ARGS=()

  # 0) Full replacement from release
  if [[ -f "${OVR_ROOT}/jvm/jvm.args" ]]; then
    while IFS= read -r l; do [[ -z "$l" || "$l" =~ ^[[:space:]]*# ]] && continue; JVM_ARGS+=("$l"); done < "${OVR_ROOT}/jvm/jvm.args"
    log "using overrides/jvm/jvm.args (replacement)"; return
  fi

  # 1) Baseline from release
  if [[ -f "${CODE_DIR}/config/jvm.args" ]]; then
    while IFS= read -r l; do [[ -z "$l" || "$l" =~ ^[[:space:]]*# ]] && continue; JVM_ARGS+=("$l"); done < "${CODE_DIR}/config/jvm.args"
    log "loaded baseline jvm.args"
  fi

  # 2) Instance inventory-derived for THIS release
  if [[ -f "${CLS_VER_DIR}/jvm.cls.args" ]]; then
    while IFS= read -r l; do [[ -z "$l" || "$l" =~ ^[[:space:]]*# ]] && continue; JVM_ARGS+=("$l"); done < "${CLS_VER_DIR}/jvm.cls.args"
    log "applied instance jvm controls (jvm.cls.args)"
  fi

  # 3) Fragments from release overrides (*.args)
  if [[ -d "${OVR_ROOT}/jvm" ]]; then
    shopt -s nullglob
    mapfile -t _frags < <(find "${OVR_ROOT}/jvm" -maxdepth 1 -type f -name '*.args' | sort)
    shopt -u nullglob
    for f in "${_frags[@]}"; do
      [[ "$(basename "$f")" == "jvm.args" ]] && die "fragments conflict with replacement jvm.args"
      while IFS= read -r l; do [[ -z "$l" || "$l" =~ ^[[:space:]]*# ]] && continue; JVM_ARGS+=("$l"); done < "$f"
      log "applied JVM fragment: $(basename "$f")"
    done
  fi
}

# ----- hooks (release-scoped, follow current)
run_hooks() {
  local phase="$1"
  local dir="${OVR_ROOT}/hooks/${phase}.d"
  [[ -d "$dir" ]] || { log "no ${phase} hooks"; return 0; }
  for f in $(find "$dir" -maxdepth 1 -type f -name '*.sh' | sort); do
    [[ -x "$f" ]] || chmod +x "$f"
    log "running ${phase} hook: $(basename "$f")"
    set +e; "$f"; local rc=$?; set -e
    if [[ "${FAIL_ON_HOOK}" == "True" || "${FAIL_ON_HOOK}" == "true" ]]; then
      [[ $rc -ne 0 ]] && die "${phase} hook failed: $(basename "$f") (rc=$rc)"
    fi
  done
}

# ----- java & launch
java_bin() {
  if [[ -n "${JAVA_HOME:-}" && -x "${JAVA_HOME}/bin/java" ]]; then echo "${JAVA_HOME}/bin/java"
  elif command -v java >/dev/null 2>&1; then command -v java
  else echo "{{ _java_bin_fallback }}"; fi
}

derive_classpath() { echo "${CODE_DIR}/lib/*:${CODE_DIR}/config"; }

launch_exec() {
  case "{{ _cls_mode }}" in
    class)
      [[ -n "{{ _cls_main }}" ]] || die "main_class not set"
      export CLASSPATH="$(derive_classpath)"
      log "exec main class (release=${RELEASE_VER} inst=${INSTANCE_ID})"
      exec "$(java_bin)" "${JVM_ARGS[@]}" "{{ _cls_main }}"
      ;;
    jar)
      local JAR="{{ _cls_jar }}"
      [[ -f "$JAR" ]] || die "jar not found: $JAR"
      log "exec jar (release=${RELEASE_VER} inst=${INSTANCE_ID})"
      exec "$(java_bin)" "${JVM_ARGS[@]}" -jar "$JAR"
      ;;
    *) die "unknown mode '{{ _cls_mode }}'";;
  esac
}

case "${1:-}" in
  --pre-only)  load_env; run_hooks pre; exit 0 ;;
  --exec)      load_env; build_jvm_args; launch_exec ;;
  --post-only) run_hooks post; exit 0 ;;
  *)           load_env; run_hooks pre; build_jvm_args; launch_exec ;;
esac
