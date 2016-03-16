#!/bin/bash

#
# Setup the base box
#

export DEBIAN_FRONTEND=noninteractive
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

# Web server
apt-get install -y apache2

# Install Oracle Java 7 which best supports Java Advanced Imaging (JAI),
# or uncomment line below and comment out other 6 lines to install OpenJDK7 instead
#apt-get install -y openjdk-7-jdk
apt-get install python-software-properties -y
add-apt-repository ppa:webupd8team/java -y
apt-get update -y
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
apt-get install oracle-java7-installer -y

# Install Tomcat 7 with JAVA_HOME export so Tomcat starts when install completes,
# and then patch /etc/default/tomcat7 to specify Oracle Java 7
export JAVA_HOME=/usr/lib/jvm/java-7-oracle
apt-get install -y tomcat7 ant
sed -i '/#JAVA_HOME.*$/a JAVA_HOME=/usr/lib/jvm/java-7-oracle/' /etc/default/tomcat7

# MySQL
echo mysql-server mysql-server/root_password password vivo | debconf-set-selections
echo mysql-server mysql-server/root_password_again password vivo | debconf-set-selections
apt-get install -y mysql-server
apt-get install -y mysql-client

echo Box boostrapped.

exit

