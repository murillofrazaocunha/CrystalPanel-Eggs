#!/bin/bash

# Verificando se os argumentos foram passados corretamente
if [ $# -ne 2 ]; then
  echo "Uso: $0 <porta> <jar>"
  exit 1
fi

# Atribuindo os argumentos a variáveis
port=$1
jar=$2

if [ ! -d "/app/mysql" ]; then
  mysqld --initialize --datadir=/app
fi

mysqld --datadir=/app --user=mysql --port=${port} &

until mysqladmin ping --silent -P ${port}; do
  sleep 2
done

mysqladmin -u root password "${jar}" -P "${port}"
