#!/bin/bash
if [ `cat /home/ablac/service12/toolkit/wrapper.properties | grep maximum-heap-size | cut -f2 -d'='` != "2G" ]; then
    echo "Ablac didn't keep his promise" | mail brayden.hull@gmail.com
fi