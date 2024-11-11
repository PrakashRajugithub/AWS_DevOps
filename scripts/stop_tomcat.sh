#!/bin/bash
if [ "$(whoami)" != "tomcat" ]; then
        echo "Tomcat cannot be stopped as user: $(whoami). Run as tomcat"
        exit -1
fi

sh /opt/tomcat/bin/shutdown.sh
SHUTDOWN=`ps -ef|grep 'catalina.base=/opt/tomcat/'|wc -l`
if [ $SHUTDOWN -ne 0 ]; then
echo "Tomcat is running"
else
echo "Tomcat is Stopped"
fi

echo "Cleaning the work directory"
rm -rf /opt/tomcat/work/Catalina/localhost