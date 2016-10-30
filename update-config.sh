#!/bin/bash

CONF_FILE='ice3.ini'
echo "[streamer]" > $CONF_FILE

for k in STREAM_URL STREAM_PASS STREAM_NAME INFO_URL GENRE DESCRIPTION SQS_URL BUCKET_NAME
do
    if [[ -z "${!k}" ]]; then
        echo "Warn: $k not set"
    fi
    v=${!k}
    echo "$k=$v"
    kr="%${k}%"
    sed -i "s'$kr'$v'" ezstream.xml
    echo "$k=$v" >> $CONF_FILE 
done
echo "Using stream URL $STREAM_URL"
