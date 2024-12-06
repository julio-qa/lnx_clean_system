#!/bin/bash

# Diretórios padrão para ações
DOWNLOADS_DIR="$HOME/Downloads"
TMP_DIR="/tmp"
TRASH_DIR="$HOME/.local/share/Trash"

# Variáveis
CLEAN_DOWNLOADS=false
CLEAN_TMP=false
CLEAN_TRASH=false
CONFIRMATION_REQUIRED=true
VERBOSE=false
DAYS_THRESHOLD=

# Função para exibir ajuda
function show_help() {
    cat << EOF
Uso: by_clean_system [opções]

Opções:
  -d, --downloads        Exclui todos os arquivos do diretório ~/Downloads.
  -t, --tmp              Exclui todos os arquivos do diretório /tmp.
  -r, --recycle-trash    Esvazia a lixeira do usuário (~/.local/share/Trash).
  -y, --force            Não solicita confirmação.
  -v, --verbose          Exibe informações detalhadas das operações.
  --days=N               Exclui apenas arquivos com mais de N dias.
  -h, --help             Exibe esta mensagem de ajuda.

Exemplos:
  by_clean_system -dtv         Limpa Downloads e /tmp com saída detalhada.
  by_clean_system -d -y        Exclui todos os arquivos do diretório ~/Downloads sem filtro de tempo.
  by_clean_system -d -y --days=30 Exclui arquivos com mais de 30 dias do diretório ~/Downloads.
EOF
}

# Função para excluir arquivos de um diretório
function clean_directory() {
    local dir=$1

    if [[ ! -d "$dir" ]]; then
        echo "Erro: O diretório $dir não existe."
        return
    fi

    if $CONFIRMATION_REQUIRED; then
        if [[ -n "$DAYS_THRESHOLD" ]]; then
            read -p "Tem certeza que deseja excluir arquivos com mais de $DAYS_THRESHOLD dias em $dir? (s/N): " CONFIRMATION
        else
            read -p "Tem certeza que deseja excluir TODOS os arquivos em $dir? (s/N): " CONFIRMATION
        fi
        CONFIRMATION=${CONFIRMATION,,} # Converte para minúsculas
        if [[ "$CONFIRMATION" != "s" ]]; then
            echo "Operação cancelada para $dir."
            return
        fi
    fi

    # Executa a limpeza
    if [[ -n "$DAYS_THRESHOLD" ]]; then
        if $VERBOSE; then
            find "$dir" -type f -mtime +$DAYS_THRESHOLD -exec rm -v {} \;
        else
            find "$dir" -type f -mtime +$DAYS_THRESHOLD -exec rm {} \;
        fi
        echo "Arquivos com mais de $DAYS_THRESHOLD dias em $dir foram excluídos."
    else
        if $VERBOSE; then
            find "$dir" -type f -exec rm -v {} \;
        else
            find "$dir" -type f -exec rm {} \;
        fi
        echo "TODOS os arquivos em $dir foram excluídos."
    fi
}

# Função para esvaziar a lixeira
function empty_trash() {
    if [[ ! -d "$TRASH_DIR" ]]; then
        echo "Erro: Diretório da lixeira $TRASH_DIR não encontrado."
        return
    fi

    if $CONFIRMATION_REQUIRED; then
        read -p "Tem certeza que deseja esvaziar a lixeira? (s/N): " CONFIRMATION
        CONFIRMATION=${CONFIRMATION,,}
        if [[ "$CONFIRMATION" != "s" ]]; then
            echo "Operação cancelada para a lixeira."
            return
        fi
    fi

    # Esvazia a lixeira
    if $VERBOSE; then
        find "$TRASH_DIR" -mindepth 1 -exec rm -rv {} \;
    else
        find "$TRASH_DIR" -mindepth 1 -exec rm -r {} \;
    fi
    echo "A lixeira foi esvaziada."
}

# Parse de argumentos combinados ou separados
while [[ $# -gt 0 ]]; do
    case $1 in
        -[a-z]*)
            for ((i = 1; i < ${#1}; i++)); do
                case ${1:$i:1} in
                    d) CLEAN_DOWNLOADS=true ;;
                    t) CLEAN_TMP=true ;;
                    v) VERBOSE=true ;;
                    r) CLEAN_TRASH=true ;;
                    y) CONFIRMATION_REQUIRED=false ;;
                    *) echo "Opção desconhecida: -${1:$i:1}" ; show_help ; exit 1 ;;
                esac
            done
            shift
            ;;
        --downloads) CLEAN_DOWNLOADS=true ; shift ;;
        --tmp) CLEAN_TMP=true ; shift ;;
        --recycle-trash) CLEAN_TRASH=true ; shift ;;
        --force) CONFIRMATION_REQUIRED=false ; shift ;;
        --verbose) VERBOSE=true ; shift ;;
        --days=*)
            DAYS_THRESHOLD="${1#*=}"
            shift
            ;;
        -h|--help) show_help ; exit 0 ;;
        *) echo "Opção desconhecida: $1" ; show_help ; exit 1 ;;
    esac
done

# Executa as ações de limpeza
if [[ $CLEAN_DOWNLOADS == true ]]; then
    clean_directory "$DOWNLOADS_DIR"
fi

if [[ $CLEAN_TMP == true ]]; then
    clean_directory "$TMP_DIR"
fi

if [[ $CLEAN_TRASH == true ]]; then
    empty_trash
fi

# Exibe uma mensagem se nenhuma ação foi especificada
if [[ $CLEAN_DOWNLOADS == false && $CLEAN_TMP == false && $CLEAN_TRASH == false ]]; then
    echo "Nenhuma ação especificada. Use -h ou --help para ver as opções."
    exit 1
fi

exit 0
