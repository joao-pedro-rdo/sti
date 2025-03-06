#!/bin/bash

# Função simples para exibir erro e sair
error_exit() {
    echo "$1"
    exit 1
}

URL_VPN="http://10.24.125.55/downloads/vpn-linux.tar.gz"
VPN_TAR="vpn-linux.tar.gz"

echo "Instalando VPN..."

# 1. BAIXA O PACOTE SE NECESSÁRIO
if [ ! -f "$VPN_TAR" ]; then
    wget "$URL_VPN" -O "$VPN_TAR" || error_exit "Erro ao baixar o pacote VPN."
fi

# 2. DESCOMPACTA
tar zxvf "$VPN_TAR" || error_exit "Erro ao descompactar o pacote VPN."

# 3. EXECUTA O INSTALADOR USANDO EXPECT
if [ -f "./anyconnect-linux64-4.9.01095/vpn/vpn_install.sh" ]; then
    # Usamos o bloco "expect" inline
    /usr/bin/expect <<EOF
spawn ./anyconnect-linux64-4.9.01095/vpn/vpn_install.sh
# Ajuste a linha abaixo para o texto EXATO que aparece no instalador
# Se houver caracteres especiais como [?] é preciso escapá-los ou usar -re
expect {
    -re "Do you accept the terms.*\\[y/n\\]" {
        send "y\r"
    }
}
expect eof
EOF
else
    error_exit "Script de instalação da VPN não encontrado."
fi

echo "Instalação concluída!"
