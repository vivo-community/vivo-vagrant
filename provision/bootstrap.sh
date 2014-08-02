#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
# Exit script immediately on first error.
# Print commands and their arguments as they are executed.
set -e
set -x

#Update Ubuntu packages. Comment out during development
sudo apt-get update -y

#Set time zone
area="America"
zone="New_York"
sudo echo "$area/$zone" > /tmp/timezone
sudo cp -f /tmp/timezone /etc/timezone
sudo cp -f /usr/share/zoneinfo/$area/$zone /etc/localtime

# Basics.
sudo apt-get install -y git-core vim wget curl subversion htop

# Install Oracle Java 7 which best supports Java Advanced Imaging (JAI),
# or uncomment line below and comment out other 6 lines to install OpenJDK7 instead
#sudo apt-get install -y openjdk-7-jdk
sudo apt-get install python-software-properties -y
sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update -y
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get install oracle-java7-installer -y --quiet

# Install Tomcat 7 with JAVA_HOME export so Tomcat starts when install completes,
# and then patch /etc/default/tomcat7 to specify Oracle Java 7
export JAVA_HOME=/usr/lib/jvm/java-7-oracle
sudo -E apt-get install -y tomcat7 ant
sudo sed -i '/#JAVA_HOME.*$/a JAVA_HOME=/usr/lib/jvm/java-7-oracle/' /etc/default/tomcat7

# MySQL
echo mysql-server mysql-server/root_password password vivo | sudo debconf-set-selections
echo mysql-server mysql-server/root_password_again password vivo | sudo debconf-set-selections
sudo apt-get install -y mysql-server
sudo apt-get install -y mysql-client

exit

