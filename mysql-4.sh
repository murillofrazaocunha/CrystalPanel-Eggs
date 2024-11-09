#!/bin/bash

# Verificando se os argumentos foram passados corretamente
if [ $# -ne 2 ]; then
  echo "Uso: $0 <porta> <senha_do_mysql>"
  exit 1
fi

# Atribuindo os argumentos a variáveis
port=$1
new_password=$2
my_cnf_path="/app/config/my.cnf"
data_dir="/app/mysql"

# Verificando se o diretório de dados do MySQL existe, se não, inicializa
if [ ! -d "$data_dir" ]; then
  echo "Inicializando o banco de dados MySQL..."
  init_output=$(mysqld --initialize --datadir="$data_dir" 2>&1)
  echo "$init_output"

  # Captura a senha temporária da saída
  temp_password=$(echo "$init_output" | grep -oP 'A temporary password is generated for root@localhost: \K.*')
  if [ -z "$temp_password" ]; then
    echo "Erro: Não foi possível obter a senha temporária."
    exit 1
  fi
else
  echo "Diretório de dados do MySQL já existe. Pulando a inicialização."
fi

# Verifica se o diretório /app/config existe, se não, cria
mkdir -p "/app/config"
chown -R mysql:mysql /app/mysql
chown -R mysql:mysql /app/config
# Verifica se o arquivo my.cnf existe, se não, cria um arquivo de configuração padrão
if [ ! -f "$my_cnf_path" ]; then
  echo "Arquivo my.cnf não encontrado. Criando arquivo de configuração padrão em $my_cnf_path..."
  cat > "$my_cnf_path" <<EOF
[mysqld]
datadir=$data_dir
socket=/var/lib/mysql/mysql.sock
user=mysql
bind-address=0.0.0.0
port=$port
EOF
  echo "Arquivo my.cnf criado com sucesso!"
fi

# Inicia o MySQL com o arquivo de configuração customizado
echo "Iniciando o MySQL na porta $port com o arquivo de configuração $my_cnf_path..."
mysqld --defaults-file="$my_cnf_path" --datadir="$data_dir" --user=mysql --port="$port" &

# Se a senha temporária foi gerada, altera a senha
if [ -n "$temp_password" ]; then
echo "Aguardando o MySQL ficar disponível..."
until mysqladmin ping -P "$port"; do
  sleep 2
done
  echo "A senha temporária é: $temp_password"
  echo "Alterando a senha do usuário root..."

mysql --connect-expired-password -u root -p"$temp_password" -P "$port" -e \
"GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$new_password' WITH GRANT OPTION; FLUSH PRIVILEGES;"

mysql --connect-expired-password -u root -p"$temp_password" -P "$port" -e \
"ALTER USER 'root'@'localhost' IDENTIFIED BY '$new_password';"

  
  # Verifica se a nova senha funciona
  if mysqladmin -u root -p"$new_password" -P "$port" ping > /dev/null 2>&1; then
    echo "Senha do usuário root alterada com sucesso!"
  else
    echo "Erro ao confirmar a alteração de senha. Verifique as configurações."
    exit 1
  fi
fi

sleep 5
