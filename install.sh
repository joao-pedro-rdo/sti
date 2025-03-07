#!/bin/bash

# Lista de pacotes a serem instalados
PACKAGES=(
    openssh-server
    net-tools
    q4wine
    libreoffice
    wget
    curl
)


# Função para exibir mensagens de erro e sair
function error_exit {
    echo "$1" 1>&2
    exit 1
}

# Verificar se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
    error_exit "Este script precisa ser executado como root. Use sudo."
fi

# Processamento de argumentos para o proxy:
# -p: ativa o uso do proxy
# -u: usuário do proxy
# -w: senha do proxy
USE_PROXY=false
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
shift $((OPTIND - 1))

# Se o proxy for solicitado, verificar as credenciais e configurar as variáveis de ambiente
if $USE_PROXY; then
    if [ -z "$PROXY_USER" ] || [ -z "$PROXY_PASSWORD" ]; then
         error_exit "Ao usar o proxy, é necessário informar o usuário (-u) e a senha (-w)."
    fi
    PROXY_URL="10.25.62.52:2000"
    echo "Configurando o proxy com o usuário informado..."
    export http_proxy="http://$PROXY_USER:$PROXY_PASSWORD@$PROXY_URL"
    export https_proxy="http://$PROXY_USER:$PROXY_PASSWORD@$PROXY_URL"
    # export ftp_proxy="http://$PROXY_USER:$PROXY_PASSWORD@$PROXY_URL"
    # export no_proxy="localhost,127.0.0.1"
fi

# Atualizar repositórios e pacotes
echo "Atualizando repositórios e pacotes..."
apt-get update || error_exit "Erro ao atualizar os repositórios."

# Instalar os pacotes
echo "Instalando pacotes: ${PACKAGES[@]}"
for package in "${PACKAGES[@]}"; do
    apt-get install -y "$package" || error_exit "Erro ao instalar o pacote $package."
done
echo "Todos os pacotes foram instalados com sucesso!"

# Verificar a instalação dos pacotes
for package in "${PACKAGES[@]}"; do
    dpkg -l | grep -i "$package" && echo "$package instalado com sucesso" || echo "Erro ao instalar $package"
done

# Verificar e executar os scripts adicionais

# Executar o script vpn-install.sh
if [ -f "vpn-install.sh" ]; then
    echo "Executando o script vpn-install..."
    sudo bash vpn-install.sh  || error_exit "Erro ao executar o script vpn-install."
else
    error_exit "Arquivo vpn-install não encontrado."
fi

# Executar o script zabbix-install.sh
if [ -f "zabbix-install.sh" ]; then
    echo "Executando o script zabbix-install.sh..."
    sudo bash zabbix-install.sh -p -u $PROXY_USER -w $PROXY_PASSWORD || error_exit "Erro ao executar o script zabbix-install.sh."
else
    error_exit "Arquivo zabbix-install.sh não encontrado."
fi

# Executar o script rustdesk-install.sh
if [ -f "rustdesk-install.sh" ]; then
    echo "Executando o script rustdesk-install.sh..."
    sudo bash rustdesk-install.sh -p -u $PROXY_USER -w $PROXY_PASSWORD || error_exit "Erro ao executar o script rustdesk-install.sh."
else
    error_exit "Arquivo rustdesk-install.sh não encontrado."
fi


# Executar o script vpn-install.sh
if [ -f "antivirus.sh" ]; then
    echo "Executando o script antivirus..."
    sudo bash antivirus.sh  || error_exit "Erro ao executar o script antivirus."
else
    error_exit "Arquivo antivirus não encontrado."
fi


# Executar o script glpi-install.sh
if [ -f "glpi-install.sh" ]; then
    echo "Executando o script glpi-install.sh..."
    sudo bash glpi-install.sh || error_exit "Erro ao executar o script glpi-install.sh."
else
    error_exit "Arquivo glpi-install.sh não encontrado."
fi

echo "Instalação e configuração concluídas com sucesso!"
