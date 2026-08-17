#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/tcp"

if [[ "$(id -u)" -ne 0 ]]; then
    echo "Execute como root: sudo bash install.sh"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y git ca-certificates python3

if [[ ! -f "$APP_DIR/update.sh" ]]; then
    echo "ERRO: update.sh não foi encontrado em $APP_DIR."
    exit 1
fi

chmod +x "$APP_DIR"/*.sh
bash "$APP_DIR/update.sh"

echo
echo "Instalação concluída."
echo "DragonTCP: /opt/DragonTCP"
echo "Facilitador: /opt/tcp"
