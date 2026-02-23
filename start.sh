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
    up)      docker compose up $BUILD $DETACH $SERVICES ;;
    stop)    docker compose stop $SERVICES ;;
    restart) docker compose restart $SERVICES ;;
    logs)    docker compose logs -f $SERVICES ;;
    status)  docker compose ps ;;
esac
