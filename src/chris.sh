#!/bin/bash
if [ "$1" = "Start" ] || [ "$1" = "start" ]; then
    if [ ! -e /etc/resolv.conf ]; then
        touch /etc/resolv.conf
        printf "nameserver 8.8.8.8\nnameserver 8.8.4.4" >> /etc/resolv.conf
    else
        printf "nameserver 8.8.8.8\nnameserver 8.8.4.4" >> /etc/resolv.conf
    fi
    echo "[Start] Attempted to fix resolv.conf"
elif [ "$1" = "Stop" ] || [ "$1" = "stop" ]; then
    rm -f /etc/resolv.conf
    touch /etc/resolv.conf
    echo "Cleared resolv.conf"
elif [ "$1" = "Status" ] || [ "$1" = "status" ]; then
    PRIMARY_IP=`cat /etc/resolv.conf | sed -n 1p | awk '{printf $2}'`
    if [ ${PRIMARY_IP} = 8.8.8.8 ]; then
        echo "8.8.8.8 appears to be present."
    else
        echo "You don't have Google Public DNS on the first line."
    fi
else
    echo "I no understand."
fi