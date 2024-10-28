#!/bin/bash
f_date=`date '+%d%m%y'`
mkdir -p /opt/tomcat/WAR_BACKUP/$f_date
mv /opt/tomcat/webapps/sparkjava-hello*.war /opt/tomcat/WAR_BACKUP/$f_date/
rm -rf /opt/tomcat/webapps/sparkjava-hello*
cp /home/tomcat/deploy/hcpnapi.war /opt/tomcat/webapps/