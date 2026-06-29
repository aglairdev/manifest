#!/bin/bash
#
# manifest - buscador de manifests no terminal
# © 2026 ~ AGL ~ github.com/aglairdev
# licença: MIT
#

#Configs
VERSION="1.7"
AGL="ꕤ"

#Rotas
URL_RYU="https://generator.ryuu.lol/download?appid="
URL_MORRENUS="https://hubcapmanifest.com/api/v1/manifest/"
URL_SUSHI="https://raw.githubusercontent.com/sushi-dev55-alt/sushitools-games-repo-alt/refs/heads/main/"
URL_STEAM_SEARCH="https://store.steampowered.com/api/storesearch/?l=latam&cc=BR&term="

#Arquivos
DIR_CONFIG="$HOME/.config/Manifest"
DIR_DOWNLOAD="$HOME/Downloads/Manifests"
FILE_RYU_CONFIG="$DIR_CONFIG/.ryu_config"
FILE_MOR_CONFIG="$DIR_CONFIG/.morrenus_config"
FILE_ACCELA_CONFIG="$DIR_CONFIG/.accela_enabled"
BIN_REAL_ACCELA="$HOME/.local/share/ACCELA/run.sh"
FILE_ACCELA_CONF="$HOME/.config/Tachibana Labs/ACCELA.conf"

#enter-the-wired
DIR_WIRED="$HOME/enter-the-wired"
BIN_ACCELA="$DIR_WIRED/accela"
BIN_SLS="$DIR_WIRED/slssteam"
BIN_UNINSTALL="$DIR_WIRED/uninstall"

#Cores
CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAN_GREEN='\033[38;2;54;125;40m'
NC='\033[0m'

# Cores (ProtonDB)
ST_PLATINA='\033[1;36m' 
ST_OURO='\033[1;33m'    
ST_PRATA='\033[0;37m'   
ST_BRONZE='\033[0;33m'  
ST_BORKED='\033[1;31m'  
ST_NATIVO='\033[1;32m'  

# Cores (Steam)
CAT_JOGO='\033[1;34m'   
CAT_DLC='\033[1;35m'    
CAT_SOUND='\033[1;32m'

mkdir -p "$DIR_DOWNLOAD"

divider() {
    local div=""
    for i in 1 2 3 4 5 6 7; do
        if (( i % 2 == 0 )); then
            div+="${MAN_GREEN}─────${NC}"
        else
            div+="─────"
        fi
        (( i < 7 )) && div+=" "
    done
    echo -e "$div"
}

show_header() {
    clear
    echo ""
    echo -e "  ${ST_PRATA}v${VERSION} // Manifest ${AGL}${NC}"
    divider
}

check_update() {
    local LATEST
    LATEST=$(curl -s --connect-timeout 3 \
        "https://raw.githubusercontent.com/aglairdev/Manifest/main/manifest.sh" \
        | grep '^VERSION=' | cut -d'"' -f2 2>/dev/null)

    if [[ -n "$LATEST" && "$LATEST" != "$VERSION" ]]; then
        echo -e " ${AGL} Nova versão disponível: ${GREEN}v${LATEST}${NC} (atual: ${RED}v${VERSION}${NC})"
        divider
        echo ""
        read -p "Atualizar agora? (s/n): " UPD
        if [[ "$UPD" == "s" ]]; then
            curl -fsSL https://raw.githubusercontent.com/aglairdev/Manifest/main/install.sh | bash
            exec manifest
        fi
        echo ""
    fi
}

apply_accela_defaults() {
    if [ ! -f "$BIN_REAL_ACCELA" ]; then return; fi
    if [ ! -f "$FILE_ACCELA_CONF" ]; then return; fi
    {
        for KEY in generate_achievements use_steamless; do
            if grep -q "^${KEY}=" "$FILE_ACCELA_CONF"; then
                sed -i "s/^${KEY}=.*/${KEY}=true/" "$FILE_ACCELA_CONF"
            else
                echo "${KEY}=true" >> "$FILE_ACCELA_CONF"
            fi
        done
    } &>/dev/null &
}

get_proton_status() {
    local ID=$1
    local STATUS=$(curl -s --connect-timeout 2 "https://www.protondb.com/api/v1/reports/summaries/${ID}.json" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('tier', 'na').lower())" 2>/dev/null)
    local URL="https://www.protondb.com/app/${ID}"

    link_status() {
        echo -ne "\e]8;;${URL}\a[${1}]\e]8;;\a"
    }

    case "$STATUS" in
        "platinum") echo -ne "${ST_PLATINA}$(link_status "Platina")${NC}" ;;
        "gold")     echo -ne "${ST_OURO}$(link_status "Ouro")${NC}" ;;
        "silver")   echo -ne "${ST_PRATA}$(link_status "Prata")${NC}" ;;
        "bronze")   echo -ne "${ST_BRONZE}$(link_status "Bronze")${NC}" ;;
        "borked")   echo -ne "${ST_BORKED}$(link_status "Quebrado")${NC}" ;;
        "native")   echo -ne "${ST_NATIVO}$(link_status "Nativo")${NC}" ;;
        *)          echo -ne "${NC}[S/I]" ;;
    esac
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
        local ids=($(echo "$JSON_DATA" | grep -oP '"id":\K[0-9]+' | head -n 5))
        
        local i=1
        for current_id in "${ids[@]}"; do
            local DETAILS=$(curl -s "https://store.steampowered.com/api/appdetails?appids=${current_id}")
            local NAME=$(echo "$DETAILS" | python3 -c "import sys, json; d=json.load(sys.stdin); id=next(iter(d)); print(d[id]['data']['name']) if d[id]['success'] else print('Unknown')")
            local TYPE=$(echo "$DETAILS" | python3 -c "import sys, json; d=json.load(sys.stdin); id=next(iter(d)); print(d[id]['data']['type']) if d[id]['success'] else print('game')")

            local LINE="[${i}] ${WHITE}${NAME}${NC} (${CYAN}${current_id}${NC})"
            
            case "$TYPE" in
                "dlc")
                    LINE="${LINE} ${CAT_DLC}[DLC]${NC}"
                    ;;
                "music")
                    LINE="${LINE} ${CAT_SOUND}[Soundtrack]${NC}"
                    ;;
                *)
                    local P_STATUS=$(get_proton_status "$current_id")
                    LINE="${LINE} ${CAT_JOGO}[Jogo]${NC} ${P_STATUS}"
                    ;;
            esac

            echo -e "$LINE" >&2
            ((i++))
        done
        
        echo "" >&2
        read -p "> " CHOICE >&2
        
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
    name = re.sub(r'[^\w\s]', '', name) 
    name = re.sub(r'\s+', '_', name)   
    clean_name = name[:20]             
    print(f'{clean_name}-{sys.argv[1]}.zip')
except:
    print(f'{sys.argv[1]}.zip')
" "$ID"
}

menu_baixar() {
    show_header
    read -p "$(echo -e "  AppID ou Nome (${RED}q${NC} para voltar): ")" USER_INPUT
    if [[ "$USER_INPUT" == "q" ]]; then return; fi

    APPID=$(resolve_appid "$USER_INPUT")

    if [ "$APPID" == "ERRO" ]; then
        echo -e "${RED}Não encontrei nada para: $USER_INPUT${NC}"
        read -p "  Enter para voltar..."
        return
    elif [ "$APPID" == "CANCEL" ]; then
        return
    fi

    FILENAME=$(get_clean_filename "$APPID")
    FILE_PATH="${DIR_DOWNLOAD}/${FILENAME}"

    show_header
    echo ""
    echo -e "AppID: ${APPID}"
    echo ""
    FOUND=false

    # Morrenus
    if [ -f "$FILE_MOR_CONFIG" ]; then
        source "$FILE_MOR_CONFIG"
        echo -n "  Morrenus: "
        HTTP_STATUS=$(curl -o "$FILE_PATH" -s -H "Authorization: Bearer $KEY" -w "%{http_code}" -L "${URL_MORRENUS}${APPID}")
        if [ "$HTTP_STATUS" == "200" ]; then
            echo -e "${GREEN}SUCESSO${NC}"; FOUND=true
        elif [ "$HTTP_STATUS" == "401" ] || [ "$HTTP_STATUS" == "403" ]; then
            echo -e "${RED}CHAVE EXPIRADA${NC}"; rm -f "$FILE_MOR_CONFIG" "$FILE_PATH"
        else
            echo -e "${RED}INDISPONÍVEL${NC}"; rm -f "$FILE_PATH"
        fi
    fi

    # Ryu
    if [ "$FOUND" = false ] && [ -f "$FILE_RYU_CONFIG" ]; then
        source "$FILE_RYU_CONFIG"
        echo -n "  Ryu: "
        if [ $(curl -o "$FILE_PATH" -s -H "Cookie: $COOKIE" -H "User-Agent: $AGENT" -w "%{http_code}" -L "${URL_RYU}${APPID}&file_type=manifest") == "200" ]; then
            echo -e "${GREEN}SUCESSO${NC}"; FOUND=true
        else
            echo -e "${RED}INDISPONÍVEL${NC}"; rm -f "$FILE_PATH"
        fi
    fi

    # Sushi
    if [ "$FOUND" = false ]; then
        echo -n "  Sushi: "
        if [ $(curl -o "$FILE_PATH" -s -w "%{http_code}" -L "${URL_SUSHI}${APPID}.zip") == "200" ]; then
            echo -e "${GREEN}SUCESSO${NC}"; FOUND=true
        else
            echo -e "${RED}INDISPONÍVEL${NC}"; rm -f "$FILE_PATH"
        fi
    fi

    if [ "$FOUND" = true ]; then
        echo -e "\n  ${GREEN}Download concluído.${NC}"
        echo -e "  Salvo em: ${CYAN}${FILE_PATH}${NC}"
        if [ -f "$FILE_ACCELA_CONFIG" ]; then
            echo -e "  ${YELLOW}Enviando para Accela CLI...${NC}"
            "$BIN_REAL_ACCELA" --cli "$FILE_PATH"
        fi
    else
        echo -e "\n  ${RED}Nenhum arquivo encontrado.${NC}"
    fi
    echo ""
    read -p "  Enter para voltar..."
}

menu_accela() {
    while true; do
        show_header

        if [ ! -f "$BIN_REAL_ACCELA" ]; then
            echo -e "STATUS ATUAL: [${RED}PENDENTE${NC}] (Não instalado)"
            echo ""
            echo -e "> O comando de instalação utiliza curl e bash."
            echo -e "> Créditos: ${CYAN}https://github.com/ciscosweater/enter-the-wired${NC}"
            echo -e "> Os scripts são instalados em ~/.local/share/ACCELA/"
            divider
            echo -e "\nDESEJA INSTALAR AGORA?"
            echo ""
            echo -e "  [${GREEN}1${NC}] Sim, executar enter-the-wired"
            echo -e "  [${RED}0${NC}] Voltar"
        else
            if [ -f "$FILE_ACCELA_CONFIG" ]; then
                echo -e "  STATUS ATUAL: [${GREEN}ATIVADO${NC}]"
            else
                echo -e "  STATUS ATUAL: [${YELLOW}DESATIVADO${NC}]"
            fi
            echo -e "  Os scripts estão em:"
            echo -e "  ~/.local/share/ACCELA/"
            divider
            if [ -f "$FILE_ACCELA_CONFIG" ]; then
                echo -e "  [${RED}1${NC}] Desativar integração"
            else
                echo -e "  [${BLUE}1${NC}] Ativar integração"
            fi
            echo -e "  [${BLUE}2${NC}] Configurar conquistas"
            echo -e "  [${GREEN}3${NC}] Atualizar Accela"
            echo -e "  [${GREEN}4${NC}] Atualizar SLSsteam"
            echo -e "  [${GREEN}5${NC}] Atualizar enter-the-wired"
            echo -e "  [${RED}6${NC}] Remover tudo"
            echo -e "  [${RED}0${NC}] Voltar"
            divider
        fi

        read -p "> " SUB_OPT

        if [ ! -f "$BIN_REAL_ACCELA" ]; then
            case $SUB_OPT in
                1) 
                    echo -e "\n${CYAN}Iniciando instalação...${NC}"
                    curl -fsSL https://raw.githubusercontent.com/aglairdev/enter-the-wired/main/enter-the-wired | bash
                    read -p "  Enter para continuar..." 
                    ;;
                0) return ;;
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
                2)
                    source "$HOME/.local/share/ACCELA/.venv/bin/activate" && python3 "$HOME/.local/share/ACCELA/src/deps/SLScheevo/SLScheevo.py"
                    deactivate 2>/dev/null
                    read -p "  Enter para continuar..."
                    ;;
                3) [ -f "$BIN_ACCELA" ] && bash "$BIN_ACCELA" || echo -e "${RED}Erro: Script ausente.${NC}"; read -p "  Enter..." ;;
                4) [ -f "$BIN_SLS" ] && bash "$BIN_SLS" || echo -e "${RED}Erro: Script ausente.${NC}"; read -p "  Enter..." ;;
                5)
                    echo -e "\n${CYAN}Atualizando enter-the-wired...${NC}"
                    curl -fsSL https://raw.githubusercontent.com/aglairdev/enter-the-wired/main/enter-the-wired | bash
                    read -p "  Enter para continuar..."
                    ;;
                6) 
                    read -p "  Remover Accela, SLSsteam, SLScheevo, Steamless? (s/n): " CONFIRM
                    if [ "$CONFIRM" = "s" ]; then
                        [ -f "$BIN_UNINSTALL" ] && bash "$BIN_UNINSTALL"
                        rm -f "$FILE_ACCELA_CONFIG"
                        rm -rf "$DIR_WIRED" "$HOME/.local/share/ACCELA"
                        echo -e "\n  ${GREEN}Limpeza completa concluída.${NC}"
                        read -p "  Enter..."
                        return
                    fi
                    ;;
                0) return ;;
                *) echo -e "${RED}Opção inválida.${NC}"; sleep 1 ;;
            esac
        fi
    done
}

check_update
apply_accela_defaults

while true; do
    show_header
    [ -f "$FILE_MOR_CONFIG" ] && echo -e "  Morrenus  [${GREEN}PRONTO${NC}]" || echo -e "  Morrenus  [${RED}PENDENTE${NC}]"
    [ -f "$FILE_RYU_CONFIG" ] && echo -e "  Ryu       [${GREEN}PRONTO${NC}]" || echo -e "  Ryu       [${RED}PENDENTE${NC}]"
    echo -e "  Sushi     [${GREEN}PRONTO${NC}]"
    divider
    if [ ! -f "$BIN_REAL_ACCELA" ]; then
        echo -e "  Accela    [${RED}PENDENTE${NC}]"
    elif [ -f "$FILE_ACCELA_CONFIG" ]; then
        echo -e "  Accela    [${GREEN}ATIVADO${NC}]"
    else
        echo -e "  Accela    [${YELLOW}DESATIVADO${NC}]"
    fi
    divider
    echo -e "  [${GREEN}1${NC}] Baixar manifests"
    echo -e "  [${BLUE}2${NC}] Configurar Morrenus"
    echo -e "  [${BLUE}3${NC}] Configurar Ryu"
    echo -e "  [${BLUE}4${NC}] Configurar Accela"
    echo -e "  [${RED}0${NC}] Sair"
    divider
    read -p "> " OPT

    case $OPT in
        1) menu_baixar ;;
        2)
            show_header
            echo -e "  > Acesse: ${CYAN}https://hubcapmanifest.com/${NC}"
            divider
            read -p "$(echo -e "  API Key (${RED}q${NC} para voltar): ")" API_KEY
            if [ "$API_KEY" != "q" ]; then
                if [[ "$API_KEY" =~ ^smm_[a-f0-9]{96}$ ]]; then
                    mkdir -p "$DIR_CONFIG"
                    echo "KEY='$API_KEY'" > "$FILE_MOR_CONFIG"
                    echo -e "\n  ${GREEN}Configurado!${NC}"
                else
                    echo -e "\n  ${RED}Chave inválida.${NC}"
                fi
                sleep 2
            fi
            ;;
        3)
            show_header
            echo "  Siga os passos:"
            echo -e "  1. Acesse: ${CYAN}https://generator.ryuu.lol/${NC}"
            echo "  2. F12 > F5 > Network > Filter URLs > download > Copy as cURL"
            divider
            read -p "$(echo -e "  Cole o comando (${RED}q${NC} para voltar): ")" CURL_CMD
            if [ "$CURL_CMD" != "q" ]; then
                COOKIE=$(echo "$CURL_CMD" | grep -oP "Cookie: \K[^']+")
                AGENT=$(echo "$CURL_CMD" | grep -oP "User-Agent: \K[^']+")
                if [ -n "$COOKIE" ]; then
                    mkdir -p "$DIR_CONFIG"
                    echo "COOKIE='$COOKIE'" > "$FILE_RYU_CONFIG"
                    echo "AGENT='$AGENT'" >> "$FILE_RYU_CONFIG"
                    echo -e "\n  ${GREEN}Configurado!${NC}"
                else
                    echo -e "\n  ${RED}Dados inválidos.${NC}"
                fi
                sleep 2
            fi
            ;;
        4) menu_accela ;;
        0) exit 0 ;;
        *) echo -e "${RED}Opção inválida.${NC}"; sleep 1 ;;
    esac
done