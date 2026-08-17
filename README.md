# DragonTCP Ubuntu — instalador e atualizador

Este repositório contém apenas o facilitador de instalação do **DragonTCP Hybrid**. O código principal e os binários são sincronizados diretamente do repositório oficial [DragonTCP](https://git.dr2.site/penguinehis/DragonTCP).

## Instalação

Em uma VPS Ubuntu 20.04 ou superior, execute:

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/Willapela/tcp/main/install-direct.sh)
```

O instalador mantém o facilitador em `/opt/tcp`, sincroniza a versão oficial em `/opt/DragonTCP`, detecta automaticamente `x86_64/amd64` ou `aarch64/arm64` e cria o serviço `dragontcp`.

## Atualização

Para atualizar uma instalação existente:

```bash
cd /opt/tcp
sudo bash update.sh
```

O script baixa a branch `main` do projeto oficial, preserva `dragontcp-users.json` quando esse arquivo já existe, seleciona o binário correto, atualiza o link `/opt/DragonTCP/dragontcp-server`, recria a unidade systemd e reinicia o serviço.

## Serviço e configuração

O servidor oficial usa o binário `dragontcp-hybrid-server-linux-amd64` em AMD64 ou `dragontcp-hybrid-server-linux-arm64` em ARM64. Por padrão, o serviço escuta TCP nas portas **53 e 80** e usa `--chunk-max 1048576`. A segunda porta pode ser desativada editando a unidade e trocando `--port-alt 80` por `--port-alt 0`.

O token é opcional e fica em `/etc/default/dragontcp`:

```bash
sudo nano /etc/default/dragontcp
sudo systemctl restart dragontcp
```

Exemplo:

```ini
DRAGONTCP_TOKEN=uma_senha_forte
```

Não exponha publicamente as portas internas de SSH e UDPGW do DragonTCP. Consulte a documentação oficial para configurar o menu SSH, usuários, cliente e demais opções.

## Painel administrativo opcional

O arquivo `painel.py` é um painel TCP simples na porta `9999`. Ele **não inicia com senha padrão**. Para habilitá-lo, crie `/etc/default/dragontcp-panel` com uma senha forte:

```ini
DRAGONTCP_PANEL_PASSWORD=uma_senha_forte
```

Depois instale a unidade `dragontcp-painel.service`, recarregue o systemd e habilite o serviço. Restrinja a porta 9999 por firewall ou rede privada; não a exponha diretamente à Internet sem proteção adicional.

## Desinstalação

```bash
cd /opt/tcp
sudo bash uninstall.sh
```

O comando remove os serviços, arquivos de ambiente, facilitador e cópia sincronizada em `/opt/DragonTCP`.

## Fonte oficial

A versão do DragonTCP usada em cada atualização vem de:

`https://git.dr2.site/penguinehis/DragonTCP.git`

Para detalhes de flags e operação, consulte o [README oficial](https://git.dr2.site/penguinehis/DragonTCP/blob/main/README.md).
