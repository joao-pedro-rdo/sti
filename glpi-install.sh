#!/bin/bash

#instalando dependencia de entrada de usuario
sudo apt-get install expect -y

# Definindo a URL do agente GLPI. Certifique-se de verificar a versÃ£o mais recente no site oficial.
GLPI_AGENT_URL="https://github.com/glpi-project/glpi-agent/releases/download/1.9/glpi-agent-1.9-linux-installer.pl"


# DiretÃ³rio temporÃ¡rio para download
TEMP_DIR="/tmp/glpi-agent-install"
# ConfiguraÃ§Ã£o bÃ¡sica do GLPI Agent
GLPI_SERVER_URL="http://<SEU IP>/glpi/front/inventory.php"

# Editar o arquivo de configuraÃ§Ã£o do GLPI Agent
CONFIG_FILE="/etc/glpi-agent/glpi-agent.conf"
# Criar o diretÃ³rio temporÃ¡rio
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

# Tornando o instalador executÃ¡vel
chmod +x glpi-agent-installer.pl

# Executando o instalador
echo "Instalando o GLPI Agent..."
#sudo perl glpi-agent-installer.pl

#Entrada de usuario automatizado
#talvez precise mudar para perl o ./
expect <<EOF
spawn ./glpi-agent-installer.pl
expect "Provide an url to configure GLPI server:" 
send "$GLPI_SERVER_URL\r"
expect "Provide a path to configure local inventory run or leave it empty:"
send "/tmp\r"
expect eof
EOF
# Verificando se a instalaÃ§Ã£o foi bem-sucedida
if [ $? -ne 0 ]; then
    echo "Erro durante a instalaÃ§Ã£o do GLPI Agent."
    exit 1
fi

# Limpar o diretÃ³rio temporÃ¡rio
rm -rf $TEMP_DIR

# Exibindo mensagem de sucesso
echo "GLPI Agent instalado com sucesso!"

#echo "Configurando o GLPI Agent para se comunicar com o servidor GLPI em $GLPI_SERVER_URL..."
#if [ -f $CONFIG_FILE ]; then
#    sudo sed -i "s|^# server=.*|server=$GLPI_SERVER_URL|" $CONFIG_FILE
#    echo "ConfiguraÃ§Ã£o do servidor GLPI atualizada com sucesso."
#else
#    echo "Arquivo de configuraÃ§Ã£o $CONFIG_FILE nÃ£o encontrado."
#    exit 1
#fi

# Reiniciar o serviÃ§o do GLPI Agent para aplicar as mudanÃ§as
#echo "Reiniciando o serviÃ§o do GLPI Agent..."
#sudo systemctl restart glpi-agent

# Verificando se o serviÃ§o estÃ¡ ativo
#sudo systemctl status glpi-agent --no-pager

echo "ConfiguraÃ§Ã£o concluÃ­da com sucesso!"

echo "ForÃ§ando inventario"
sudo glpi-agent

echo "Fim da instalaÃ§Ã£o"
