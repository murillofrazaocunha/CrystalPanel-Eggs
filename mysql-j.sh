#!/bin/bash

# Verificando se os argumentos foram passados corretamente
if [ $# -ne 2 ]; then
  echo "Uso: $0 <porta> <senha_do_mysql>"
  exit 1
fi

# Atribuindo os argumentos a variáveis
port=$1
new_password=$2

# Verificando se o diretório de dados do MySQL existe, se não, inicializa
if [ ! -d "/app/mysql" ]; then
  mkdir /app/config
  # Inicializa o banco de dados e captura a saída
  echo "Inicializando o banco de dados MySQL..."
  init_output=$(mysqld --initialize --datadir=/app --defaults-file=/app/config 2>&1)
  echo "$init_output"
  # Captura a senha temporária da saída
  temp_password=$(echo "$init_output" | grep -oP 'A temporary password is generated for root@localhost: \K.*')
fi

# Inicia o MySQL
echo "Iniciando o MySQL na porta $port..."
mysqld --datadir=/app --user=mysql --port=$port --defaults-file=/app/config &

# Aguarda o MySQL estar pronto para conexões
echo "Aguardando o MySQL ficar disponível..."
until mysqladmin ping --silent -P $port; do
  sleep 2
done

# Se a senha temporária foi gerada, altera a senha
if [ -n "$temp_password" ]; then
  echo "A senha temporária é: $temp_password"
  # Faz login no MySQL com a senha temporária
  echo "Alterando a senha do usuário root..."
  mysql -u root -p"$temp_password" -P "$port" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$new_password'"
  echo "Senha do usuário root alterada com sucesso!"
fi

mysql -u root -p $jar -P $port
