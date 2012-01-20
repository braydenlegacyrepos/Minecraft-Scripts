#!/bin/bash
PID=`ps --User $1 -o pid,cmd | grep -v grep | grep -w java | sed -n 2p | awk '{printf $1}'`
if [ $PID != "" ]; then
    kill -9 ${PID}
    echo "Attempted to kill ${PID} under username $1"
    exit 0
else
    echo "Something went wrong, got username $1 and PID ${PID} but the PID was not equal to anything."
    exit 1
fi