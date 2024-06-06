#!/bin/bash

# COLOCAR ALGO PARA FAZER DOWNLOAD REMOTAMENTE 

# Verifique se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute como root"
  exit
fi
echo "Instalando ICED TEA"
sudo apt install icedtea-netx

echo "Instalando OpenJFX"
sudo apt isntall OpenJFX -y

# Descompacte os arquivos
echo "Descompactando jre-8u202-linux-x64.tar.gz..."
tar zxvf jre-8u202-linux-x64.tar.gz

echo "Descompactando jdk-8u202-linux-x64.tar.gz..."
tar zxvf jdk-8u202-linux-x64.tar.gz

# Crie a pasta /usr/local/java se não existir
JAVA_DIR="/usr/local/java"
if [ ! -d "$JAVA_DIR" ]; then
  echo "Criando diretório $JAVA_DIR..."
  mkdir $JAVA_DIR
fi

# Copie os arquivos descompactados para /usr/local/java
echo "Copiando arquivos para $JAVA_DIR..."
cp -r jre1.8.0_202/ $JAVA_DIR/
cp -r jdk1.8.0_202/ $JAVA_DIR/

# Adicione as variáveis de ambiente ao /etc/bash.bashrc
echo "Adicionando variáveis de ambiente ao /etc/bash.bashrc..."
cat <<EOL >> /etc/bash.bashrc

# Java Environment Variables
export JAVA_HOME=$JAVA_DIR/jdk1.8.0_202
export JRE_HOME=$JAVA_DIR/jre1.8.0_202
export PATH=\$PATH:\$JAVA_HOME/bin:\$JRE_HOME/bin
EOL

# Informe o Ubuntu onde o JDK e o JRE estão instalados
echo "Configurando alternativas de Java..."
update-alternatives --install "/usr/bin/java" "java" "$JAVA_DIR/jre1.8.0_202/bin/java" 1
update-alternatives --install "/usr/bin/javac" "javac" "$JAVA_DIR/jdk1.8.0_202/bin/javac" 1
update-alternatives --install "/usr/bin/javaws" "javaws" "$JAVA_DIR/jre1.8.0_202/bin/javaws" 1

# Defina o Java instalado como padrão
echo "Definindo o Java instalado como padrão..."
update-alternatives --set java $JAVA_DIR/jre1.8.0_202/bin/java
update-alternatives --set javac $JAVA_DIR/jdk1.8.0_202/bin/javac
update-alternatives --set javaws $JAVA_DIR/jre1.8.0_202/bin/javaws

# Reinicie a máquina (opcional)
echo "Reiniciando a máquina para aplicar as alterações..."
# reboot

# Verifique a versão do Java
echo "Verifique a versão do Java instalada..."
java -version

echo "Instalação e configuração do Java concluídas com sucesso."
