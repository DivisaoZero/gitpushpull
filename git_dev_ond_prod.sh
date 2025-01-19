#!/bin/bash
#https://github.com/DivisaoZero/gitpushpull

DZLOGFILE="/dzti/quest/git_dev_on_prod.log"
ERRCODE=0

#FUNÇÃO PUSH - GITHUB
#PARÂEMTRO 1:   Texto para a descrição do Commit usado no push.
function push {
    # Acessar a pasta do projeto em desenvolvimento.
    ((ERRCODE++))
    cd /dzti/quest/quest-dev1/ || {
        echo -e "Error [$ERRCODE]:\n$RETURN\n"
        echo    "$(date "+%Y-%m-%d %H:%M:%S") Error [$ERRCODE]: $RETURN" >> "$DZLOGFILE"
        exit 1
    }
    # Adicionar as alterações no Stage do git
    ((ERRCODE++))
    CODE="git add -A"
    RETURN=$(eval  $CODE 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "Error [$ERRCODE]: $CODE: \n$RETURN\n"
        echo    "$(date "+%Y-%m-%d %H:%M:%S") Error [$ERRCODE]: $CODE: $RETURN" >> "$DZLOGFILE"
        exit 1
    fi

    # Realizar o Commit do Stage.
    ((ERRCODE++))
    CODE="git commit -m \"$PAR1\""
    RETURN=$(eval $CODE 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "Error [$ERRCODE]: $CODE: \n$RETURN\n"
        echo    "$(date "+%Y-%m-%d %H:%M:%S") Error [$ERRCODE]: $CODE: $RETURN" >> "$DZLOGFILE"
        exit 1
    fi

    # Realizar o Push ao GitHub.
    ((ERRCODE++))
    CODE="git push origin master"
    RETURN=$(eval $CODE 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "Error [$ERRCODE]: $CODE: \n$RETURN\n"
        echo    "$(date "+%Y-%m-%d %H:%M:%S") Error [$ERRCODE]: $CODE: $RETURN" >> "$DZLOGFILE"
        exit 1
    fi
    echo "Error 0: Push executedo com sucesso: \"$1\""
    echo "$(date "+%Y-%m-%d %H:%M:%S") Error 0: Push executedo com sucesso." >> "$DZLOGFILE"
}

#FUNÇÃO PULL - GITHUB
function pull {
    # Acessar a pasta do projeto em produção.
    ((ERRCODE++))
    cd /dzti/quest/quest-prod/ || {
        echo -e "Error [$ERRCODE]:\n$RETURN\n"
        echo    "$(date "+%Y-%m-%d %H:%M:%S") Error [$ERRCODE]: $RETURN" >> "$DZLOGFILE"
        exit 1
    }

    # Obter a versão da branch 'master' do github
    ((ERRCODE++))
    CODE="git pull origin master"
    RETURN=$($CODE 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "Error [$ERRCODE]: $CODE: \n$RETURN\n"
        echo    "$(date "+%Y-%m-%d %H:%M:%S") Error [$ERRCODE]: $CODE: $RETURN" >> "$DZLOGFILE"
        exit 1
    fi

    # Reiniciar o serviço do PM2 ao projeto.
    ((ERRCODE++))
    CODE="pm2 restart quest-server.js"
    RETURN=$($CODE 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "Error [$ERRCODE]: $CODE: \n$RETURN\n"
        echo    "$(date "+%Y-%m-%d %H:%M:%S") Error [$ERRCODE]: $CODE: $RETURN" >> "$DZLOGFILE"
        exit 1
    fi

    echo "Error 0: Pull executedo com sucesso."
    echo "$(date "+%Y-%m-%d %H:%M:%S") Error 0: Pull executedo com sucesso." >> "$DZLOGFILE"
}

#------------------------------------------------------------------------------
#--CORPO DO BASH---------------------------------------------------------------
#------------------------------------------------------------------------------

# Conferir a existência de um parâmetro para o Github.
((ERRCODE++))
if [ -z "$1" ]; then
    echo "Error [$ERRCODE]: Parâmetro inexistente.\n"
    echo "$(date "+%Y-%m-%d %H:%M:%S") Error [$ERRCODE]: Parâmetro inexistente." >> "$DZLOGFILE"
    exit 1
fi

#Se o parâmetro 1 form push, então substitui com a data atual, senão utilizar o texto informado para o "Commit Message".
PAR1=$1; if [ "$1" == "push" ]; then PAR1="$(date "+%Y-%m-%d %H:%M:%S")"; fi
#Se o segundo parâmetro for diferente de "pull" então inserir 0
PAR2="none"; if [ "$2" == "pull" ]; then PAR2=$2; fi

if [ "$PAR1" == "pull" ]; then
    pull
    exit 0
fi

if [ "$PAR2" == "pull" ]; then
    push $PAR1
    pull    
    exit 0
fi

if [ "$PAR2" == "none" ]; then
    push $PAR1
    exit 0
fi

((ERRCODE++))
echo "Error [$ERRCODE]: Erro no bash.\n"
echo "$(date "+%Y-%m-%d %H:%M:%S") Error [$ERRCODE]: Erro no bash." >> "$DZLOGFILE"
exit 1
