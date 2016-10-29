#!/bin/bash

for k in STREAM_URL STREAM_PASS STREAM_NAME INFO_URL GENRE DESCRIPTION
do
	if [[ -z "${!k}" ]]; then
	    echo "Warn: $k not set"
	    continue
	fi
	v=${!k}
	echo "$k=$v"
	kr="%${k}%"
	sed -i "s'$kr'$v'" ezstream.xml
done
echo "Using stream URL $STREAM_URL"
