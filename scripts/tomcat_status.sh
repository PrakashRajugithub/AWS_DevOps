TOMCAT=`ps -ef|grep 'catalina.base=/opt/tomcat/'|wc -l`
if [ $TOMCAT -ne 0 ]; then
echo "Tomcat is not starting"
fi