#!/bin/bash

#
# Setup the base box
#
set -o verbose
#Exit on first error
set -e

# Add vagrant user and group
groupadd vagrant || echo "vagrant group exists"
useradd -g vagrant vagrant || echo "vagrant user exists in group vagrant"

#Update Ubuntu packages. Comment out during development
apt-get update -y

#Set time zone
area="America"
zone="New_York"
echo "$area/$zone" > /tmp/timezone
cp -f /tmp/timezone /etc/timezone
cp -f /usr/share/zoneinfo/$area/$zone /etc/localtime

# Basics.
apt-get install -y git vim screen wget curl raptor-utils unzip

# Install open jdk 8
installJava(){
    add-apt-repository ppa:openjdk-r/ppa -y
    apt-get update -y
    apt-get install openjdk-8-jdk -y
}

# Maven
installMaven () {
	cd /usr/local
	rm -rf /usr/bin/mvn
	rm -rf /usr/local/apache-maven-3.3.9
	wget http://mirrors.sonic.net/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
	tar -xvf apache-maven-3.3.9-bin.tar.gz
	ln -s /usr/local/apache-maven-3.3.9/bin/mvn /usr/bin/mvn
}

# Install Tomcat 7 with JAVA_HOME export so Tomcat starts when install completes,
installTomcat () {
	export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
	apt-get install -y tomcat7
	sed -i '/#JAVA_HOME.*$/a JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' /etc/default/tomcat7
}

# MySQL
# echo mysql-server mysql-server/root_password password vivo | debconf-set-selections
# echo mysql-server mysql-server/root_password_again password vivo | debconf-set-selections
# apt-get install -y mysql-server
# apt-get install -y mysql-client



installJava
installMaven
installTomcat

# Make Karma scripts executable
chmod +x /home/vagrant/provision/karma.sh

echo Box boostrapped.

exit

