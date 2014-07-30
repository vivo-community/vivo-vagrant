#!/bin/bash
#
#
#Install VIVO.
#
#
#VIVO install location
APPDIR=/usr/local/vivo
#Data directory - Solr index and VIVO application files will be stored here.
DATADIR=/usr/local/vdata
#Tomcat webapp dir
WEBAPPDIR=/var/lib/tomcat7/webapps
#Database
VIVO_DATABASE=vivo17dev

#VIVO will be installed in APPDIR.  You might want to put this
#in a shared folder so that the files can be edited from the
#host machine.  Building VIVO via the shared file
#system can be very slow, at least with Windows.  See
#http://docs.vagrantup.com/v2/synced-folders/nfs.html

#Remove existing app directory if present.
sudo rm -rf $APPDIR

#create VIVO mysql database
mysql -uroot -pvivo -e "CREATE DATABASE IF NOT EXISTS $VIVO_DATABASE DEFAULT CHARACTER SET utf8;"

#Make app directory
sudo mkdir -p $APPDIR
#Make data directory
sudo mkdir -p $DATADIR

#Setup permissions and switch to app dir.
sudo chown -R $USER:$USER $APPDIR
sudo chown -R $USER:$USER $DATADIR
cd $APPDIR

#Checkout three tiered build template from Github
git clone https://github.com/lawlesst/vivo-project-template.git .
git submodule init
git submodule update
cd VIVO/
git checkout maint-rel-1.7
cd ../Vitro
git checkout maint-rel-1.7
cd ..

#Copy build properties into app directory
cp /home/$USER/provision/vivo/build.properties $APPDIR/.
#Copy runtime properties into data directory
cp /home/$USER/provision/vivo/runtime.properties $DATADIR/.

#Stop tomcat
sudo /etc/init.d/tomcat7 stop

#In development, you might want to remove these ontology and data files
#since they slow down Tomcat restarts considerably.
# rm VIVO/rdf/tbox/filegraph/geo-political.owl
# rm VIVO/rdf/abox/filegraph/continents.n3
# rm VIVO/rdf/abox/filegraph/us-states.rdf
# rm VIVO/rdf/abox/filegraph/geopolitical.abox.ver1.1-11-18-11.owl

#Build VIVO
#Disable tests with -Dskiptests=true
sudo ant all

# VIVO log directory
sudo mkdir -p /usr/share/tomcat7/logs/
sudo touch /usr/share/tomcat7/logs/vivo.all.log

#Change permissions
sudo chown -R tomcat7:tomcat7 /usr/share/tomcat7/logs/
sudo chown -R tomcat7:tomcat7 $DATADIR
sudo chown -R tomcat7:tomcat7 $WEBAPPDIR/vivo/

#Add redicrect to /vivo in tomcat root
sudo rm -f $WEBAPPDIR/ROOT/index.html
sudo cp /home/$USER/provision/vivo/index.jsp $WEBAPPDIR/ROOT/index.jsp

#Start Tomcat
sudo /etc/init.d/tomcat7 start
