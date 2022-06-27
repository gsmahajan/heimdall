#! /bin/bash -x

key=/Users/girishmahajan/girish_topology.pem


ssh -i $key ubuntu@logistics cd /home/ubuntu/logicmonitor/heimdall/ && git pull
ssh -i $key ubuntu@automobile cd /home/ubuntu/logicmonitor/heimdall/ && git pull
ssh -i $key ubuntu@pharmacy cd /home/ubuntu/logicmonitor/heimdall/ && git pull


