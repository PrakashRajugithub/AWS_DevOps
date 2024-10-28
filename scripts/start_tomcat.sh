#!/bin/bash
if [ "$(whoami)" != "tomcat" ]; then
        echo "Tomcat cannot be started as user: $(whoami). Run as tomcat"
        exit -1
fi
sh /opt/tomcat/bin/startup.sh
TOMCAT_PORT=`netstat -vatn | grep LISTEN | grep 8080 | wc -l`
if [ $TOMCAT_PORT -ne 0 ]; then
echo "Tomcat is not starting"
fi