#!/bin/bash
if [ $(which md5sum) ]; then
    md5command="md5sum"
elif [ $(which md5) ]; then
    md5command="md5"
else
    echo "Could not find md5 or md5sum"
    exit 1
fi

echo "{\"md5_result\":\"$(find $1 -type f -exec $md5command {} \; | $md5command)\"}"
