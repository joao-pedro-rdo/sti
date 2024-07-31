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
echo  "Configurando o fuso horário..."
timedatectl set-timezone America/Sao_Paulo

echo "Atualizando repositorio e Instalando e configurando o NTP..."
apt-get update
apt-get install ntp ntpdate -y

echo "Configurando o NTP..."
service ntp stop
ntpdate a.ntp.br
service ntp start
