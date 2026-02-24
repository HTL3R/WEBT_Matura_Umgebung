#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLIENTDIR="$SCRIPT_DIR/client"
SERVERDIR="$SCRIPT_DIR/server"
EXPORT_DIR="$SCRIPT_DIR/_images"

usage() {
    echo "Usage: $0 [options] [vue|react|server|all]"
    echo ""
    echo "Builds Docker images for the specified service(s)."
    echo "Default target: all"
    echo ""
    echo "Options:"
    echo "  -e, --export    Export built images as .tar files to _images/"
    echo "  -h, --help      Show this help"
}

build_vue() {
    echo "==> Building Vue.js image..."
    docker build -t matura-webt-vue "$CLIENTDIR/vue-project"
    echo "==> Vue.js image built successfully."
}

build_react() {
    echo "==> Building React image..."
    docker build -t matura-webt-react "$CLIENTDIR/react-project"
    echo "==> React image built successfully."
}

build_server() {
    echo "==> Building server image..."
    docker build -t matura-webt-server "$SERVERDIR"
    echo "==> Server image built successfully."
}

export_image() {
    local name="$1"
    mkdir -p "$EXPORT_DIR"
    echo "==> Exporting $name to $EXPORT_DIR/$name.tar ..."
    docker save -o "$EXPORT_DIR/$name.tar" "$name"
    echo "==> Exported $name ($(du -h "$EXPORT_DIR/$name.tar" | cut -f1))"
}

EXPORT=false
TARGET=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--export) EXPORT=true; shift ;;
        -h|--help)   usage; exit 0 ;;
        vue|react|server|all) TARGET="$1"; shift ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

TARGET="${TARGET:-all}"

case "$TARGET" in
    vue)
        build_vue
        $EXPORT && export_image matura-webt-vue
        ;;
    react)
        build_react
        $EXPORT && export_image matura-webt-react
        ;;
    server)
        build_server
        $EXPORT && export_image matura-webt-server
        ;;
    all)
        build_server
        build_vue
        build_react
        if $EXPORT; then
            export_image matura-webt-server
            export_image matura-webt-vue
            export_image matura-webt-react
        fi
        ;;
esac
