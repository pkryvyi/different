#!bin/bash

set -v

JAVA_VERSION=1.8.0
TOMCAT_INSTALL_DIR=/opt/tomcat
TOMCAT_VERSION=7.0.91
MAJOR_TOMCAT_VERSION=tomcat-7

#Install java
yum install -y java-${JAVA_VERSION}-openjdk-devel httpd

#Create tomcat group and user
groupadd tomcat
useradd -M -s /bin/nologin -g tomcat -d ${TOMCAT_INSTALL_DIR} tomcat

#Download and unarchive tomcat
curl -O -L http://www-us.apache.org/dist/tomcat/${MAJOR_TOMCAT_VERSION}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
mkdir -p ${TOMCAT_INSTALL_DIR}
tar xvf apache-${MAJOR_TOMCAT_VERSION}*tar.gz -C ${TOMCAT_INSTALL_DIR} --strip-components=1

#Give permissions and change owner
chown -R tomcat:tomcat ${TOMCAT_INSTALL_DIR}
chmod -R g+r ${TOMCAT_INSTALL_DIR}/conf
chmod g+x ${TOMCAT_INSTALL_DIR}/conf
chown -R tomcat ${TOMCAT_INSTALL_DIR}/webapps ${TOMCAT_INSTALL_DIR}/temp ${TOMCAT_INSTALL_DIR}/logs

#Run tomcat as Linux service
cat << EOF > /etc/systemd/system/tomcat.service
# Systemd unit file for tomcat
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_PID=${TOMCAT_INSTALL_DIR}/temp/tomcat.pid
Environment=CATALINA_HOME=${TOMCAT_INSTALL_DIR}
Environment=CATALINA_BASE=${TOMCAT_INSTALL_DIR}
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=${TOMCAT_INSTALL_DIR}/bin/startup.sh
ExecStop=${TOMCAT_INSTALL_DIR}/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

#Create user
cat << EOF > ${TOMCAT_INSTALL_DIR}/conf/tomcat-users.xml 
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
 <user username="admin" password="password" roles="manager-gui,admin-gui"/>
 </tomcat-users>
EOF

#Enable and start services
systemctl daemon-reload
systemctl enable httpd.service
systemctl start httpd.service
systemctl enable tomcat
systemctl start tomcat
