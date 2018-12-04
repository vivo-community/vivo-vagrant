#!/bin/bash

#
# Install VIVO.
#

# Exit on first error
set -e

# Print shell commands
set -o verbose

# Make data directory
mkdir -p /opt/vivo
# Make config directory
mkdir -p /opt/vivo/config
# Make log directory
mkdir -p /opt/vivo/logs

removeRDFFiles(){
    # In development, you might want to remove these ontology and data files
    # since they slow down Tomcat restarts considerably.
    rm /opt/vivo/rdf/tbox/filegraph/geo-political.owl
    rm /opt/vivo/rdf/abox/filegraph/continents.n3
    rm /opt/vivo/rdf/abox/filegraph/us-states.rdf
    rm /opt/vivo/rdf/abox/filegraph/geopolitical.abox.ver1.1-11-18-11.owl
    return $TRUE
}

setLogAlias() {
    #Alias for viewing VIVO log
    VLOG="alias vlog='less +F /opt/vivo/logs/vivo.all.log'"
    BASHRC=/home/vagrant/.bashrc

    if grep "$VLOG" $BASHRC > /dev/null
    then
       echo "log alias exists"
    else
       (echo;  echo $VLOG)>> $BASHRC
       echo "log alias created"
    fi
}

setupTomcat() {
    cd
    # Change permissions
    dirs=( /opt/vivo /opt/tomcat/webapps/vivo )
    for dir in "${dirs[@]}"
    do
      chown -R vagrant:tomcat $dir
      chmod -R g+rws $dir
    done

    # Add redirect to /vivo in tomcat root
    rm -f /opt/tomcat/webapps/ROOT/index.html
    cp /home/vagrant/provision/vivo/index.jsp /opt/tomcat/webapps/ROOT/index.jsp
}

setupMySQL() {
  mysql --user=root --password=vivo -e "CREATE DATABASE vivo110dev CHARACTER SET utf8;"
  mysql --user=root --password=vivo -e "GRANT ALL ON vivo110dev.* TO 'vivo'@'localhost' IDENTIFIED BY 'vivo';"
}

installVIVO() {

  echo 'apache           hard    nproc           400' >> /etc/security/limits.conf
  echo 'tomcat           hard    nproc           1500' >> /etc/security/limits.conf

  # Vivo
  cd /home/vagrant/
  git clone https://github.com/vivo-project/Vitro.git Vitro -b rel-1.10-maint
  git clone https://github.com/vivo-project/VIVO.git VIVO -b rel-1.10-maint

  cd VIVO
  mvn install -DskipTests -s /home/vagrant/provision/vivo/settings.xml

  cp /home/vagrant/provision/vivo/runtime.properties /opt/vivo/config/runtime.properties
  cp /home/vagrant/provision/vivo/deploy.properties /opt/vivo/config/deploy.properties
  cp /home/vagrant/provision/vivo/developer.properties /opt/vivo/config/developer.properties
  cp /home/vagrant/provision/vivo/build.properties /opt/vivo/config/build.properties
  cp /home/vagrant/provision/vivo/applicationSetup.n3 /opt/vivo/config/applicationSetup.n3

  chgrp -R tomcat /opt/vivo
  chown -R tomcat /opt/vivo

  systemctl restart tomcat
}

# Stop tomcat
systemctl stop tomcat

# add vagrant to tomcat group
if ! id "vagrant" >/dev/null 2>&1; then
  echo "Creating 'vagrant' user"
  adduser --disabled-password --gecos "" vagrant
fi
usermod -a -G tomcat vagrant

# create VIVO database
setupMySQL

# install the app
installVIVO

# Adjust tomcat permissions
setupTomcat

# Set a log alias
setLogAlias

# Stop tomcat
systemctl start tomcat

echo VIVO installed.

exit

