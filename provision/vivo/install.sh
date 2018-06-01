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
set -o verbose

#
# -- Setup global variables and directories
#
#VIVO install location
APPDIR=/usr/local/
TEMPLATEBASE=vivo
TEMPLATEDIR=${APPDIR}/${TEMPLATEBASE}
#Data directory - Solr index and VIVO application files will be stored here.
DATADIR=${TEMPLATEDIR}/vdata
PROVDIR=/home/vagrant/provision
#Tomcat webapp dir
WEBAPPDIR=/var/lib/tomcat7/webapps
#Database
VIVO_DATABASE=vivo

#Make app directory if it doesn't exist
mkdir -p $APPDIR

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

    #cd to APPDIR, cleanup, checkout template
    cd $APPDIR

    #Remove existing app directory if present.
    rm -rf $TEMPLATEDIR 


    #Checkout three tiered build template from Github
    git clone https://github.com/vivo-community/vivo-project-template.git ${TEMPLATEBASE}
 
    cd ${TEMPLATEBASE}
    git checkout devworkshop-2018
    git submodule init
    git submodule update
    ./setup.sh

    #Setup permissions and switch to TEMPLATEDIR dir.
    cd $APPDIR
    chown -R vagrant:tomcat7 $TEMPLATEDIR

    return $TRUE
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
    cd
    #Change permissions
    dirs=( $DATADIR $WEBAPPDIR/vivo )
    for dir in "${dirs[@]}"
    do
      chown -R vagrant:tomcat7 $dir
      chmod -R g+rws $dir
    done

    #Add redirect to /vivo in tomcat root
    rm -f $WEBAPPDIR/ROOT/index.html
    cp $PROVDIR/vivo/index.jsp $WEBAPPDIR/ROOT/index.jsp

    return $TRUE
}

installVIVO(){
    #Copy runtime properties into data directory
    cp $PROVDIR/vivo/runtime.properties $DATADIR/.
    #Copy applicationSetup.n3 from Vitro into data directory
    cp $PROVDIR/vivo/applicationSetup.n3 $DATADIR/config/.
    #Copy log4j config to config directory
    cd ${TEMPLATEDIR}/custom-vivo
    cp $PROVDIR/vivo/log4j.properties webapp/src/main/webResources/WEB-INF/classes/.
    cp $PROVDIR/vivo/settings.xml .
    mvn install -s settings.xml
    chown -R vagrant:tomcat7 ../
    return $TRUE
}


#Stop tomcat
/etc/init.d/tomcat7 stop

# add vagrant user to passwd file
if ! id "vagrant" >/dev/null 2>&1; then
  echo "Creating 'vagrant' user"
  adduser --disabled-password --gecos "" vagrant
fi

# add vagrant to tomcat7 group
usermod -a -G tomcat7 vagrant

# create VIVO SDB database
createDatabase

#Clone the VIVO 3 tier template
cloneVIVOTemplate

# install the app
installVIVO

#Adjust tomcat permissions
setupTomcat

#Set a log alias
setLogAlias

#Start Tomcat
/etc/init.d/tomcat7 start

echo VIVO installed.

exit

