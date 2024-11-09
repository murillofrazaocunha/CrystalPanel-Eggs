#!/bin/bash

# Verifica se a porta foi fornecida como argumento
if [ -z "$1" ]; then
  echo "Uso: ./server.sh PORTA"
  exit 1
fi

PORTA="$1"

apt install -y -qq openssh-server >/dev/null

# Modifica o arquivo de configuração do sshd para usar a porta especificada
sed -i "s/#Port 22/Port $PORTA/" /etc/ssh/sshd_config

# Permite o login root e autenticação por senha
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Define a senha para o usuário root
echo "root:12345678" | sudo chpasswd

service ssh start

echo "Configuração concluída e serviço SSH iniciado na porta $PORTA."
echo "Use ssh root@IP -p $PORTA com a senha 12345678 para acessar o SSH" 
