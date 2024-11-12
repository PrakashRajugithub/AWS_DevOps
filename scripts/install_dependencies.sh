#!/bin/bash

set -e

sudo wget https://aws-codedeploy-ap-southeast-1.s3.amazonaws.com/latest/install
sudo chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start
sudo service codedeploy-agent enable

CATALINA_HOME=/opt/tomcat
TOMCAT_VERSION=9.0.97

# Tar file name
TOMCAT9_CORE_TAR_FILENAME="apache-tomcat-$TOMCAT_VERSION.tar.gz"
# Download URL for TOMCAT9 core
TOMCAT9_CORE_DOWNLOAD_URL="https://dlcdn.apache.org/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/$TOMCAT9_CORE_TAR_FILENAME"
# The top-level directory after unpacking the tar file
TOMCAT9_CORE_UNPACKED_DIRNAME="apache-tomcat-$TOMCAT_VERSION"


# Check whether there exists a valid instance
# of TOMCAT9 installed at the specified directory
[[ -d $CATALINA_HOME ]] && { service TOMCAT9 status; } && {
    echo "TOMCAT9 is already installed at $CATALINA_HOME. Skip reinstalling it."
    exit 0
}

# Clear install directory
if [ -d $CATALINA_HOME ]; then
    rm -rf $CATALINA_HOME
fi
mkdir -p $CATALINA_HOME

# Download the latest TOMCAT9 version
cd /tmp
{ which wget; } || { yum install wget; }
wget $TOMCAT9_CORE_DOWNLOAD_URL
if [[ -d /tmp/$TOMCAT9_CORE_UNPACKED_DIRNAME ]]; then
    rm -rf /tmp/$TOMCAT9_CORE_UNPACKED_DIRNAME
fi
tar xzf $TOMCAT9_CORE_TAR_FILENAME

# Copy over to the CATALINA_HOME
cp -r /tmp/$TOMCAT9_CORE_UNPACKED_DIRNAME/* $CATALINA_HOME

# Install Java if not yet installed
{ which java; } || { yum install java; }

# Create the service init.d script
cat > /etc/init.d/TOMCAT9 <<'EOF'
#!/bin/bash
# description: TOMCAT9 Start Stop Restart
# processname: TOMCAT9
PATH=$JAVA_HOME/bin:$PATH
export PATH
CATALINA_HOME='/opt/tomcat'

case $1 in
start)
sh $CATALINA_HOME/bin/startup.sh
;;
stop)
sh $CATALINA_HOME/bin/shutdown.sh
;;
restart)
sh $CATALINA_HOME/bin/shutdown.sh
sh $CATALINA_HOME/bin/startup.sh
;;
esac
exit 0
EOF

# Change permission mode for the service script
chmod 755 /etc/init.d/TOMCAT9
chmod 755 $CATALINA_HOME/bin/*.sh
chown -R tomcat:tomcat $CATALINA_HOME/*