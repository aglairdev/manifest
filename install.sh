#!/bin/bash

YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"
CHECK="✓"
CROSS="✗"
AGL="ꕤ"

DIR_BIN="$HOME/.local/bin"
DIR_CONF="$HOME/.config/Manifest"
REPO_URL="https://raw.githubusercontent.com/aglairdev/Manifest/main/manifest.sh"

clear
echo -e "${BLUE}Manifest ${AGL}${RESET}\n"
echo -e "Estabelecendo conexão com o repositório..."

check_deps() {
    local deps=("curl" "python3")
    local missing=()
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "\n${YELLOW}Para funcionar corretamente, o Manifest precisa de:${RESET} ${missing[*]}"
        read -p "Permitir que o instalador tente resolver via gerenciador de pacotes? (s/n): " auth
        if [[ "$auth" == "s" ]]; then
            if command -v dnf &> /dev/null; then
                sudo dnf install -y "${missing[@]}"
            elif command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y "${missing[@]}"
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm "${missing[@]}"
            else
                echo -e "\n${RED}${CROSS} Gerenciador de pacotes não identificado.${RESET}"
                exit 1
            fi
        else
            echo -e "\nInstalação interrompida."
            exit 1
        fi
    fi
}

check_deps

mkdir -p "$DIR_BIN"
mkdir -p "$DIR_CONF"

sleep 1
HTTP_STATUS=$(curl -L -w "%{http_code}" "$REPO_URL" -o "$DIR_CONF/manifest.sh" --silent)

if [ "$HTTP_STATUS" -eq 200 ]; then
    chmod +x "$DIR_CONF/manifest.sh"
    ln -sf "$DIR_CONF/manifest.sh" "$DIR_BIN/manifest"
    
    echo -e "\n${GREEN}${CHECK} Manifest configurado com sucesso!${RESET}"
    
    if [[ ":$PATH:" != *":$DIR_BIN:"* ]]; then
        echo -e "\n${YELLOW}Atenção:${RESET} O diretório $DIR_BIN não está no seu PATH."
        echo -e "Adicione esta linha ao seu .bashrc ou .zshrc para usar o comando:"
        echo -e "${BLUE}export PATH=\$PATH:\$HOME/.local/bin${RESET}"
    else
        echo -e "\nTudo pronto. Basta digitar ${BLUE}manifest${RESET} para começar.\n"
    fi
else
    echo -e "\n${RED}${CROSS} Ops! Ocorreu um problema ao baixar o arquivo.${RESET}"
    exit 1
fi