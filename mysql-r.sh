#!/bin/bash

# Verificando se os argumentos foram passados corretamente
if [ $# -ne 2 ]; then
  echo "Uso: $0 <porta> <senha_do_mysql>"
  exit 1
fi

# Atribuindo os argumentos a variáveis
port=$1
new_password=$2

# Verificando se o diretório de dados do MySQL existe, se não, inicial#!/bin/bash

# Verificando se os argumentos foram passados corretamente
if [ $# -ne 3 ]; then
  echo "Uso: $0 <porta> <senha_do_mysql>"
  exit 1
fi

# Atribuindo os argumentos a variáveis
port=$1
new_password=$2
my_cnf_path="/app/config/my.cnf"

# Verificando se o diretório de dados do MySQL existe, se não, inicializa
if [ ! -d "/app/mysql" ]; then
  # Inicializa o banco de dados e captura a saída
  echo "Inicializando o banco de dados MySQL..."
  init_output=$(mysqld --initialize --datadir=/app 2>&1)
  echo "$init_output"
  # Captura a senha temporária da saída
  temp_password=$(echo "$init_output" | grep -oP 'A temporary password is generated for root@localhost: \K.*')
  
  if [ -z "$temp_password" ]; then
    echo "Erro: Não foi possível obter a senha temporária."
    exit 1
  fi
fi

# Verifica se o diretório /app/config existe, se não, cria
if [ ! -d "/app/config" ]; then
  echo "Criando o diretório /app/config..."
  mkdir -p /app/config
fi

# Verifica se o arquivo my.cnf existe, se não, cria um arquivo de configuração padrão
if [ ! -f "$my_cnf_path" ]; then
  echo "Arquivo my.cnf não encontrado. Criando arquivo de configuração padrão em $my_cnf_path..."
  cat > "$my_cnf_path" <<EOF
[mysqld]
datadir=/app/mysql
socket=/app/mysql/mysql.sock
user=mysql
bind-address=0.0.0.0
port=$port
EOF
  echo "Arquivo my.cnf criado com sucesso!"
fi

# Inicia o MySQL com o arquivo de configuração customizado
echo "Iniciando o MySQL na porta $port com o arquivo de configuração $my_cnf_path..."
mysqld --datadir=/app --user=mysql --port=$port --defaults-file="$my_cnf_path" &

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
  mysql -u root -p"$temp_password" -P "$port" --defaults-file="$my_cnf_path" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$new_password'"

  # Confirma a alteração da senha
  mysqladmin -u root -p"$new_password" -P "$port" --defaults-file="$my_cnf_path" ping

  echo "Senha do usuário root alterada com sucesso!"
else
  echo "Erro: Nenhuma senha temporária foi gerada."
  exit 1
fi
iza
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
