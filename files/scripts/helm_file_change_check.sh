#!/bin/bash
if [ $(which md5sum) ]; then
    md5command="md5sum"
else
    echo "Could not find md5sum"
    exit 1
fi
echo "{\"md5_result\":\"$(find $1 -type f -exec $md5command {} \; | cut -d' ' -f1 | sort | $md5command)\"}"
