#!/bin/bash
while true; do
NC_PACKET=`nc -l 112 -v`
if [ "${NC_PACKET}" = "stop hping3" ]; then
    killall hping3
    echo "Received kill signal."
else
    echo ${NC_PACKET}
fi
done
