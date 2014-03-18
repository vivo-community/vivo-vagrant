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

# Java - install openjdk7 first
sudo apt-get install -y openjdk-7-jdk
sudo apt-get install -y tomcat7 ant

# MySQL
echo mysql-server mysql-server/root_password password vivo | sudo debconf-set-selections
echo mysql-server mysql-server/root_password_again password vivo | sudo debconf-set-selections
sudo apt-get install -y mysql-server
sudo apt-get install -y mysql-client

#Default .bashrc to home directory
cp /home/vagrant/provision/.bashrc /home/vagrant/.

#Call VIVO install
source /home/vagrant/provision/vivo/install.sh

echo Box provisioned.

exit

