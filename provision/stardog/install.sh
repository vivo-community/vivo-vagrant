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

#Setup permissions and switch to app dir.
sudo chown -R vagrant:vagrant $APPDIR

#copy stardog libraries
cp -r /home/vagrant/provision/stardog/stardog_dist/* $APPDIR

#Copy license 
cp /home/vagrant/provision/stardog/stardog-license-key.bin $DATADIR

cd $APPDIR
export STARDOG_HOME=$DATADIR

#have to start the server with security disabled
#since vivo does not allow you to provide credentials
./bin/stardog-admin server start --disable-security

#create vivo DB 
./bin/stardog-admin db create -n vivo
