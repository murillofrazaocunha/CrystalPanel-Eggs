#!/bin/bash

# Verifica se a porta foi fornecida como argumento
if [ -z "$1" ]; then
  echo "Uso: ./server.sh PORTA"
  exit 1
fi

PORTA="$1"

# Instala o servidor SSH, garantindo que as mensagens sejam exibidas
apt install -y -qq openssh-server

# Modifica o arquivo de configuração do sshd para usar a porta especificada
sed -i "s/#Port 22/Port $PORTA/" /etc/ssh/sshd_config

# Permite o login root e autenticação por senha
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Define a senha para o usuário root
echo "root:12345678" | chpasswd

# Reinicia o serviço SSH para aplicar as mudanças
service ssh restart

# Exibe mensagens de status
echo "Configuração concluída e serviço SSH iniciado na porta $PORTA."
echo "Use ssh root@IP -p $PORTA com a senha 12345678 para acessar o SSH"
