#!/bin/bash

# Verifica se a porta foi fornecida como argumento
if [ -z "$1" ]; then
  echo "Uso: ./server.sh PORTA"
  exit 1
fi

# Variável para a porta
PORTA="$1"

# Solicita a senha do usuário root
echo "Digite a senha para o usuário root:"
read -s ROOT_PASSWORD

# Atualiza o apt e instala o openssh-server
sudo apt update && sudo apt install -y openssh-server

echo "Setando porta do SSH"
# Modifica o arquivo de configuração do sshd para usar a porta especificada
sudo sed -i "s/#Port 22/Port $PORTA/" /etc/ssh/sshd_config

# Permite o login root e autenticação por senha
echo "Login do ROOT"
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
echo "Login por SENHA"
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Define a senha para o usuário root
echo "root:$ROOT_PASSWORD" | sudo chpasswd

# Inicia o serviço SSH
sudo service ssh start

echo "Configuração concluída e serviço SSH iniciado na porta $PORTA."
