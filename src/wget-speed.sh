#!/bin/bash
FILE_URL=http://mirror.internode.on.net/pub/test/10meg.test
TEMP_LOG=/tmp/wget.out
wget -o ${TEMP_LOG} -O /dev/null ${FILE_URL}
DOWNLOAD_SPEED=`cat ${TEMP_LOG} | tail -2 | sed -n 1p | cut -d'(' -f2 | cut -f1 -d')'`
DOWNLOAD_NOTATION=`echo "${DOWNLOAD_SPEED}" | awk '{printf $2}'`
if [ "${DOWNLOAD_NOTATION}" = "MB/s" ]; then
    DOWNLOAD_NUMBER=`echo "${DOWNLOAD_SPEED}" | cut -f1 -d' '`
    DOWNLOAD_SPEED_TMP=${DOWNLOAD_NUMBER}
    DOWNLOAD_SPEED=`echo "${DOWNLOAD_SPEED_TMP} * 1024" | bc | cut -f1 -d'.'`
    unset DOWNLOAD_SPEED_TMP
fi
DOWNLOAD_SPEED_TMP=`echo ${DOWNLOAD_SPEED}`
DOWNLOAD_SPEED=`echo ${DOWNLOAD_SPEED_TMP} | cut -f1 -d' '`
unset DOWNLOAD_SPEED_TMP
SPEED_LOG_LOCATION=/var/log/last-speed.log
echo ${DOWNLOAD_SPEED} > ${SPEED_LOG_LOCATION}
HIST_LOG=/var/log/speed-history.log
echo "`date`: ${DOWNLOAD_SPEED} KB/s" >> ${HIST_LOG}
rm -f ${TEMP_LOG}