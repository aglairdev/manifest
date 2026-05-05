#!/bin/bash

#Configs
VERSION="1.0"
AGL="ꕤ"

#Endpoints
URL_RYU="https://generator.ryuu.lol/download?appid="
URL_MORRENUS="https://manifest.morrenus.xyz/api/v1/manifest/"
URL_SUSHI="https://raw.githubusercontent.com/sushi-dev55-alt/sushitools-games-repo-alt/refs/heads/main/"
URL_STEAM_SEARCH="https://store.steampowered.com/api/storesearch/?l=latam&cc=BR&term="

#Files
DIR_CONFIG="$HOME/.config/Manifest"
DIR_DOWNLOAD="$HOME/Downloads/Manifests"
FILE_RYU_CONFIG="$DIR_CONFIG/.ryu_config"
FILE_MOR_CONFIG="$DIR_CONFIG/.morrenus_config"
FILE_ACCELA_CONFIG="$DIR_CONFIG/.accela_enabled"
BIN_REAL_ACCELA="$HOME/.local/share/ACCELA/run.sh"

mkdir -p "$DIR_DOWNLOAD"

#Enter-the-wired
DIR_WIRED="$HOME/enter-the-wired"
BIN_ACCELA="$DIR_WIRED/accela"
BIN_SLS="$DIR_WIRED/slssteam"
BIN_UNINSTALL="$DIR_WIRED/uninstall"

#Colors
CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

show_header() {
    clear
    echo -e "v${VERSION} // Manifest ${AGL}"
    echo -e "${CYAN}------------------------------------------${NC}"
    echo ""
}

resolve_appid() {
    local INPUT=$1
    if [[ "$INPUT" =~ ^[0-9]+$ ]]; then echo "$INPUT"; return; fi

    local ENCODED_NAME="${INPUT// /%20}"
    local JSON_DATA=$(curl -s -L "${URL_STEAM_SEARCH}${ENCODED_NAME}")
    local COUNT=$(echo "$JSON_DATA" | grep -o '"id":' | wc -l)

    if [ "$COUNT" -eq 0 ]; then
        echo "ERRO"
    else
        echo -e "\nResultados para '${INPUT}':\n" >&2
        
        local MAP=$(echo "$JSON_DATA" | python3 -c "import sys, json; data=json.load(sys.stdin); [print(f'{item[\"name\"]} (ID: {item[\"id\"]})') for item in data['items'][:5]]")
        local ids=($(echo "$JSON_DATA" | grep -oP '"id":\K[0-9]+' | head -n 5))
        
        local i=1
        while read -r line; do
            [ -z "$line" ] && continue
            echo -e "[$i] $line" >&2
            ((i++))
        done <<< "$MAP"
        
        echo -e "[q] Cancelar" >&2
        echo "" >&2
        read -p "Selecione: " CHOICE >&2
        
        if [[ "$CHOICE" =~ ^[1-9]$ ]] && [ "$CHOICE" -le "${#ids[@]}" ]; then
            echo "${ids[$((CHOICE-1))]}"
        else
            echo "CANCEL"
        fi
    fi
}

get_clean_filename() {
    local ID=$1
    local JSON_DATA=$(curl -s -L "https://store.steampowered.com/api/appdetails?appids=${ID}&l=brazilian")
    
    echo "$JSON_DATA" | python3 -c "
import sys, json, re
try:
    data = json.load(sys.stdin)
    name = data[next(iter(data))]['data']['name']
    name = re.sub(r'[^\w\s]', '', name) # Remove especiais
    name = re.sub(r'\s+', '_', name)   # Espaço vira _
    clean_name = name[:20]             # Limite 20 chars
    print(f'{clean_name}-{sys.argv[1]}.zip')
except:
    print(f'{sys.argv[1]}.zip')
" "$ID"
}

menu_accela() {
    while true; do
        show_header
        echo -e "CONFIG ACCELA"
        echo -e "─────────────"
        echo ""

        if [ ! -f "$BIN_REAL_ACCELA" ]; then
            echo -e "STATUS ATUAL: [${RED}PENDENTE${NC}] (Não instalado)"
            echo ""
            echo -e "> O comando de instalação utiliza curl e bash."
            echo -e "> Créditos: ${CYAN}https://github.com/ciscosweater/enter-the-wired${NC}"
            echo -e "> Os scripts são instalados em ~/.local/share/ACCELA/"
            echo -e "${CYAN}------------------------------------------${NC}"
            echo -e "\nDESEJA INSTALAR AGORA?"
            echo -e "\n[1] Sim, executar enter-the-wired"
            echo -e "[2] Não, apenas voltar"
        else
            if [ -f "$FILE_ACCELA_CONFIG" ]; then
                echo -e "STATUS ATUAL: [${GREEN}ATIVADO${NC}]"
            else
                echo -e "STATUS ATUAL: [${YELLOW}DESATIVADO${NC}]"
            fi
            echo -e "\nOs scripts estão em:"
            echo -e "~/.local/share/ACCELA/"
            echo -e "------------------------------------------"
            echo -e "\nO QUE DESEJA FAZER?"
            [ -f "$FILE_ACCELA_CONFIG" ] && echo -e "\n[1] Desativar integração" || echo -e "\n[1] Ativar integração"
            echo -e "[2] Atualizar Accela"
            echo -e "[3] Atualizar SLSsteam"
            echo -e "[4] Remover tudo"
            echo -e "[5] Apenas voltar"
        fi

        echo ""
        read -p "Selecione: " SUB_OPT

        if [ ! -f "$BIN_REAL_ACCELA" ]; then
            case $SUB_OPT in
                1) 
                    echo -e "\n${CYAN}Iniciando instalação...${NC}"
                    curl -fsSL https://raw.githubusercontent.com/ciscosweater/enter-the-wired/main/enter-the-wired | bash
                    read -p "Pressione Enter para continuar..." 
                    ;;
                2) return ;;
                *) echo -e "${RED}Opção inválida.${NC}"; sleep 1 ;;
            esac
        else
            case $SUB_OPT in
                1) 
                    if [ -f "$FILE_ACCELA_CONFIG" ]; then
                        rm -f "$FILE_ACCELA_CONFIG"
                    else
                        mkdir -p "$DIR_CONFIG"
                        touch "$FILE_ACCELA_CONFIG"
                    fi
                    ;;
                2) [ -f "$BIN_ACCELA" ] && bash "$BIN_ACCELA" || echo -e "${RED}Erro: Script ausente.${NC}"; read -p "Enter..." ;;
                3) [ -f "$BIN_SLS" ] && bash "$BIN_SLS" || echo -e "${RED}Erro: Script ausente.${NC}"; read -p "Enter..." ;;
                4) 
                    read -p "Remover Accela, SLSsteam, SLScheevo, Steamless? (s/n): " CONFIRM
                    if [ "$CONFIRM" = "s" ]; then
                        [ -f "$BIN_UNINSTALL" ] && bash "$BIN_UNINSTALL"
                        rm -f "$FILE_ACCELA_CONFIG"
                        rm -rf "$DIR_WIRED" "$HOME/.local/share/ACCELA"
                        echo -e "\n${GREEN}Limpeza completa concluída.${NC}"
                        read -p "Enter..."
                        return
                    fi
                    ;;
                5) return ;;
                *) echo -e "${RED}Opção inválida.${NC}"; sleep 1 ;;
            esac
        fi
    done
}

while true; do
    show_header
    echo -e "FONTES"
    echo -e "──────"
    [ -f "$FILE_RYU_CONFIG" ] && echo -e "Ryu       [${GREEN}PRONTO${NC}]" || echo -e "Ryu       [${RED}PENDENTE${NC}]"
    [ -f "$FILE_MOR_CONFIG" ] && echo -e "Morrenus  [${GREEN}PRONTO${NC}]" || echo -e "Morrenus  [${RED}PENDENTE${NC}]"
    echo -e "Sushi     [${GREEN}PRONTO${NC}]"
    echo -e "${CYAN}------------------------------------------${NC}"
    echo -e "\nINTEGRAÇÃO"
    echo -e "──────────"
    if [ ! -f "$BIN_REAL_ACCELA" ]; then
        echo -e "Accela    [${RED}PENDENTE${NC}]"
    elif [ -f "$FILE_ACCELA_CONFIG" ]; then
        echo -e "Accela    [${GREEN}ATIVADO${NC}]"
    else
        echo -e "Accela    [${YELLOW}DESATIVADO${NC}]"
    fi
    echo -e "${CYAN}------------------------------------------${NC}"
    echo -e "\n1. Baixar manifests"
    echo "2. Configurar Ryu"
    echo "3. Configurar Morrenus"
    echo "4. Configurar Accela"
    echo "5. Sair"
    echo ""
    read -p "Selecione: " OPT

    case $OPT in
        1)
            echo ""
            read -p "AppID ou Nome: " USER_INPUT
            APPID=$(resolve_appid "$USER_INPUT")

            if [ "$APPID" == "ERRO" ]; then
                echo -e "${RED}Não encontrei nada para: $USER_INPUT${NC}"; read -p "Enter para voltar..."; continue
            elif [ "$APPID" == "CANCEL" ]; then
                continue
            fi

            FILENAME=$(get_clean_filename "$APPID")
            FILE_PATH="${DIR_DOWNLOAD}/${FILENAME}"

            show_header
            echo -e "\nAppID: ${APPID}"
            echo -e "${CYAN}------------------------------------------${NC}\n"
            FOUND=false
            
            # Sushi
            echo -n "Sushi: "
            if [ $(curl -o "$FILE_PATH" -s -w "%{http_code}" -L "${URL_SUSHI}${APPID}.zip") == "200" ]; then
                echo -e "${GREEN}SUCESSO${NC}"; FOUND=true
            else
                echo -e "${RED}INDISPONÍVEL${NC}"; rm -f "$FILE_PATH"
            fi

            # Ryu
            if [ "$FOUND" = false ] && [ -f "$FILE_RYU_CONFIG" ]; then
                source "$FILE_RYU_CONFIG"
                echo -n "Ryu: "
                if [ $(curl -o "$FILE_PATH" -s -H "Cookie: $COOKIE" -H "User-Agent: $AGENT" -w "%{http_code}" -L "${URL_RYU}${APPID}&file_type=manifest") == "200" ]; then
                    echo -e "${GREEN}SUCESSO${NC}"; FOUND=true
                else
                    echo -e "${RED}INDISPONÍVEL${NC}"; rm -f "$FILE_PATH"
                fi
            fi

            # Morrenus
            if [ "$FOUND" = false ] && [ -f "$FILE_MOR_CONFIG" ]; then
                source "$FILE_MOR_CONFIG"
                echo -n "Morrenus: "
                HTTP_STATUS=$(curl -o "$FILE_PATH" -s -H "Authorization: Bearer $KEY" -w "%{http_code}" -L "${URL_MORRENUS}${APPID}")
                if [ "$HTTP_STATUS" == "200" ]; then
                    echo -e "${GREEN}SUCESSO${NC}"; FOUND=true
                elif [ "$HTTP_STATUS" == "401" ] || [ "$HTTP_STATUS" == "403" ]; then
                    echo -e "${RED}CHAVE EXPIRADA${NC}"; rm -f "$FILE_MOR_CONFIG" "$FILE_PATH"
                else
                    echo -e "${RED}INDISPONÍVEL${NC}"; rm -f "$FILE_PATH"
                fi
            fi
            
            if [ "$FOUND" = true ]; then
                echo -e "\n${GREEN}Download concluído.${NC}"
                echo ""
                echo -e "Salvo em: ${CYAN}${FILE_PATH}${NC}"
                
                if [ -f "$FILE_ACCELA_CONFIG" ]; then
                    echo -e "${YELLOW}Enviando para Accela CLI...${NC}"
                    accela --cli "$FILE_PATH"
                fi
            else
                echo -e "\n${RED}Nenhum arquivo encontrado.${NC}"
            fi
            echo ""
            read -p "Enter para voltar..."
            ;;
        2)
            show_header
            echo -e "CONFIG RYU\n──────────\n"
            echo "Siga os passos:"
            echo ""
            echo -e "1. Acesse: ${CYAN}https://generator.ryuu.lol/${NC}"
            echo "2. F12 > F5 > Network > Filter URLs > download > Copy as cURL"
            echo -e "${CYAN}------------------------------------------${NC}"
            echo ""
            read -p "Cole o comando (ou 'q'): " CURL_CMD
            if [ "$CURL_CMD" != "q" ]; then
                COOKIE=$(echo "$CURL_CMD" | grep -oP "Cookie: \K[^']+")
                AGENT=$(echo "$CURL_CMD" | grep -oP "User-Agent: \K[^']+")
                if [ -n "$COOKIE" ]; then
                    mkdir -p "$DIR_CONFIG"
                    echo "COOKIE='$COOKIE'" > "$FILE_RYU_CONFIG"
                    echo "AGENT='$AGENT'" >> "$FILE_RYU_CONFIG"
                    echo -e "\n${GREEN}Configurado!${NC}"
                else
                    echo -e "\n${RED}Dados inválidos.${NC}"
                fi
                sleep 2
            fi
            ;;
        3)
            show_header
            echo -e "CONFIG MORRENUS\n───────────────\n"
            echo -e "> Acesse: ${CYAN}https://hubcapmanifest.com/${NC}"
            echo -e "${CYAN}------------------------------------------${NC}"
            echo ""
            read -p "API Key (ou 'q'): " API_KEY
            if [ "$API_KEY" != "q" ]; then
                if [[ "$API_KEY" =~ ^smm_[a-f0-9]{96}$ ]]; then
                    mkdir -p "$DIR_CONFIG"
                    echo "KEY='$API_KEY'" > "$FILE_MOR_CONFIG"
                    echo -e "\n${GREEN}Configurado!${NC}"
                else
                    echo -e "\n${RED}Chave inválida.${NC}"
                fi
                sleep 2
            fi
            ;;
        4) menu_accela ;;
        5) exit 0 ;;
        *) echo -e "${RED}Opção inválida.${NC}"; sleep 1 ;;
    esac
done
