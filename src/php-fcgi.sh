#!/bin/bash
PROCESS_STATE=`ps -ef|grep -v grep|grep php5-cgi|awk '{print $8}'`
if [ "${PROCESS_STATE}" == "/usr/bin/php5-cgi" ]; then
    /etc/init.d/php-fcgi -b 127.0.0.1:9000
    echo "php fcgi restarted at `date`" >> /var/log/fcgi-crash.log
fi