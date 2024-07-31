>Lembrando que antes de usar o script de instalação do SIAFI (Tela Preta no Linux), você deve fazer o download dos seguintes arquivos e colocá-los no mesmo diretório que o script:

- [jdk-8u202-linux-x64.tar](https://bit.ly/3RvHdNz)
- [jre-8u202-linux-x64.tar](https://bit.ly/3xmHkUX)

## Introdução

Este repositório tem como objetivo disponibilizar scripts para auxiliar os profissionais da seção de informática na configuração rápida de ambientes de trabalho Linux, sem a necessidade de um conhecimento prévio avançado em Linux. Os scripts automatizam instalações e configurações, garantindo que nenhum passo seja esquecido e que todos os computadores sejam configurados de forma uniforme.

## Objetivo

O objetivo principal deste projeto é:

- Facilitar a configuração de ambientes de trabalho Linux para os auxiliares da seção de informática.
- Automatizar instalações e configurações para economizar tempo e evitar erros humanos.
- Garantir uniformidade na configuração de todos os computadores.

## Como utilizar

Para utilizar os scripts disponíveis neste repositório, siga os passos abaixo:

1. Clone este repositório para o computador que deseja configurar.
2. Execute os scripts conforme as instruções fornecidas em cada um deles.

### Permissões de Execução

Antes de executar os scripts contidos neste repositório, é necessário garantir que eles tenham permissão de execução. Você pode conceder permissão de execução utilizando o comando `chmod +x`. Por exemplo:

```bash
chmod +x install.sh glpi-install.sh zabbix-install.sh java-install.sh
```
### Uso do install.sh

O script `install.sh` é o ponto de entrada para configurar os ambientes de trabalho. Ele automatiza as instalações e configurações necessárias, chamando automaticamente os scripts `zabbix-install.sh` e `glpi-install.sh`.

```bash
sudo bash install.sh
```

Certifique-se de revisar e entender cada script antes da execução para garantir que ele atenda às necessidades específicas do seu ambiente de trabalho.

## Contribuições

Contribuições são bem-vindas! Se você tiver sugestões de melhorias nos scripts ou deseja adicionar novos recursos, sinta-se à vontade para enviar um pull request.

