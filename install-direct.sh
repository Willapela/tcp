#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/Willapela/tcp.git"
DIR="/opt/tcp"

if [[ "$(id -u)" -ne 0 ]]; then
    echo "Execute como root: sudo bash install-direct.sh"
    exit 1
fi

echo "======================================"
echo "   DRAGONTCP - INSTALAÇÃO OFICIAL"
echo "======================================"

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y git ca-certificates

rm -rf "$DIR"
git clone --depth 1 --branch main "$REPO" "$DIR"
chmod +x "$DIR"/*.sh

exec bash "$DIR/install.sh"
