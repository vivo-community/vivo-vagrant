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

#Copy license 
cp /home/vagrant/provision/stardog/stardog-license-key.bin $DATADIR

#copy stardog libraries
cp -r /home/vagrant/provision/stardog/stardog_dist/* $APPDIR

cd $APPDIR
export STARDOG_HOME=$DATADIR

./bin/stardog-admin server start --disable-security

./bin/stardog-admin db create -n vivo
