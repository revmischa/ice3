#!/bin/bash

for k in STREAM_URL STREAM_PASS STREAM_NAME INFO_URL GENRE DESCRIPTION
do
	if [[ -z "${!k}" ]]; then
	    echo "Warn: $k not set"
	fi
	echo "$k=${!k}"
	sed -i "s'%${k}%'${!k}'" ezstream.xml
done
echo "Using stream URL $STREAM_URL"
