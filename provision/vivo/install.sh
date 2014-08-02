#!/bin/bash
#
#
#Install VIVO.
#
#
#VIVO install location
APPDIR=/usr/local/vivo
#Github branch for VIVO and Vitro to install.
BRANCH=maint-rel-1.7
#Data directory - Solr index and VIVO application files will be stored here.
#If this is changed, you need to adjust the bath in build.properties as well.
DATADIR=/usr/local/vdata
#Tomcat webapp dir
WEBAPPDIR=/var/lib/tomcat7/webapps
#Database
VIVO_DATABASE=vivo17dev

echo "Installing VIVO branch $BRANCH at $APPDIR"

#create VIVO mysql database
mysql -uroot -pvivo -e "CREATE DATABASE IF NOT EXISTS $VIVO_DATABASE DEFAULT CHARACTER SET utf8;"

#Make data directory
sudo mkdir -p $DATADIR

#If we can't find build.xml in the VIVO dir then check out the
#three tiered build template from Github
if [ ! -f "$APPDIR/build.xml" ]; then
    echo "Checking VIVO and Vitro out from Github."
    #Recreate app dir and set permissions.
    sudo rm -rf $APPDIR
    mkdir -p $APPDIR
    sudo chown -R $USER:$USER $APPDIR
    cd $APPDIR
    #Checkout from Github.
    git clone https://github.com/lawlesst/vivo-project-template.git .
    git submodule init
    git submodule update
    cd VIVO/
    git checkout $BRANCH
    cd ../Vitro
    git checkout $BRANCH
    cd ..
else
    echo "VIVO and Vitro source code exists.  Not pulling from Github."
fi

#Setup permissions and switch to app dir.
sudo chown -R $USER:$USER $APPDIR
sudo chown -R $USER:$USER $DATADIR

#Copy build properties into app directory
cp /home/$USER/provision/vivo/build.properties $APPDIR/.
#Copy runtime properties into data directory
cp /home/$USER/provision/vivo/runtime.properties $DATADIR/.

#Stop tomcat
sudo /etc/init.d/tomcat7 stop

cd $APPDIR
#In development, you might want to remove these ontology and data files
#since they slow down Tomcat restarts considerably.
# rm -f VIVO/rdf/tbox/filegraph/geo-political.owl
# rm -f VIVO/rdf/abox/filegraph/continents.n3
# rm -f VIVO/rdf/abox/filegraph/us-states.rdf
# rm -f VIVO/rdf/abox/filegraph/geopolitical.abox.ver1.1-11-18-11.owl

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

#Add redirect to /vivo in tomcat root
sudo rm -f $WEBAPPDIR/ROOT/index.html
sudo cp /home/$USER/provision/vivo/index.jsp $WEBAPPDIR/ROOT/index.jsp

#Start Tomcat
sudo /etc/init.d/tomcat7 start

#Append defaults to .bashrc
#Alias for viewing VIVO log
VLOG="alias vlog='less +F /usr/share/tomcat7/logs/vivo.all.log'"
BASHRC=/home/$USER/.bashrc

if grep "$VLOG" $BASHRC > /dev/null
then
   echo "log alias exists"
else
   (echo;  echo $VLOG)>> $BASHRC
   echo "log alias created"
fi

echo "VIVO provisioned."
