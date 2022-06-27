#!/bin/bash

#[ ! -d /home/ubuntu/logicmonitor ] && exit -1

cd /home/ubuntu/logicmonitor/

git clone https://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@github.com/gsmahajan/heimdall.git

cd heimdall/apps/java/

mvn clean package

[[ ! -d target ]] && echo "code not compiled over machine, abort" && exit -33
