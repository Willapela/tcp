#!/usr/bin/env bash
set -euo pipefail

OFFICIAL_REPO="https://git.dr2.site/penguinehis/DragonTCP.git"
INSTALL_DIR="/opt/DragonTCP"
SERVICE_NAME="dragontcp"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
ENV_FILE="/etc/default/dragontcp"

if [[ "$(id -u)" -ne 0 ]]; then
    echo "Execute como root: sudo bash update.sh"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y git ca-certificates

case "$(uname -m)" in
    x86_64|amd64)
        SERVER_BIN="dragontcp-hybrid-server-linux-amd64"
        ;;
    aarch64|arm64)
        SERVER_BIN="dragontcp-hybrid-server-linux-arm64"
        ;;
    *)
        echo "Arquitetura não suportada: $(uname -m)"
        echo "Suportadas: x86_64/amd64 e aarch64/arm64."
        exit 1
        ;;
esac

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Baixando a versão oficial do DragonTCP..."
git clone --depth 1 --branch main "$OFFICIAL_REPO" "$TMP_DIR/DragonTCP"

chmod +x "$TMP_DIR/DragonTCP/bin/$SERVER_BIN" 2>/dev/null || true
if [[ ! -f "$TMP_DIR/DragonTCP/bin/$SERVER_BIN" ]]; then
    echo "ERRO: o binário oficial bin/$SERVER_BIN não foi encontrado."
    exit 1
fi

mkdir -p "$INSTALL_DIR"
if [[ -f "$INSTALL_DIR/dragontcp-users.json" ]]; then
    cp -a "$INSTALL_DIR/dragontcp-users.json" "$TMP_DIR/dragontcp-users.json.backup"
fi
rm -rf "$INSTALL_DIR"/*
cp -a "$TMP_DIR/DragonTCP"/. "$INSTALL_DIR"/
if [[ -f "$TMP_DIR/dragontcp-users.json.backup" ]]; then
    cp -a "$TMP_DIR/dragontcp-users.json.backup" "$INSTALL_DIR/dragontcp-users.json"
fi
chmod +x "$INSTALL_DIR/bin/$SERVER_BIN"
ln -sfn "$INSTALL_DIR/bin/$SERVER_BIN" "$INSTALL_DIR/dragontcp-server"

if [[ ! -f "$ENV_FILE" ]]; then
    cat > "$ENV_FILE" <<'EOF'
# Token opcional do DragonTCP. Deixe vazio para usar o modo sem token.
DRAGONTCP_TOKEN=
EOF
    chmod 600 "$ENV_FILE"
fi

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=DragonTCP Hybrid Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
EnvironmentFile=-$ENV_FILE
ExecStart=/bin/sh -c 'exec "$INSTALL_DIR/dragontcp-server" \${DRAGONTCP_TOKEN:+--token "\$DRAGONTCP_TOKEN"} --port 53 --port-alt 80 --chunk-max 1048576'
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl restart "$SERVICE_NAME"

echo
echo "DragonTCP atualizado com sucesso."
echo "Arquitetura: $(uname -m)"
echo "Binário: $INSTALL_DIR/bin/$SERVER_BIN"
echo "Commit oficial:"
git -C "$INSTALL_DIR" log -1 --oneline 2>/dev/null || true
echo
echo "Serviço: $(systemctl is-active "$SERVICE_NAME" || true)"
echo "Portas: 53 e 80 (use --port-alt 0 para desativar a segunda)."
