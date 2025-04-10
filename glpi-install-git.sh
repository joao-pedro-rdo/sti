#!/bin/bash
# Definir o ambiente não interativo para evitar prompts (ex.: tzdata)
export DEBIAN_FRONTEND=noninteractive

# Função para exibir mensagens de erro e sair
function error_exit {
    echo "$1" 1>&2
    exit 1
}

# Endereço fixo do proxy (caso seja utilizado)
PROXY_URL="10.25.62.52:2000"
USE_PROXY=false

# Processamento de argumentos com getopts:
#  -p: ativa o uso do proxy
#  -u: proxy username
#  -w: proxy password
while getopts "pu:w:" opt; do
    case $opt in
        p)
            USE_PROXY=true
            ;;
        u)
            PROXY_USER="$OPTARG"
            ;;
        w)
            PROXY_PASSWORD="$OPTARG"
            ;;
        \?)
            error_exit "Opção inválida: -$OPTARG"
            ;;
        :)
            error_exit "A opção -$OPTARG requer um argumento."
            ;;
    esac
done

# Se o proxy foi solicitado, verificar se o username e password foram informados
if $USE_PROXY; then
    if [ -z "$PROXY_USER" ] || [ -z "$PROXY_PASSWORD" ]; then
         error_exit "Ao usar o proxy, é necessário informar o usuário (-u) e a senha (-w)."
    fi
    echo "Configurando o proxy com o usuário informado..."
    export http_proxy="http://$PROXY_USER:$PROXY_PASSWORD@$PROXY_URL"
    export https_proxy="http://$PROXY_USER:$PROXY_PASSWORD@$PROXY_URL"
fi

# Avançar os parâmetros posicionais após o getopts
shift $((OPTIND - 1))

# Verificar se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
    error_exit "Este script precisa ser executado como root."
fi

# Atualizar os repositórios e instalar pacotes necessários para o GLPI Agent
echo "Atualizando repositórios e instalando pacotes necessários..."
apt-get update || { echo "Erro ao atualizar repositórios."; exit 1; }
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    wget \
    expect \
    perl || { echo "Erro ao instalar pacotes necessários."; exit 1; }

# Definindo a URL do agente GLPI na versão 1.13
GLPI_AGENT_URL="https://github.com/glpi-project/glpi-agent/releases/download/1.13/glpi-agent-1.13-linux-installer.pl"

# Diretório temporário para download do instalador
TEMP_DIR="/tmp/glpi-agent-install"
# URL do servidor GLPI para configuração do agente (substitua conforme necessário)
GLPI_SERVER_URL="http://10.24.125.11/glpi/front/inventory.php"

# Arquivo de configuração padrão do GLPI Agent (pode ser editado se necessário)
CONFIG_FILE="/etc/glpi-agent/glpi-agent.conf"

# Criar e acessar o diretório temporário
mkdir -p "$TEMP_DIR" || { echo "Erro ao criar o diretório temporário."; exit 1; }
cd "$TEMP_DIR" || { echo "Erro ao acessar o diretório temporário."; exit 1; }

# Baixando o instalador do GLPI Agent
echo "Baixando o instalador do GLPI Agent versão 1.13..."
wget "$GLPI_AGENT_URL" -O glpi-agent-installer.pl || { echo "Erro ao baixar o instalador do GLPI Agent."; exit 1; }

# Tornar o instalador executável
chmod +x glpi-agent-installer.pl

echo "Instalando o GLPI Agent com automação..."
# Automatizando a instalação com 'expect'
expect <<EOF
spawn ./glpi-agent-installer.pl
expect "Provide an url to configure GLPI server:" 
send "$GLPI_SERVER_URL\r"
expect "Provide a path to configure local inventory run or leave it empty:" 
send "/tmp\r"
# Nova etapa de TAG: pular enviando uma linha em branco
expect "Enter your tag:" { }
send "\r"
expect eof
EOF

# Verificar se a instalação ocorreu sem erros
if [ $? -ne 0 ]; then
    echo "Erro durante a instalação do GLPI Agent."
    exit 1
fi

# Limpar o diretório temporário de instalação
rm -rf "$TEMP_DIR"

echo "GLPI Agent instalado com sucesso!"

# Verificar e corrigir a localização do arquivo de configuração
if [ ! -f /etc/glpi-agent/agent.cfg ]; then
    if [ -f "$CONFIG_FILE" ]; then
        ln -s "$CONFIG_FILE" /etc/glpi-agent/agent.cfg
        echo "Criado link simbólico: /etc/glpi-agent/agent.cfg -> $CONFIG_FILE"
    else
        echo "Arquivo de configuração não encontrado em $CONFIG_FILE."
        exit 1
    fi
fi

# Forçar o inventário
echo "Forçando inventário..."
glpi-agent

echo "Fim da instalação."
