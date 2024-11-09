#!/bin/bash

# Verifica se a porta foi fornecida como argumento
if [ -z "$1" ]; then
  echo "Uso: ./server.sh PORTA"
  exit 1
fi

# Variável para a porta
PORTA="$1"

# Atualiza o apt e instala o openssh-server
apt update && apt install -y openssh-server

# Modifica o arquivo de configuração do sshd para usar a porta especificada
sed -i "s/#Port 22/Port $PORTA/" /etc/ssh/sshd_config

# Permite o login root e autenticação por senha
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Inicia o serviço SSH
service ssh start

echo "Configuração concluída e serviço SSH iniciado na porta $PORTA."
