#!/bin/bash
while true; do
NC_PACKET=`nc -l 112`
if [ "${NC_PACKET}" = "stop hping3" ]; then
    killall hping3
    echo "Received kill signal."
fi
done
