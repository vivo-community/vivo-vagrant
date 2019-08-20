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

# Install Azul Systems OpenJDK 11 (A free OpenJDK with LTS available on Windows, Linux, and Mac.)
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9
apt-add-repository 'deb http://repos.azulsystems.com/ubuntu stable main'
apt-get update -y
apt-get install -y zulu-11

# Install Maven
apt-get install -y maven

# Some utils
apt-get install -y git vim screen wget curl raptor-utils unzip

# Set time zone
timedatectl set-timezone America/New_York

# Install MariaDB
installMySQL () {
  export DEBIAN_FRONTEND=noninteractive
  apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
  add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.2/ubuntu xenial main'
  apt-get update -y
  apt-get install -y mariadb-server mariadb-client
  mysqladmin -u root password vivo
}

# Install Tomcat 9
installTomcat () {
  groupadd tomcat || true
  useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat || true

  curl -O http://mirrors.sonic.net/apache/tomcat/tomcat-9/v9.0.22/bin/apache-tomcat-9.0.22.tar.gz

  mkdir /opt/tomcat || true
  tar xzvf apache-tomcat-9.0.22.tar.gz -C /opt/tomcat --strip-components=1

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

# ca-certificates-java must be explicitly installed as it is needed for maven based installation
/var/lib/dpkg/info/ca-certificates-java.postinst configure

# Make Karma scripts executable
chmod +x /home/vagrant/provision/karma.sh

echo Box boostrapped.

exit

