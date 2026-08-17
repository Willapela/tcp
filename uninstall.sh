#!/usr/bin/env bash
set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
    echo "Execute como root: sudo bash uninstall.sh"
    exit 1
fi

echo "Parando serviços..."
systemctl stop dragontcp-painel 2>/dev/null || true
systemctl stop dragontcp 2>/dev/null || true
systemctl disable dragontcp-painel 2>/dev/null || true
systemctl disable dragontcp 2>/dev/null || true

rm -f /etc/systemd/system/dragontcp.service
rm -f /etc/systemd/system/dragontcp-painel.service
rm -f /etc/default/dragontcp /etc/default/dragontcp-panel
systemctl daemon-reload

rm -rf /opt/tcp /opt/DragonTCP

echo "DragonTCP e os serviços associados foram removidos."
