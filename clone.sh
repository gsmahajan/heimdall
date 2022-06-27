#!/bin/bash

[ ! -d /home/ubuntu/logicmonitor ] && exit -1

cd /home/ubuntu/logicmonitor/

git clone https://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@github.com/gsmahajan/heimdall.git

cd heimdall 

mvn clean package

[[ ! -d target ]] && echo "code not compiled over machine, abort" && exit -33
