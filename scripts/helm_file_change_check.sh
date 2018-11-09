#!/bin/bash
echo "{\"md5_result\":\"$(find $1 -type f -exec md5 {} \; | md5)\"}"
