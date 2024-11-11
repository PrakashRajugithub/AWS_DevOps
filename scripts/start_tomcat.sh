#!/bin/bash
if [ "$(whoami)" != "tomcat" ]; then
        echo "Tomcat cannot be started as user: $(whoami). Run as tomcat"
        exit -1
fi
sh /opt/tomcat/bin/startup.sh
TOMCAT=`ps -ef|grep 'catalina.base=/opt/tomcat/'|wc -l`
if [ $TOMCAT -ne 0 ]; then
echo "Tomcat is not starting"
fi