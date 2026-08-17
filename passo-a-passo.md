# Passo a Passo Manual (Ubuntu 20.04)

Caso prefira instalar manualmente sem o script.

## 1. Preparar o sistema

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git screen ufw python3
```

## 2. Baixar o DragonTCP

```bash
cd /opt
sudo git clone https://git.dr2.site/penguinehis/DragonTCP.git
cd DragonTCP/bin
sudo chmod +x dragontcp-hybrid-server-linux-amd64 dragontcp-hybrid-server-linux-arm64
# Use o binário correspondente à arquitetura da VPS: amd64 ou arm64.
```

## 3. Criar o serviço do DragonTCP

```bash
sudo nano /etc/systemd/system/dragontcp.service
```

Conteúdo:

```ini
[Unit]
Description=DragonTCP Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/DragonTCP
EnvironmentFile=-/etc/default/dragontcp
ExecStart=/bin/sh -c 'exec /opt/DragonTCP/dragontcp-server ${DRAGONTCP_TOKEN:+--token "$DRAGONTCP_TOKEN"} --port 53 --port-alt 80 --chunk-max 1048576'
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

## 4. Ativar o DragonTCP

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now dragontcp
sudo systemctl status dragontcp
```

## 5. Criar o painel

```bash
sudo mkdir -p /opt/tcp
sudo nano /opt/tcp/painel.py
```

Cole o conteúdo do arquivo `painel.py` deste repositório e dê permissão:

```bash
sudo chmod +x /opt/tcp/painel.py
```

## 6. Serviço do painel

```bash
sudo nano /etc/systemd/system/dragontcp-painel.service
```

```ini
[Unit]
Description=DragonTCP Admin Panel
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /opt/tcp/painel.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now dragontcp-painel
```

## 7. Firewall

```bash
sudo ufw allow 22/tcp
sudo ufw allow 53/tcp
sudo ufw allow 80/tcp
sudo ufw allow 9999/tcp
sudo ufw enable
sudo ufw reload
```

## 8. Verificar

```bash
sudo systemctl status dragontcp
sudo systemctl status dragontcp-painel
ss -tulnp | grep -E ':53|:80|:9999'
```

## Uso

- Painel: `nc SEU_IP 9999` (configure `DRAGONTCP_PANEL_PASSWORD` em `/etc/default/dragontcp-panel` antes de iniciar o painel).
- App Android: IP + porta 53 ou 80 + token.