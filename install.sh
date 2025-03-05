#!/bin/bash

# Função para exibir mensagens de erro e sair
function error_exit {
    echo "$1" 1>&2
    exit 1
}

# Verificar se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
    error_exit "Este script precisa ser executado como root. Use sudo."
fi

# Função para configurar o proxy
function configure_proxy {
    PROXY_URL="10.25.62.52:2000"
    read -p "Digite o nome de usuário do proxy: " PROXY_USER
    read -sp "Digite a senha do proxy: " PROXY_PASSWORD
    echo

    # Exportar as variáveis de ambiente do proxy
    export http_proxy="http://$PROXY_USER:$PROXY_PASSWORD@$PROXY_URL"
    export https_proxy="http://$PROXY_USER:$PROXY_PASSWORD@$PROXY_URL"
    #export ftp_proxy="http://$PROXY_USER:$PROXY_PASSWORD@$PROXY_URL"
    #export no_proxy="localhost,127.0.0.1"
}

# Verificar se o usuário deseja usar um proxy
read -p "Deseja configurar um proxy para as atualizações? (y/n): " USE_PROXY
if [[ "$USE_PROXY" == "y" || "$USE_PROXY" == "Y" ]]; then
    configure_proxy
fi

# Atualizar repositórios e pacotes
echo "Atualizando repositórios e pacotes..."
apt-get update || error_exit "Erro ao atualizar os repositórios."
apt-get upgrade -y || error_exit "Erro ao atualizar os pacotes."

# Lista de pacotes a serem instalados
PACKAGES=(
    openssh-server
    net-tools
    q4wine
    libreoffice
)

# Instalar os pacotes
echo "Instalando pacotes: ${PACKAGES[@]}"
for package in "${PACKAGES[@]}"; do
    apt-get install -y $package || error_exit "Erro ao instalar o pacote $package."
done

# Exibir mensagem de sucesso
echo "Todos os pacotes foram instalados com sucesso!"

# Verificar a instalação dos pacotes
for package in "${PACKAGES[@]}"; do
    dpkg -l | grep -i $package && echo "$package instalado com sucesso" || echo "Erro ao instalar $package"
done



# DOWNLOAD VPN
echo "Instalando VPN"
wget http://10.24.125.55/downloads/vpn-linux.tar.gz -O vpn.tar.gz
tar zxvf vpn.tar.gz
sudo ./anyconnect-linux64-4.9.01095/vpn/vpn_install.sh

# Dowload SIMATEX
echo "Dowload Simatex"
wget http://10.24.125.55/downloads/SiMatEx.zip



#Deve integrar os demais  scripts

# Executar o script zabbix-install.sh com sudo
echo "Executando o script zabbix-install.sh..."
sudo bash zabbix-install.sh || error_exit "Erro ao executar o script zabbix-install.sh."

# Executar o script glpi-install.sh com sudo
echo "Executando o script glpi-install.sh..."
sudo bash glpi-install.sh || error_exit "Erro ao executar o script glpi-install.sh."

echo "Instalação e configuração concluídas com sucesso!"
