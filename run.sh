#! /bin/bash


#                              #     #                                     #     #                                             
#        ####   ####  #  ####  ##   ##  ####  #    # # #####  ####  #####  #     # ###### # #    # #####    ##   #      #      
#       #    # #    # # #    # # # # # #    # ##   # #   #   #    # #    # #     # #      # ##  ## #    #  #  #  #      #      
#       #    # #      # #      #  #  # #    # # #  # #   #   #    # #    # ####### #####  # # ## # #    # #    # #      #      
#       #    # #  ### # #      #     # #    # #  # # #   #   #    # #####  #     # #      # #    # #    # ###### #      #      
#       #    # #    # # #    # #     # #    # #   ## #   #   #    # #   #  #     # #      # #    # #    # #    # #      #      
#######  ####   ####  #  ####  #     #  ####  #    # #   #    ####  #    # #     # ###### # #    # #####  #    # ###### ###### 
                                                                                                                               
# @Copyright LogicMonitor India LLP, 2022

HOME_DIR="/home/ubuntu/logicmonitor/heimdall";
#HOME_DIR="/Users/girishmahajan/dev/heimdall";

[ ! -d "$HOME_DIR" ] && echo "directory not present, aborting $HOME_DIR" && exit -1;

[ "$#" -eq "0" ] && echo "abort no namespace given" && exit -35
echo "GO GO GO GO"
. $HOME_DIR/bin/functions.sh
 
cd $HOME_DIR


function build_java {
 cd $HOME_DIR/apps/java/
 mvn clean package
 cd -
 for dir in $(ls); 
  do 
  cd $HOME_DIR/webapps/java_apps/$dir; 
  cp $HOME_DIR/lib/opentelemetry*.jar target/; cd $HOME_DIR; done
}

function patch_template {

local hostalias="$1"
local port="$2"
local app_name="$3"
local app_ip="$4"
#local endpoint="$5"
local app_dir="$5"
local appnamespace="$6"

cd ../

sed -e "s/###app_name_host_alias###/$hostalias/g" target/template_lmotel_java.txt > target/template_lmotel_java1.txt
sed -e "s/###app_name###/$app_name/g" target/template_lmotel_java1.txt > target/template_lmotel_java2.txt
sed -e "s/###app_ip###/$app_ip/g" target/template_lmotel_java2.txt > target/template_lmotel_java3.txt
#sed -e "s/###otlp_endpoint###/$endpoint/g" target/template_lmotel_java3.txt > target/template_lmotel_java4.txt
sed -e "s/###app_port###/$port/g" target/template_lmotel_java3.txt > target/template_lmotel_java4.txt
sed -e "s/###app_namspace###/$appnamespace/g" target/template_lmotel_java4.txt > target/template_lmotel_java5.txt


echo "cd $app_dir" > target/startup.sh
echo "" >> target/startup.sh
echo "#generated at $(date +%D_%T)" >> target/startup.sh

cat target/template_lmotel_java5.txt >> target/startup.sh

}

function launch_java {
  cd $HOME_DIR/webapps/java_apps
 local namespace="$1"
 #killall java 
 build_java
  
 
  for dir in $(ls webapps/java_apps); 
  do 
   cd $HOME_DIR/webapps/java_apps/$dir/target/; 
   
   cp $HOME_DIR/conf/template_lmotel_java.txt .
   
   local port=$(cat $HOME_DIR/conf/services.txt | grep $dir | sed -e 's/.*#//g')
   local host_alias="$(echo $(echo $dir | tr '[:upper:]' '[:lower:]')_dc_$port)"
   local app_name="$(echo $dir | tr '[:upper:]' '[:lower:]')"
   local app_ip="$(echo $port | sed 's/^...//')"
  # local otlp_endpoint="http\://192\.168\.43\.71\:55680"
   local app_dir=$(echo $HOME_DIR/webapps/java_apps/$dir/target/) 
   patch_template $host_alias $port $app_name $app_ip $app_dir #$otlp_endpoint $namespace
   cd target 
   chmod 755 startup.sh; 
   ./startup.sh >> $HOME_DIR/logs/$(echo "$dir" | tr '[:upper:]' '[:lower:]').log 2>&1 &  
   sleep 4
 done

 #fire 
 fire
}

function createServicesDirectory {
 
 for dir in $(cat conf/$1.txt | head -20); do cp -r $HOME_DIR/apps/java $HOME_DIR/webapps/java_apps/$(echo $dir | sed -e 's/.*://g' | sed -e 's/#.*//g'); done
}

function createServicesDirectory1 {
  for dir in $(cat conf/$1.txt); 
  do 
      [[ "$dir" =~ ".*java:.*" ]] && cp -r $HOME_DIR/apps/java $HOME_DIR/webapps/java_apps/$(echo $dir | sed -e 's/.*://g' | sed -e 's/#.*//g'); 
      [[ "$dir" =~ ".*python:.*" ]] && cp -r apps/python webapps/python_apps/$(echo $dir | sed -e 's/.*://g' | sed -e 's/#.*//g'); 
      [[ "$dir" =~ ".*go:.*" ]] && cp -r apps/go webapps/go_apps/$(echo $dir | sed -e 's/.*://g' | sed -e 's/#.*//g'); 
      [[ "$dir" =~ ".*nodejs:.*" ]] && cp -r apps/nodejs webapps/nodejs_apps/$(echo $dir | sed -e 's/.*://g' | sed -e 's/#.*//g'); 
      [[ "$dir" =~ ".*dotnet:.*" ]] && cp -r apps/dotnet webapps/dotnet_apps/$(echo $dir | sed -e 's/.*://g' | sed -e 's/#.*//g'); 
      [[ "$dir" =~ ".*ruby:.*" ]] && cp -r apps/ruby webapps/ruby_apps/$(echo $dir | sed -e 's/.*://g' | sed -e 's/#.*//g'); 
  done 
    
}



function cleanup {
  [ -d webapps ] && rm -rf webapps* && mv webapps webapps_$(date +%s | sed -e 's/://g')
  [ -d logs ] && rm -rf logs
  mkdir webapps
  cd webapps
  mkdir -p java_apps python_apps go_apps nodejs_apps ruby_apps dotnet_apps
  mkdir ../logs
  cd ../
}


function start {
   
   $HOME_DIR/start_lmotel.sh
   cleanup
   
   createServicesDirectory "$1"
   launch_java "$1"
}

start "$1"
