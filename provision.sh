#! /bin/bash -x

key=/Users/girishmahajan/girish_topology.pem


if [ "$#" -ge "2" ]; then
ssh -i $key ubuntu@logistics rm -rf /home/ubuntu/logicmonitor/heimdall/
ssh -i $key ubuntu@automobile rm -rf /home/ubuntu/logicmonitor/heimdall/
ssh -i $key ubuntu@pharmacy rm -rf /home/ubuntu/logicmonitor/heimdall/


scp -i $key -r /Users/girishmahajan/dev/heimdall/clone.sh ubuntu@logistics:/home/ubuntu/logicmonitor/
scp -i $key -r /Users/girishmahajan/dev/heimdall/clone.sh ubuntu@automobile:/home/ubuntu/logicmonitor/
scp -i $key -r /Users/girishmahajan/dev/heimdall/clone.sh ubuntu@pharmacy:/home/ubuntu/logicmonitor/


ssh -i $key ubuntu@logistics /home/ubuntu/logicmonitor/clone.sh &
ssh -i $key ubuntu@automobile /home/ubuntu/logicmonitor/clone.sh &
ssh -i $key ubuntu@pharmacy /home/ubuntu/logicmonitor/clone.sh &
fi

sleep 20

if [ "$#" -ge "1" ]; then
	ssh -i $key ubuntu@logistics /home/ubuntu/logicmonitor/heimdall/run.sh logistics
	ssh -i $key ubuntu@automobile /home/ubuntu/logicmonitor/heimdall/run.sh automobile
	ssh -i $key ubuntu@pharmacy /home/ubuntu/logicmonitor/heimdall/run.sh pharmacy
fi
