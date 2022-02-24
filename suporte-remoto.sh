#! /bin/bash

# create and run dialog
TITLE="Suporte Remoto"
TEXT="\nInforme o IP do computador do técnico\n"
INVALID_IP_TEXT="\nFormato de IP invalido\n"
CMD=
RES_isCMD=
isValid=

function open_msg(){
    yad --width="$1" --center --window-icon="$2" --name="${0##*/}" --title="$3" --text="$4" --image="$2" "$@"
}

function run_x11vnc(){
    x11vnc -connect "$1" &
    result=$(open_msg "500" "appimagekit-org.keepassxc.KeePassXC" "$TITLE" "\nConexão enviada com sucesso.\nIP: $1" --button="Encerrar e tentar novamente":10 --button="Encerrar":20)
    ret=$?
    [[ -z "$ret" || "$ret" -eq "20" ]] && kill_PS_x11vnc "exit" && exit 0
    [[ "$ret" -eq "10" ]] && kill_PS_x11vnc "now"
}

function kill_PS_x11vnc(){
    kill -9 $(pgrep x11vnc) &> /dev/null 
    [[ "now" == "$1" ]] && open_dialg
    [[ "exit" == "$1" ]] && open_msg "350" "emblem-success" "$TITLE" "\nConexão encerrada com sucesso" --button="Sair"
}

function IPValid(){
    echo "1: $1"
    isValid=$(echo "$1" | egrep -e "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
    [[ -z "$isValid" ]] && isCMD
    [[ -n "$isValid" ]] && run_x11vnc $1 
}

function open_dialg(){
    CMD=$(yad --width=500 --center --window-icon=distributor-logo-knoppix --name="${0##*/}" --title="Suporte Remoto" --text="\nInforme o IP do computador do técnico\n" --image=distributor-logo-knoppix --entry --editable --button="Sair":7 --button="Conectar":5)
    ret=$?
    echo "ret: $ret"
    [[ "$ret" == "7" || -z "$ret" ]] && kill_PS_x11vnc "exit" && exit 0
    [[ "$ret" == "5" || "$ret" == "0" ]] && echo "CMD: $CMD" && IPValid "$CMD"
}

function isCMD(){
    isValue=$(open_msg "500" "abrt" "$TITLE" "$INVALID_IP_TEXT" --button="Tentar Novamente":10 --button="Sair":20)
    ret=$?
    RES_isCMD=$ret

    [[ -z "$ret" || "$ret" -eq "20" ]] && kill_PS_x11vnc "exit" && exit 0
    [[ "$ret" -eq "10" ]] && open_dialg
}

function exec_VNC(){
    kill_PS_x11vnc
    open_dialg
    [[ "$RES_isCMD" -eq "10"  ]] && open_dialg
}

exec_VNC

exit 0
