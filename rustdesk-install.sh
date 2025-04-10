#!/bin/bash
# Definir o ambiente não interativo para evitar prompts (tzdata, etc)
export DEBIAN_FRONTEND=noninteractive

# Função para exibir mensagens de erro e sair
function error_exit {
    echo "$1" 1>&2
    exit 1
}

# Endereço fixo do proxy
PROXY_URL="10.25.62.52:2000"
USE_PROXY=false

# Processamento de argumentos com getopts:
# -p: ativa o uso do proxy
# -u: proxy username
# -w: proxy password
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

# Se o proxy foi solicitado, verificar se username e password foram informados
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

# Atualizar a lista de pacotes
apt update || error_exit "Falha ao atualizar a lista de pacotes."

# Corrigir pacotes quebrados (caso existam) antes de qualquer instalação
apt --fix-broken install -y || error_exit "Falha ao corrigir dependências com apt --fix-broken install."

# Instalar wget (caso não esteja instalado)
apt install wget -y || error_exit "Erro ao instalar o wget."

# Instalar as dependências necessárias para o Rustdesk:
# Para a dependência do libasound2 escolhemos explicitamente o pacote libasound2t64
apt install -y \
  libgtk-3-0 \
  libxcb-randr0 \
  libxfixes3 \
  libxcb-shape0 \
  libxcb-xfixes0 \
  libasound2t64 \
  curl \
  libva2 \
  libva-drm2 \
  libva-x11-2 \
  libgstreamer-plugins-base1.0-0 \
  gstreamer1.0-pipewire \
  libxdo3 || error_exit "Erro ao instalar as dependências necessárias."

# Baixar o pacote do Rustdesk (salvando com o nome correto)
wget https://github.com/rustdesk/rustdesk/releases/download/1.3.8/rustdesk-1.3.8-x86_64.deb -O rustdesk.deb || error_exit "Erro ao baixar o pacote do Rustdesk."

# Instalar o pacote do Rustdesk
dpkg -i rustdesk.deb || true

# Corrigir dependências remanescentes, se houver
apt --fix-broken install -y || error_exit "Falha ao corrigir dependências após a instalação do pacote."

echo "Instalação do Rustdesk concluída com sucesso."
