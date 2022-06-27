#!/bin/bash

#[ ! -d /home/ubuntu/logicmonitor ] && exit -1

cd /home/ubuntu/logicmonitor/

git clone https://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@github.com/gsmahajan/heimdall.git

cd heimdall/apps/java/

mvn clean package

[[ ! -d target ]] && echo "code not compiled over machine, abort" && exit -33
