#!/usr/bin/env python3
import os
import socket
import subprocess
from datetime import datetime

HOST = os.environ.get("DRAGONTCP_PANEL_HOST", "0.0.0.0")
PORT = int(os.environ.get("DRAGONTCP_PANEL_PORT", "9999"))
PASSWORD = os.environ.get("DRAGONTCP_PANEL_PASSWORD", "")


def run(command):
    try:
        return subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT, text=True)
    except subprocess.CalledProcessError as exc:
        return exc.output


def handle_client(conn, addr):
    try:
        conn.sendall(b"\n===== DragonTCP Admin Panel =====\n")
        if not PASSWORD:
            conn.sendall(b"Painel desabilitado: configure DRAGONTCP_PANEL_PASSWORD.\n")
            return

        conn.sendall(b"Digite a senha: ")
        senha = conn.recv(1024).decode(errors="replace").strip()
        if senha != PASSWORD:
            conn.sendall(b"Senha incorreta. Saindo...\n")
            return

        while True:
            menu = """
===== MENU =====
1. Status do DragonTCP
2. Reiniciar DragonTCP
3. Parar DragonTCP
4. Iniciar DragonTCP
5. Ver logs (ultimas 30 linhas)
6. Uso de CPU/RAM
7. Ver portas 53 e 80
0. Sair
================
Escolha: """
            conn.sendall(menu.encode())
            escolha = conn.recv(1024).decode(errors="replace").strip()

            if escolha == "1":
                conn.sendall(f"\nStatus: {run('systemctl is-active dragontcp')}\n".encode())
            elif escolha == "2":
                run("systemctl restart dragontcp")
                conn.sendall(b"\nDragonTCP reiniciado.\n")
            elif escolha == "3":
                run("systemctl stop dragontcp")
                conn.sendall(b"\nDragonTCP parado.\n")
            elif escolha == "4":
                run("systemctl start dragontcp")
                conn.sendall(b"\nDragonTCP iniciado.\n")
            elif escolha == "5":
                conn.sendall(f"\n{run('journalctl -u dragontcp -n 30 --no-pager')}\n".encode())
            elif escolha == "6":
                conn.sendall(f"\n{run('top -bn1 | head -n 5 && free -h')}\n".encode())
            elif escolha == "7":
                portas = run("ss -tulnp | grep -E ':(53|80)([[:space:]]|$)' || true")
                conn.sendall(f"\n{portas}\n".encode())
            elif escolha == "0":
                conn.sendall(b"\nSaindo...\n")
                break
            else:
                conn.sendall(b"\nOpcao invalida.\n")
    except Exception as exc:
        print(f"Erro com {addr}: {exc}")
    finally:
        conn.close()


def main():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server:
        server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server.bind((HOST, PORT))
        server.listen(5)
        print(f"[{datetime.now()}] Painel rodando na porta {PORT}")
        while True:
            conn, addr = server.accept()
            print(f"Conexao de {addr}")
            handle_client(conn, addr)


if __name__ == "__main__":
    main()
