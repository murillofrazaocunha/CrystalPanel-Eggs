#!/bin/bash

# Verifica se a porta foi fornecida como argumento
if [ -z "$1" ]; then
  echo "Uso: ./server.sh PORTA"
  exit 1
fi

PORTA="$1"

# Cria o segundo script para configuração do SSH
cat <<EOF > /tmp/configura_ssh.sh
#!/bin/bash
# Modifica o arquivo de configuração do sshd para usar a porta especificada
sed -i "s/#Port 22/Port $PORTA/" /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Define a senha para o usuário root
echo "root:12345678" | chpasswd

# Inicia o serviço SSH
service ssh restart

# Exibe as mensagens de status
echo "Configuração concluída e serviço SSH iniciado na porta $PORTA." | tee /dev/stderr
echo "Use ssh root@IP -p $PORTA com a senha 12345678 para acessar o SSH" | tee /dev/stderr
EOF

# Torna o script executável
chmod +x /tmp/configura_ssh.sh

# Instala o SSH e chama o script de configuração em segundo plano
apt update
apt install -y openssh-server && /tmp/configura_ssh.sh &
