#!/bin/bash

# Verificando se os argumentos foram passados corretamente
if [ $# -ne 2 ]; then
  echo "Uso: $0 <porta> <jar>"
  exit 1
fi

# Atribuindo os argumentos a variáveis
port=$1
jar=$2

# Verificando se o diretório de dados do MySQL existe, se não, inicializa
if [ ! -d "/app/mysql" ]; then
  # Inicializa o banco de dados e captura a saída
  init_output=$(mysqld --initialize --datadir=/app 2>&1)
  # Captura a senha temporária da saída
  temp_password=$(echo "$init_output" | grep -oP 'A temporary password is generated for root@localhost: \K.*')

mysql -u root -p"${temp_password}" -P "${port}" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${jar}'"

# Confirma a alteração da senha
mysqladmin -u root -p"${jar}" -P "${port}" ping
fi

# Inicia o MySQL
mysqld --datadir=/app --user=mysql --port=${port} &

# Aguarda o MySQL iniciar
until mysqladmin ping --silent -P ${port}; do
  sleep 2
done

echo "Senha do usuário root alterada com sucesso!"
echo "Servidor iniciado com sucesso!"
