#!/bin/bash

cd /home/ubuntu/logicmonitor/logicmonitor/lmotel/

export LOGICMONITOR_ACCOUNT="qauattraces01"

Date=$(date +%d%m%Y)
#rm -rf *.log

./lmotel --config config.yaml >> logs_$Date.log 2>&1 &


