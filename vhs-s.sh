#!/bin/bash

# Verifica se a porta foi fornecida como argumento
if [ -z "$1" ]; then
  echo "Uso: ./server.sh PORTA"
  exit 1
fi

# Variável para a porta
PORTA="$1"

# Solicita a senha do usuário root e confirmação
while true; do
  echo "Digite a senha para o usuário root:"
  read -s ROOT_PASSWORD
  echo "Confirme a senha para o usuário root:"
  read -s ROOT_PASSWORD_CONFIRM

  # Verifica se as senhas coincidem
  if [ "$ROOT_PASSWORD" == "$ROOT_PASSWORD_CONFIRM" ]; then
    echo -e "\nSenha confirmada com sucesso."
    break
  else
    echo -e "\nAs senhas não coincidem. Tente novamente."
  fi
done

# Atualiza o apt e instala o openssh-server
sudo apt update && sudo apt install -y openssh-server

# Modifica o arquivo de configuração do sshd para usar a porta especificada
sudo sed -i "s/#Port 22/Port $PORTA/" /etc/ssh/sshd_config

# Permite o login root e autenticação por senha
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Define a senha para o usuário root
echo "root:$ROOT_PASSWORD" | sudo chpasswd

# Inicia o serviço SSH
sudo service ssh start

echo "Configuração concluída e serviço SSH iniciado na porta $PORTA."
