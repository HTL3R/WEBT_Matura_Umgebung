#!/bin/bash

usage() {
    echo "Usage: $0 [options] [services...]"
    echo ""
    echo "Services: server, vue, react (default: all)"
    echo ""
    echo "Options:"
    echo "  -b, --build     Force rebuild images"
    echo "  -d, --detach    Run in background"
    echo "  -s, --stop      Stop running containers"
    echo "  -r, --restart   Restart containers"
    echo "  -l, --logs      Show logs (combine with service names)"
    echo "  --status        Show container status"
    echo "  -h, --help      Show this help"
    echo ""
    echo "Uses podman if installed, otherwise docker."
    echo "Override with CONTAINER_ENGINE=docker|podman."
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/compose.yaml"
COMPOSE_FILES=(-f "$COMPOSE_FILE")

# --- Container engine detection -------------------------------------------
# Default: docker. If podman is installed, podman is used instead.
# Override with: CONTAINER_ENGINE=docker ./script.sh  (or =podman)
detect_engine() {
    if [[ -n "$CONTAINER_ENGINE" ]]; then
        ENGINE="$CONTAINER_ENGINE"
    elif command -v podman >/dev/null 2>&1; then
        ENGINE="podman"
    else
        ENGINE="docker"
    fi

    if ! command -v "$ENGINE" >/dev/null 2>&1; then
        echo "Error: '$ENGINE' is not installed." >&2
        exit 1
    fi
}

# Sets COMPOSE to the matching compose command for $ENGINE.
detect_compose() {
    if [[ "$ENGINE" == "podman" ]]; then
        # Prefer podman-compose directly: 'podman compose' may delegate to
        # docker-compose, which would talk to the Docker daemon instead.
        if command -v podman-compose >/dev/null 2>&1; then
            COMPOSE=(podman-compose)
        elif podman compose version >/dev/null 2>&1; then
            COMPOSE=(podman compose)
        else
            echo "Error: podman-compose is not installed (e.g. 'sudo apt install podman-compose')." >&2
            exit 1
        fi

        if [[ "$(podman info --format '{{.Host.Security.Rootless}}' 2>/dev/null)" == "true" ]]; then
            # Rootless podman: services with a fixed 'user:' (e.g. server, 1000:1000)
            # need 'keep-id' so that UID maps to the host user and mounted
            # volumes stay writable. Services running as root are already
            # mapped to the host user and must not be changed.
            local user_services
            user_services="$(awk '
                /^services:/ { in_s=1; next }
                in_s && /^[^ #]/ { in_s=0 }
                in_s && /^  [A-Za-z0-9_.-]+:/ { svc=$1; sub(":", "", svc) }
                in_s && /^    user:/ { print svc }
            ' "$COMPOSE_FILE")"
            if [[ -n "$user_services" ]]; then
                # Fixed path per project (overwritten on every run, no temp-file leftovers)
                PODMAN_OVERRIDE="${TMPDIR:-/tmp}/podman-compose-override-$(id -u)-$(echo "$SCRIPT_DIR" | md5sum | cut -c1-8).yaml"
                {
                    echo "services:"
                    for svc in $user_services; do
                        echo "  $svc:"
                        echo "    userns_mode: keep-id"
                    done
                } > "$PODMAN_OVERRIDE"
                COMPOSE_FILES+=(-f "$PODMAN_OVERRIDE")
            fi

            # Rootless podman cannot bind ports < 1024 (unless allowed by sysctl).
            local min_port
            min_port="$(cat /proc/sys/net/ipv4/ip_unprivileged_port_start 2>/dev/null || echo 1024)"
            if [[ -z "$HTTP_PORT" && "$min_port" -gt 80 ]]; then
                export HTTP_PORT=8080
                echo "Note: rootless podman cannot use port 80, server runs on port 8080 (override with HTTP_PORT=...)."
            fi
        fi
    else
        if docker compose version >/dev/null 2>&1; then
            COMPOSE=(docker compose)
        elif command -v docker-compose >/dev/null 2>&1; then
            COMPOSE=(docker-compose)
        else
            echo "Error: docker compose is not installed." >&2
            exit 1
        fi
    fi
}

ACTION="up"
BUILD=""
DETACH=""
SERVICES=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--build)   BUILD="--build"; shift ;;
        -d|--detach)  DETACH="-d"; shift ;;
        -s|--stop)    ACTION="stop"; shift ;;
        -r|--restart) ACTION="restart"; shift ;;
        -l|--logs)    ACTION="logs"; shift ;;
        --status)     ACTION="status"; shift ;;
        -h|--help)    usage; exit 0 ;;
        server|vue|react) SERVICES="$SERVICES $1"; shift ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

detect_engine
detect_compose
echo "==> Using $ENGINE (${COMPOSE[*]})"

# podman-compose does not recreate existing containers on --build,
# so the freshly built image would not be used without --force-recreate.
if [[ "$ENGINE" == "podman" && -n "$BUILD" ]]; then
    BUILD="$BUILD --force-recreate"
fi

case $ACTION in
    up)      "${COMPOSE[@]}" "${COMPOSE_FILES[@]}" up $BUILD $DETACH $SERVICES ;;
    stop)    "${COMPOSE[@]}" "${COMPOSE_FILES[@]}" stop $SERVICES ;;
    restart) "${COMPOSE[@]}" "${COMPOSE_FILES[@]}" restart $SERVICES ;;
    logs)    "${COMPOSE[@]}" "${COMPOSE_FILES[@]}" logs -f $SERVICES ;;
    status)  "${COMPOSE[@]}" "${COMPOSE_FILES[@]}" ps ;;
esac
