#!/bin/bash
# Download SIMATEX
SIMATEX_ZIP="SiMatEx.zip"
echo "Download SiMatEx"
if [ ! -f "$SIMATEX_ZIP" ]; then
    wget http://10.24.125.55/downloads/SiMatEx.zip || error_exit "Erro ao baixar o pacote SiMatEx."
fi