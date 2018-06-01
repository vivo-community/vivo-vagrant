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
#Data directory - Solr index and VIVO application files will be stored here.
DATADIR=/usr/local/vdata
PROVDIR=/home/vagrant/provision
#Tomcat webapp dir
WEBAPPDIR=/var/lib/tomcat7/webapps

#Make data directory
mkdir -p $DATADIR
#Make config directory
mkdir -p $DATADIR/config
#Make log directory
mkdir -p $DATADIR/logs

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
    cd /home/vagrant/
    rm -rf vivo
    mkdir vivo
    cd vivo
    wget https://github.com/vivo-project/VIVO/releases/download/rel-1.10.0-RC-1/VIVO-rel-1.10.0-RC-1.tar.gz -O vivo.tar.gz
    tar -xvf vivo.tar.gz
    #Copy runtime properties into data directory
    cp $PROVDIR/vivo/runtime.properties $DATADIR/.
    #Copy applicationSetup.n3 from Vitro into data directory
    cp $PROVDIR/vivo/applicationSetup.n3 $DATADIR/config/.
    #Copy log4j config to config directory
    cp $PROVDIR/vivo/log4j.properties webapp/src/main/webResources/WEB-INF/classes/.
    cp $PROVDIR/vivo/settings.xml .
    mvn install -s settings.xml
    chown -R vagrant:tomcat7 ../
    return $TRUE
}


#Stop tomcat
/etc/init.d/tomcat7 stop

# add vagrant to tomcat7 group
if ! id "vagrant" >/dev/null 2>&1; then
  echo "Creating 'vagrant' user"
  adduser --disabled-password --gecos "" vagrant
fi

usermod -a -G tomcat7 vagrant

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

