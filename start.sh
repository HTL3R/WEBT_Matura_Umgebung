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
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/server/compose.yaml"

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

case $ACTION in
    up)      docker compose -f "$COMPOSE_FILE" up $BUILD $DETACH $SERVICES ;;
    stop)    docker compose -f "$COMPOSE_FILE" stop $SERVICES ;;
    restart) docker compose -f "$COMPOSE_FILE" restart $SERVICES ;;
    logs)    docker compose -f "$COMPOSE_FILE" logs -f $SERVICES ;;
    status)  docker compose -f "$COMPOSE_FILE" ps ;;
esac
