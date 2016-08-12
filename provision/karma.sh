#!/bin/bash
set -e

#
#To install Karma `sudo karma.sh install`
#To start Karma `karma.sh start`
#

#Port KARMA runs on.  VIVO uses port 8080 so use alternate.
KARMA_PORT="8000"
KARMA_HOME="/home/vagrant/karma"

# Karma source settings.  Shouldn't have to change.
KARMA_URL="https://github.com/InformationIntegrationGroup/Web-Karma/archive/master.zip"
#this is the name of the zip file that is unpacked
KARMA_NAME="Web-Karma-master"


if [ "$1" = "install" ]
then
  echo Installing Karma to $KARMA_HOME

  #install maven
  apt-get install maven

  PWD=`pwd`
  TMPFILE=`tempfile`
  mkdir -p $KARMA_HOME

  #Get Karma source.
  wget "$KARMA_URL" -O $TMPFILE
  unzip $TMPFILE -d $KARMA_HOME
  rm $TMPFILE

  #Move unzipped karma dir to karma home
  cd $KARMA_HOME
  mv $KARMA_NAME/* .
  rm -r $KARMA_NAME

  #Run maven install
  mvn clean install
  cd $PWD

  #change owner of karma directory to vagrant
  chown -R vagrant:vagrant $KARMA_HOME

elif [ "$1" = "start" ]
then
    echo Starting Karma
    cd $KARMA_HOME
    cd karma-web
    mvn jetty:run -Djetty.port=$KARMA_PORT
else
    echo "No options passed.  Doing nothing."
    echo "Options are ./karma.sh start|install"
fi