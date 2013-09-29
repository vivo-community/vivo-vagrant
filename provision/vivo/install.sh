#!/bin/bash
#
#
#Install VIVO.
#
#
#VIVO install location - this needs to match your deploy.properties file.
APPDIR=/usr/local/vivo
#Data directory - Solr index will be stored here.
DATADIR=/usr/local/vdata

#VIVO will be installed in APPDIR.  You might want to put this
#in a shared folder so that the files can be edited from the
#host machine.  Buidling VIVO on Windows via the shared file
#system was very slow.  See
#http://docs.vagrantup.com/v2/synced-folders/nfs.html

#Remove existing app directory if present.
sudo rm -rf $APPDIR

#remove existing VIVO database
mysql -uroot -pvivo -e "DROP DATABASE IF EXISTS vivodev;"
#create vivo database
mysql -uroot -pvivo -e "CREATE DATABASE IF NOT EXISTS vivodev DEFAULT CHARACTER SET utf8;"

#Make app directory
sudo mkdir -p $APPDIR
#Make data directory
sudo mkdir -p $DATADIR

#Setup permissions and switch to app dir.
sudo chown -R vagrant:vagrant $APPDIR
cd $APPDIR

#Checkout three tiered build template from Github
git clone https://github.com/lawlesst/vivo-project-template.git .
git submodule init
git submodule update
cd VIVO/
git checkout maint-rel-1.5
cd ../Vitro
git checkout maint-rel-1.5
cd ..

#Copy deploy properties into app directory
cp /home/vagrant/provision/vivo/deploy.properties $APPDIR/.

#Stop tomcat
sudo /etc/init.d/tomcat7 stop

#In development, you might want to remove these ontology and data files
#since they slow down Tomcat restarts considerably.
rm VIVO/productMods/WEB-INF/filegraph/tbox/geopolitical.tbox.ver1.1-11-18-11.owl
rm VIVO/productMods/WEB-INF/filegraph/abox/continents.n3
rm VIVO/productMods/WEB-INF/filegraph/abox/us-states.rdf
rm VIVO/productMods/WEB-INF/filegraph/abox/geopolitical.abox.ver1.1-11-18-11.owl

#Build VIVO
sudo ant all

# VIVO log directory
sudo mkdir -p /usr/share/tomcat7/logs/
sudo touch /usr/share/tomcat7/logs/vivo.all.log

#Add directories not created by VIVO build process.
sudo mkdir -p /var/lib/tomcat7/webapps/vivo/WEB-INF/ontologies/update/changedData/
sudo mkdir -p /var/lib/tomcat7/webapps/vivo/WEB-INF/ontologies/update/logs

#Change some permissions
sudo chown -R tomcat7:tomcat7 /usr/share/tomcat7/logs/
sudo chown -R tomcat7:tomcat7 $DATADIR
sudo chown -R tomcat7:tomcat7 /var/lib/tomcat7/webapps/vivo/

sudo /etc/init.d/tomcat7 start
