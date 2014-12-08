#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
set -e # Exit script immediately on first error.
set -x # Print commands and their arguments as they are executed.

#Update Ubuntu packages. Comment out during development
sudo apt-get update -y

#Set time zone
area="America"
zone="New_York"
sudo echo "$area/$zone" > /tmp/timezone
sudo cp -f /tmp/timezone /etc/timezone
sudo cp -f /usr/share/zoneinfo/$area/$zone /etc/localtime

# Basics.
sudo apt-get install -y git-core mercurial vim screen wget curl raptor-utils unzip

# Web server
sudo apt-get install -y apache2

# Install Oracle Java 7 which best supports Java Advanced Imaging (JAI),
# or uncomment line below and comment out other 6 lines to install OpenJDK7 instead
#sudo apt-get install -y openjdk-7-jdk
sudo apt-get install python-software-properties -y
sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update -y
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get install oracle-java7-installer -y

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

# Instal AllegroGraph
echo "Installing AllegroGraph"
sudo apt-get install python-cjson python-pycurl
sudo wget http://franz.com/ftp/pri/acl/ag/ag4.14.1/linuxamd64.64/agraph-4.14.1-linuxamd64.64.tar.gz /home/vagrant/provision
sudo cd /home/vagrant/provision
sudo tar zxf agraph-4.14.1-linuxamd64.64.tar.gz
sudo mkdir -p /mnt/src/agraph-4.14.1
sudo agraph-4.14.1/install-agraph /mnt/src/agraph-4.14.1
sudo /mnt/src/agraph-4.14.1/bin/agraph-control --config /mnt/src/agraph-4.14.1/lib/agraph.cfg start

#Call VIVO install
source /home/vagrant/provision/vivo/install.sh

#Append defaults to .bashrc
#Alias for viewing VIVO log
VLOG="alias vlog='less +F /usr/share/tomcat7/logs/vivo.all.log'"
BASHRC=/home/vagrant/.bashrc

if grep "$VLOG" $BASHRC > /dev/null
then
   echo "log alias exists"
else
   (echo;  echo $VLOG)>> $BASHRC
   echo "log alias created"
fi

echo Box provisioned.

exit

