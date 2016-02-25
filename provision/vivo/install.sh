#!/bin/bash
#
#
#Install VIVO.
#
#

export DEBIAN_FRONTEND=noninteractive
#Exit on first error
set -e
#Print shell commands
set -x

#
# -- Setup global variables and directories
#
#VIVO install location
APPDIR=/usr/local/vivo
#Data directory - Solr index and VIVO application files will be stored here.
DATADIR=/usr/local/vdata
PROVDIR=/home/vagrant/provision
#Tomcat webapp dir
WEBAPPDIR=/var/lib/tomcat7/webapps
#Database
VIVO_DATABASE=vivo17dev

#Make app directory
mkdir -p $APPDIR
#Make data directory
mkdir -p $DATADIR
#Make config directory
mkdir -p $DATADIR/config
#Make log directory
mkdir -p $DATADIR/logs

createDatabase() {
    #create VIVO mysql database
    mysql -uroot -pvivo -e "CREATE DATABASE IF NOT EXISTS $VIVO_DATABASE DEFAULT CHARACTER SET utf8;"
}

cloneVIVOTemplate(){
    #VIVO will be installed in APPDIR.  You might want to put this
    #in a shared folder so that the files can be edited from the
    #host machine.  Building VIVO via the shared file
    #system can be very slow, at least with Windows.  See
    #http://docs.vagrantup.com/v2/synced-folders/nfs.html

    #Remove existing app directory if present.
    rm -rf $APPDIR && mkdir -p $APPDIR

    #Setup permissions and switch to app dir.
    chown -R vagrant:vagrant $APPDIR
    cd $APPDIR

    #Checkout three tiered build template from Github
    git clone https://github.com/lawlesst/vivo-project-template.git .
    git submodule init
    git submodule update
    cd VIVO/
    git checkout maint-rel-1.8
    cd ../Vitro
    git checkout maint-rel-1.8
    cd ..
    return $TRUE
}

configureBuildVIVO(){
    cd $APPDIR
    #Copy build properties into app directory
    cp $PROVDIR/vivo/build.properties $APPDIR/.
    #Copy runtime properties into data directory
    cp $PROVDIR/vivo/runtime.properties $DATADIR/.
    #Copy applicationSetup.n3 from Vitro into data directory
    cp $PROVDIR/vivo/applicationSetup.n3 $APPDIR/config/applicationSetup.n3
    #Copy log4j config to config directory
    cp $PROVDIR/vivo/log4j.properties $APPDIR/config/.
    #Build VIVO
    ant all -Dskiptests=true
}

removeRDFFiles(){
    #In development, you might want to remove these ontology and data files
    #since they slow down Tomcat restarts considerably.
    rm VIVO/rdf/tbox/filegraph/geo-political.owl
    rm VIVO/rdf/abox/filegraph/continents.n3
    rm VIVO/rdf/abox/filegraph/us-states.rdf
    rm VIVO/rdf/abox/filegraph/geopolitical.abox.ver1.1-11-18-11.owl
    return $TRUE
}


setLogAlias() {
    #Alias for viewing VIVO log
    VLOG="alias vlog='less +F $DATADIR/logs/vivo.all.log'"
    BASHRC=/home/vagrant/.bashrc

    if grep "$VLOG" $BASHRC > /dev/null
    then
       echo "log alias exists"
    else
       (echo;  echo $VLOG)>> $BASHRC
       echo "log alias created"
    fi
    return $TRUE
}


setupTomcat(){
    #Change permissions
    chown -R tomcat7:tomcat7 $DATADIR
    chown -R tomcat7:tomcat7 $WEBAPPDIR/vivo/

    #Add redirect to /vivo in tomcat root
    rm -f $WEBAPPDIR/ROOT/index.html
    cp $PROVDIR/vivo/index.jsp $WEBAPPDIR/ROOT/index.jsp
    return $TRUE
}


#Stop tomcat
/etc/init.d/tomcat7 stop

#Create database
createDatabase

#Checkout and VIVO from project template
#This will take several minutes.
cloneVIVOTemplate

#Copy config files and setup.
configureBuildVIVO

#Adjust tomcat permissions
setupTomcat

#Set a log alias
setLogAlias

#Start Tomcat
/etc/init.d/tomcat7 start

echo VIVO installed.

exit

