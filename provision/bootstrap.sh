#!/bin/bash

#
# Setup the base box
#

# Exit on first error
set -e

# Print shell commands
set -o verbose

# Update Ubuntu packages. Comment out during development
apt-get update -y

# Install Java and Maven
apt-get install -y default-jdk maven

# Set time zone
timedatectl set-timezone America/New_York

# Some utils
apt-get install -y git vim screen wget curl raptor-utils unzip

# Install MySQL
installMySQL () {
  DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server
  mysqladmin -u root password vivo
}

# Install Tomcat 8
installTomcat () {
  groupadd tomcat
  useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

  curl -O http://mirrors.sonic.net/apache/tomcat/tomcat-8/v8.5.35/bin/apache-tomcat-8.5.35.tar.gz

  mkdir /opt/tomcat
  tar xzvf apache-tomcat-8.5.35.tar.gz -C /opt/tomcat --strip-components=1

  chgrp -R tomcat /opt/tomcat
  chmod -R g+r /opt/tomcat/conf
  chmod g+x /opt/tomcat/conf
  chown -R tomcat /opt/tomcat/webapps /opt/tomcat/work /opt/tomcat/temp /opt/tomcat/logs

  cp /home/vagrant/provision/tomcat/tomcat.service /etc/systemd/system/tomcat.service

  cp /home/vagrant/provision/tomcat/server.xml /opt/tomcat/conf/server.xml

  cp /home/vagrant/provision/tomcat/context.xml /opt/tomcat/webapps/manager/META-INF/context.xml

  cp /home/vagrant/provision/tomcat/context.xml /opt/tomcat/webapps/host-manager/META-INF/context.xml

  cp /home/vagrant/provision/tomcat/tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml

  systemctl daemon-reload

  systemctl start tomcat
  systemctl enable tomcat
}

# Setup Ubuntu Firewall
setupFirewall () {
  ufw allow 22
  ufw allow 8080
  ufw allow 8081
  ufw allow 8000
  ufw enable
}

installMySQL
installTomcat
setupFirewall

# Make Karma scripts executable
chmod +x /home/vagrant/provision/karma.sh

echo Box boostrapped.

exit

