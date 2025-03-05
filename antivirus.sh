#!/bin/bash

# Script para instalar o Antivirus Corporativo em estações Linux 64 bits

# URL para download do instalador
URL="http://intranet.1cta.eb.mil.br/AV_Linux.zip"
ZIP_FILE="AV_Linux.zip"
INSTALL_DIR="/opt/kaspersky"

# Verifica se o script está sendo executado como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script deve ser executado como root." 
   exit 1
fi

# Baixar o instalador
if ! wget -O "$ZIP_FILE" "$URL"; then
    echo "Erro ao baixar o arquivo do URL: $URL"
    exit 1
fi

echo "Download concluído."

# Descompactar o arquivo
if ! unzip -o "$ZIP_FILE"; then
    echo "Erro ao descompactar o arquivo $ZIP_FILE."
    exit 1
fi

echo "Arquivo descompactado com sucesso."

# Tornar os scripts executáveis
chmod +x klnagent64_13.2.2-1263_amd64.sh kesl-gui_11.3.0-7441.sh

# Instalar o Agente de Rede
echo "Instalando o Agente de Rede..."
if ! ./klnagent64_13.2.2-1263_amd64.sh; then
    echo "Erro durante a instalação do Agente de Rede."
    exit 1
fi

echo "Agente de Rede instalado com sucesso."

# Instalar o Antivirus
echo "Instalando o Antivirus..."
if ! ./kesl-gui_11.3.0-7441.sh; then
    echo "Erro durante a instalação do Antivirus."
    exit 1
fi

echo "Antivirus instalado com sucesso."

# Verificar a conexão com o servidor de Antivirus
echo "Verificando a conexão com o servidor de Antivirus..."
if ! /opt/kaspersky/klnagent64/bin/klnagchk; then
    echo "Erro na verificação de conexão com o servidor de Antivirus."
    exit 1
fi

echo "Conexão com o servidor de Antivirus verificada com sucesso."

echo "Instalação concluída."