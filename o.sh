#!/usr/bin/env bash
set -Eeuo pipefail

log() { printf '[%(%Y-%m-%dT%H:%M:%S%z)T] %s\n' -1 "$*"; }

RUN_DIR="{{ run_dir }}"
PID_FILE="{{ pid_file | default(run_dir + '/' + app_name + '.pid') }}"
MODE="{{ _cls_mode | default('class') }}"
JAR="{{ _cls_jar | default('') }}"
MAIN="{{ _cls_main | default('') }}"
APP="{{ app_name }}"

exists_pid() { kill -0 "$1" 2>/dev/null; }

kill_gracefully() {
  local pid="$1" timeout="${2:-10}"
  log "stopping ${APP} (pid ${pid})"
  kill -TERM "${pid}" 2>/dev/null || return 0
  for ((i=0;i<timeout;i++)); do
    exists_pid "${pid}" || { log "stopped ${APP} (pid ${pid})"; return 0; }
    sleep 1
  done
  log "forcing kill ${APP} (pid ${pid})"
  kill -KILL "${pid}" 2>/dev/null || true
}

# 1) PID file path first (most precise)
if [[ -f "${PID_FILE}" ]]; then
  PID="$(cat "${PID_FILE}" 2>/dev/null || true)"
  if [[ -n "${PID:-}" ]] && exists_pid "${PID}"; then
    kill_gracefully "${PID}"
    exit 0
  fi
  log "PID file present but process not running (pid=${PID:-?}); removing PID file"
  rm -f "${PID_FILE}" || true
fi

# 2) Fallback: try to locate via process signature (best-effort, guarded)
if command -v pgrep >/dev/null 2>&1; then
  pattern=""
  if [[ "${MODE}" == "jar" && -n "${JAR}" ]]; then
    pattern="$(basename -- "${JAR}")"
  elif [[ -n "${MAIN}" ]]; then
    pattern="${MAIN}"
  fi

  if [[ -n "${pattern}" ]]; then
    mapfile -t PIDS < <(pgrep -f "java .*${pattern}" || true)
    if [[ ${#PIDS[@]} -eq 1 ]]; then
      kill_gracefully "${PIDS[0]}"
      exit 0
    elif [[ ${#PIDS[@]} -gt 1 ]]; then
      log "multiple candidate pids for pattern '${pattern}': ${PIDS[*]} — not killing to avoid collateral"
      exit 1
    fi
  fi
fi

log "no running process found for ${APP}"
exit 0
