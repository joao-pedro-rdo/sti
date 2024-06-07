#!/bin/bash

#instalando dependencia de entrada de usuario
sudo apt-get install expect -y

# Definindo a URL do agente GLPI. Certifique-se de verificar a versão mais recente no site oficial.
GLPI_AGENT_URL="https://github.com/glpi-project/glpi-agent/releases/download/1.9/glpi-agent-1.9-linux-installer.pl"


# Diretório temporário para download
TEMP_DIR="/tmp/glpi-agent-install"
# Configuração básica do GLPI Agent
GLPI_SERVER_URL="http://10.24.125.11/glpi/front/inventory.php"

# Editar o arquivo de configuração do GLPI Agent
CONFIG_FILE="/etc/glpi-agent/glpi-agent.conf"
# Criar o diretório temporário
mkdir -p $TEMP_DIR
cd $TEMP_DIR

# Baixando o instalador do agente GLPI
echo "Baixando o instalador do GLPI Agent..."
wget $GLPI_AGENT_URL -O glpi-agent-installer.pl

# Verificando se o download foi bem-sucedido
if [ $? -ne 0 ]; then
    echo "Erro ao baixar o instalador do GLPI Agent."
    exit 1
fi

# Tornando o instalador executável
chmod +x glpi-agent-installer.pl

# Executando o instalador
echo "Instalando o GLPI Agent..."
sudo perl glpi-agent-installer.pl

#Entrada de usuario automatizado
expect <<EOF
spawn ./glpi-agent-installer.pl
expect "Enter the URL of the GLPI server"
send "$GLPI_SERVER_URL\r"
expect eof
EOF
# Verificando se a instalação foi bem-sucedida
if [ $? -ne 0 ]; then
    echo "Erro durante a instalação do GLPI Agent."
    exit 1
fi

# Limpar o diretório temporário
rm -rf $TEMP_DIR

# Exibindo mensagem de sucesso
echo "GLPI Agent instalado com sucesso!"

#echo "Configurando o GLPI Agent para se comunicar com o servidor GLPI em $GLPI_SERVER_URL..."
#if [ -f $CONFIG_FILE ]; then
#    sudo sed -i "s|^# server=.*|server=$GLPI_SERVER_URL|" $CONFIG_FILE
#    echo "Configuração do servidor GLPI atualizada com sucesso."
#else
#    echo "Arquivo de configuração $CONFIG_FILE não encontrado."
#    exit 1
#fi

# Reiniciar o serviço do GLPI Agent para aplicar as mudanças
#echo "Reiniciando o serviço do GLPI Agent..."
#sudo systemctl restart glpi-agent

# Verificando se o serviço está ativo
#sudo systemctl status glpi-agent --no-pager

echo "Configuração concluída com sucesso!"

echo "Forçando inventario"
sudo glpi-agent

ehco "Fim da instalação"

