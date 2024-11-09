#!/bin/bash

# Verifica se a porta foi fornecida como argumento
if [ -z "$1" ]; then
  echo "Uso: ./server.sh PORTA"
  exit 1
fi

PORTA="$1"

# Instala o servidor SSH silenciosamente
apt update && apt install -y openssh-server

# Mostra o conteúdo do sshd_config antes das alterações
echo "Conteúdo original de /etc/ssh/sshd_config:"
cat /etc/ssh/sshd_config

# Modifica o arquivo de configuração do sshd para usar a porta especificada
sed -i "s/#Port 22/Port $PORTA/" /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Mostra o conteúdo do sshd_config após as alterações
echo "Conteúdo de /etc/ssh/sshd_config após alterações:"
cat /etc/ssh/sshd_config

# Define a senha para o usuário root
echo "root:12345678" | chpasswd

# Inicia o serviço SSH
service ssh start

# Exibe as mensagens de status com `tee` para garantir que sejam exibidas
echo "Configuração concluída e serviço SSH iniciado na porta $PORTA." | tee /dev/stderr
echo "Use ssh root@IP -p $PORTA com a senha 12345678 para acessar o SSH" | tee /dev/stderr
