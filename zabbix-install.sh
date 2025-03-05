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

# Definir o endereço IP do servidor Zabbix
ZABBIX_SERVER="10.24.125.2"
ZABBIX_AGENT_CONF="/etc/zabbix/zabbix_agent2.conf"

# Verificar se o parâmetro de hostname foi passado
if [ -n "$1" ]; then
    ZABBIX_AGENT_HOSTNAME="$1"
else
    # Caso não tenha sido passado, perguntar ao usuário com timeout
    echo "Digite o nome do host para este agente (pressione ENTER para deixar em branco ou aguarde 10 segundos para usar o hostname do sistema): "
    
    # Definir o tempo máximo para a entrada (10 segundos)
    read -t 10 ZABBIX_AGENT_HOSTNAME
    
    # Se nada for digitado, usar o nome do host do sistema
    if [ -z "$ZABBIX_AGENT_HOSTNAME" ]; then
        ZABBIX_AGENT_HOSTNAME=$(hostname)
    fi
fi

echo "O nome do host configurado será: $ZABBIX_AGENT_HOSTNAME"

# Verificar se o wget está instalado
if ! command -v wget &> /dev/null; then
    error_exit "O comando 'wget' não foi encontrado. Instale o wget para continuar."
fi

# Verificar se o dpkg está instalado
if ! command -v dpkg &> /dev/null; then
    error_exit "O comando 'dpkg' não foi encontrado. Instale o dpkg para continuar."
fi

echo "Baixando repositório do Zabbix..."
wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb || error_exit "Falha ao baixar o repositório do Zabbix."

echo "Instalando o pacote do repositório Zabbix..."
dpkg -i zabbix-release_latest_7.2+ubuntu24.04_all.deb || error_exit "Erro ao instalar o pacote do repositório Zabbix."

echo "Atualizando repositórios..."
apt update || error_exit "Erro ao atualizar os repositórios."

# Instalar o Zabbix Agent
echo "Instalando o Zabbix Agent..."
apt install -y zabbix-agent2 || error_exit "Erro ao instalar o Zabbix Agent."

# Verificar se o arquivo de configuração do agente existe
if [ ! -f "$ZABBIX_AGENT_CONF" ]; then
    error_exit "Arquivo de configuração do Zabbix Agent não encontrado em $ZABBIX_AGENT_CONF."
fi

# Configurar o Zabbix Agent
echo "Configurando o Zabbix Agent..."
sed -i "s/^Server=.*/Server=$ZABBIX_SERVER/" $ZABBIX_AGENT_CONF || error_exit "Erro ao configurar o servidor Zabbix."
sed -i "s/^ServerActive=.*/ServerActive=$ZABBIX_SERVER/" $ZABBIX_AGENT_CONF || error_exit "Erro ao configurar o servidor ativo do Zabbix."
sed -i "s/^Hostname=.*/Hostname=$ZABBIX_AGENT_HOSTNAME/" $ZABBIX_AGENT_CONF || error_exit "Erro ao configurar o nome do host do Zabbix Agent."

# Reiniciar o serviço do Zabbix Agent para aplicar as mudanças
echo "Reiniciando o serviço do Zabbix Agent..."
systemctl restart zabbix-agent2.service || error_exit "Erro ao reiniciar o serviço do Zabbix Agent."

# Habilitar o serviço do Zabbix Agent para iniciar no boot
echo "Habilitando o serviço do Zabbix Agent para iniciar no boot..."
systemctl enable zabbix-agent2.service || error_exit "Erro ao habilitar o serviço do Zabbix Agent para iniciar no boot."

# Verificar o status do serviço
systemctl status zabbix-agent2.service --no-pager

echo "Instalação e configuração do Zabbix Agent concluídas com sucesso!"
