#!/bin/bash -e

req="$1"

if [ "$req" == "last" ]; then ask="times"; fi
if [ "$req" == "prev" ]; then ask="index is"; fi
if [ -z "$ask" ]; then
    echo "Wrong request: $req"
    exit 101
fi
echo $(grep "${ask}" /etc/app/app.log | tail -1 | egrep -o '[0-9]+' | tail -1)
exit 0
