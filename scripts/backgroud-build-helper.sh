#!/bin/bash -eu

# Background build helper.
# Runs build.sh in the background and reports its state.
# build.sh itself is not modified; this script only shells out to it.
#
# State files: work/.build-helper/{pid,rc,build.log,args,started_at}

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_DIR=$(dirname "$SCRIPT_DIR")
STATE_DIR=${REPO_DIR}/work/.build-helper
PID_FILE=${STATE_DIR}/pid
RC_FILE=${STATE_DIR}/rc
LOG_FILE=${STATE_DIR}/build.log
ARGS_FILE=${STATE_DIR}/args
STARTED_FILE=${STATE_DIR}/started_at

Usage() {
    echo "Usage:"
    echo "    $0 <command> [args]"
    echo "command:"
    echo "    start [build options...]:  Start build.sh in background"
    echo "                               (options are passed to build.sh)"
    echo "    status:                   Show the state of the background build"
    echo "    wait:                     Block until the build completes"
    echo "                               (exit code = build.sh exit code)"
    echo "    tail [N]:                 Show the last N lines of the log (default 30)"
    echo "    stop:                     Stop the running background build"
}

die() {
    echo -e "\e[31mERROR: $1\e[m" >&2
    exit 2
}

get_pid() {
    [[ -f "${PID_FILE}" ]] && cat "${PID_FILE}"
}

is_running() {
    local pid
    pid=$(get_pid) || return 1
    [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null
}

fmt_elapsed() {
    local secs=$(( $2 - $1 ))
    printf '%dh%02dm%02ds' $(( secs / 3600 )) $(( secs % 3600 / 60 )) $(( secs % 60 ))
}

kill_tree() {
    local pid=$1
    local c
    for c in $(pgrep -P "${pid}" 2>/dev/null || true); do
        kill_tree "${c}"
    done
    kill -TERM "${pid}" 2>/dev/null || true
}

cmd_start() {
    if is_running; then
        die "build already running (PID $(get_pid)). Use 'stop' first."
    fi
    mkdir -p "${STATE_DIR}"
    rm -f "${PID_FILE}" "${RC_FILE}"

    local launcher=${STATE_DIR}/run.sh
    {
        echo '#!/bin/bash'
        echo 'set +e'
        echo "echo \"\$\$\" > \"${PID_FILE}\""
        printf 'bash '
        printf '%q ' "${REPO_DIR}/build.sh"
        if [[ $# -gt 0 ]]; then
            printf '%q ' "$@"
        fi
        echo
        echo "printf '%s' \"\$?\" > \"${RC_FILE}\""
    } > "${launcher}"

    setsid bash "${launcher}" > "${LOG_FILE}" 2>&1 < /dev/null &
    local i
    for i in $(seq 1 50); do
        [[ -f "${PID_FILE}" ]] && break
        sleep 0.1
    done
    local pid
    pid=$(cat "${PID_FILE}" 2>/dev/null) || die "build process did not start"
    date +%s > "${STARTED_FILE}"
    if [[ $# -gt 0 ]]; then
        printf '%q ' "$@" > "${ARGS_FILE}"
    else
        : > "${ARGS_FILE}"
    fi
    echo "STATE: STARTED"
    echo "PID: ${pid}"
    echo "ARGS: ${*}"
    echo "LOG: ${LOG_FILE}"
}

cmd_status() {
    if ! [[ -f "${PID_FILE}" ]]; then
        echo "STATE: NONE"
        return 0
    fi
    local pid rc started
    pid=$(cat "${PID_FILE}")
    if kill -0 "${pid}" 2>/dev/null; then
        echo "STATE: RUNNING"
        echo "PID: ${pid}"
        echo "ARGS: $(cat "${ARGS_FILE}" 2>/dev/null || true)"
        started=$(cat "${STARTED_FILE}" 2>/dev/null || date +%s)
        echo "ELAPSED: $(fmt_elapsed "${started}" "$(date +%s)")"
        echo "LOG: ${LOG_FILE}"
        echo "---- last 10 lines ----"
        tail -n 10 "${LOG_FILE}" 2>/dev/null || true
        return 0
    fi
    if [[ -f "${RC_FILE}" ]]; then
        rc=$(cat "${RC_FILE}")
        if [[ "${rc}" == "0" ]]; then
            echo "STATE: DONE"
        else
            echo "STATE: FAILED"
        fi
        echo "RC: ${rc}"
        started=$(cat "${STARTED_FILE}" 2>/dev/null || true)
        [[ -n "${started}" ]] && echo "ELAPSED: $(fmt_elapsed "${started}" "$(date +%s)")"
        echo "LOG: ${LOG_FILE}"
        if [[ "${rc}" != "0" ]]; then
            echo "---- last 30 lines ----"
            tail -n 30 "${LOG_FILE}" 2>/dev/null || true
        fi
        return 0
    fi
    echo "STATE: UNKNOWN (process ${pid} died without rc file)"
    echo "LOG: ${LOG_FILE}"
    tail -n 30 "${LOG_FILE}" 2>/dev/null || true
    return 0
}

cmd_wait() {
    [[ -f "${PID_FILE}" ]] || die "no build has been started"
    local pid
    pid=$(cat "${PID_FILE}")
    while kill -0 "${pid}" 2>/dev/null; do
        sleep 5
    done
    cmd_status
    [[ -f "${RC_FILE}" ]] || die "build process died without rc file"
    exit "$(cat "${RC_FILE}")"
}

cmd_tail() {
    [[ -f "${LOG_FILE}" ]] || die "no log file (run start first)"
    tail -n "${1:-30}" "${LOG_FILE}"
}

cmd_stop() {
    local pid
    pid=$(get_pid) || die "no build has been started"
    [[ -n "${pid}" ]] || die "no build has been started"
    kill_tree "${pid}"
    local c
    for c in $(seq 1 10); do
        kill -0 "${pid}" 2>/dev/null || break
        sleep 1
    done
    if kill -0 "${pid}" 2>/dev/null; then
        echo "FORCE KILL"
        for c in $(pgrep -P "${pid}" 2>/dev/null || true); do
            kill -KILL "${c}" 2>/dev/null || true
        done
        kill -KILL "${pid}" 2>/dev/null || true
    fi
    printf '143' > "${RC_FILE}"
    echo "STATE: STOPPED"
}

[[ $# -ge 1 ]] || { Usage; exit 2; }
CMD=$1
shift
case "${CMD}" in
    start) cmd_start "$@" ;;
    status) cmd_status ;;
    wait) cmd_wait ;;
    tail) cmd_tail "$@" ;;
    stop) cmd_stop ;;
    -h|--help) Usage; exit 0 ;;
    *) die "unknown command: ${CMD}" ;;
esac
