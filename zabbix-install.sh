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

# Solicitar o nome do host para o agente (opcional)
#read -p "Digite o nome do host para este agente (deixe em branco para usar o nome do host do sistema): " ZABBIX_AGENT_HOSTNAME

# Se o nome do host não for fornecido, use o nome do host do sistema
#if [[ -z "$ZABBIX_AGENT_HOSTNAME" ]]; then
#    ZABBIX_AGENT_HOSTNAME=$(hostname)
#fi


# Instalar o Zabbix Agent
echo "Instalando o Zabbix Agent..."
sudo apt install -y zabbix-agent || error_exit "Erro ao instalar o Zabbix Agent."

# Configurar o Zabbix Agent
echo "Configurando o Zabbix Agent..."
ZABBIX_AGENT_CONF="/etc/zabbix/zabbix_agentd.conf"
sed -i "s/^Server=.*/Server=$ZABBIX_SERVER/" $ZABBIX_AGENT_CONF || error_exit "Erro ao configurar o servidor Zabbix."
sed -i "s/^ServerActive=.*/ServerActive=$ZABBIX_SERVER/" $ZABBIX_AGENT_CONF || error_exit "Erro ao configurar o servidor ativo do Zabbix."
#sed -i "s/^Hostname=.*/Hostname=$ZABBIX_AGENT_HOSTNAME/" $ZABBIX_AGENT_CONF || error_exit "Erro ao configurar o nome do host do Zabbix Agent."

# Reiniciar o serviço do Zabbix Agent para aplicar as mudanças
echo "Reiniciando o serviço do Zabbix Agent..."
systemctl restart zabbix-agent || error_exit "Erro ao reiniciar o serviço do Zabbix Agent."

# Habilitar o serviço do Zabbix Agent para iniciar no boot
echo "Habilitando o serviço do Zabbix Agent para iniciar no boot..."
systemctl enable zabbix-agent || error_exit "Erro ao habilitar o serviço do Zabbix Agent para iniciar no boot."

# Verificar o status do serviço
systemctl status zabbix-agent --no-pager

echo "Instalação e configuração do Zabbix Agent concluídas com sucesso!"
