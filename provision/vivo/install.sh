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
APPDIR=/usr/local/vivo
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


createDatabase() {
    #create VIVO mysql database
    mysql -uroot -pvivo -e "CREATE DATABASE IF NOT EXISTS $VIVO_DATABASE DEFAULT CHARACTER SET utf8;"
}

removeRDFFiles(){
    #In development, you might want to remove these ontology and data files
    #since they slow down Tomcat restarts considerably.
    rm VIVO/rdf/tbox/filegraph/geo-political.owl
    rm VIVO/rdf/abox/filegraph/continents.n3
    rm VIVO/rdf/abox/filegraph/us-states.rdf
    rm VIVO/rdf/abox/filegraph/geopolitical.abox.ver1.1-11-18-11.owl
}


setLogAlias() {
    #Alias for viewing VIVO log
    VLOG="alias vlog='less +F /usr/share/tomcat7/logs/vivo.all.log'"
    BASHRC=/home/vagrant/.bashrc

    if grep "$VLOG" $BASHRC > /dev/null
    then
       echo "log alias exists"
    else
       (echo;  echo $VLOG)>> $BASHRC
       echo "log alias created"
    fi
}


setupTomcat(){
    cd
    #Change permissions
    chown -R vagrant:tomcat7 $DATADIR
    chown -R vagrant:tomcat7 $WEBAPPDIR/vivo/

    chmod -R g+rws $DATADIR
    chmod -R g+rws $WEBAPPDIR

    #Add redirect to /vivo in tomcat root
    rm -f $WEBAPPDIR/ROOT/index.html
    cp $PROVDIR/vivo/index.jsp $WEBAPPDIR/ROOT/index.jsp

    return $TRUE
}

installVIVO(){
    cd
    rm -rf vivo
    mkdir vivo
    cd vivo
    wget https://github.com/vivo-project/VIVO/releases/download/rel-1.9.0-rc1/vivo-1.9.0-rc1.tar.gz -O vivo.tar.gz
    tar -xvf vivo.tar.gz
    #Copy runtime properties into data directory
    cp $PROVDIR/vivo/runtime.properties $DATADIR/.
    #Copy applicationSetup.n3 from Vitro into data directory
    cp $PROVDIR/vivo/applicationSetup.n3 $DATADIR/config/.
    #Copy log4j config to config directory
    cp $PROVDIR/vivo/log4j.properties webapp/src/main/webResources/WEB-INF/classes/.
    cp $PROVDIR/vivo/settings.xml .
    mvn install -s settings.xml
    return $TRUE
}


#Stop tomcat
/etc/init.d/tomcat7 stop

# add vagrant to tomcat7 group
usermod -a -G tomcat7 vagrant

# install the app
installVIVO

#Adjust tomcat permissions
setupTomcat

#Set a log alias
setLogAlias

# Change tomcat options. See http://stackoverflow.com/a/27250730/758157
sed -i 's|JAVA_OPTS=.*|JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -Xmx2048m -XX:MaxPermSize=512m -XX:+UseConcMarkSweepGC"|g' /etc/default/tomcat7

#Start Tomcat
/etc/init.d/tomcat7 start

echo VIVO installed.

exit

