#!/bin/bash

if [[ -z "${stream_uri}" ]]; then
    echo "\$stream_uri environment variable is required"
    exit 1
fi
if [[ -z "${stream_pass}" ]]; then
    echo "\$stream_pass environment variable is required"
    exit 1
fi

sed -i "s'%STREAM_URI%'$stream_uri'" ezstream.xml
sed -i "s'%STREAM_PASS%'$stream_pass'" ezstream.xml

echo "Using stream URI $stream_uri"
