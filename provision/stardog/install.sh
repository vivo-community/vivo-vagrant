#!/bin/bash
#
#
# Install Stardog
#
#
# Stardog install location
APPDIR=/usr/local/stardog
#Data directory
DATADIR=/usr/local/stardog/data

#Remove existing app directory if present.
sudo rm -rf $APPDIR

#Make app directory
sudo mkdir -p $APPDIR

#Make data directory
sudo mkdir -p $DATADIR

#Setup permissions and switch to app dir.
sudo chown -R vagrant:vagrant $APPDIR

# unzip and copy stardog libraries
unzip /home/vagrant/provision/stardog/stardog-2.2.2.zip -d /home/vagrant/provision/stardog
mv /home/vagrant/provision/stardog/stardog-2.2.2/* $APPDIR

# Copy license 
cp /home/vagrant/provision/stardog/stardog-license-key.bin $DATADIR
cp /home/vagrant/provision/stardog/stardog.properties $DATADIR

cd $APPDIR
export STARDOG_HOME=$DATADIR

#have to start the server with security disabled
#since vivo does not allow you to provide credentials
./bin/stardog-admin server start --disable-security

#create vivo DB 
./bin/stardog-admin db create -n vivo
