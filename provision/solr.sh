#!/bin/bash

#
# Setup Solr
#

# Exit on first error
set -e

# Print shell commands
set -o verbose

# Install Solr 8.2.0
installSolr () {

  echo '*           soft    nofile           65000' >> /etc/security/limits.conf
  echo '*           hard    nproc           65000' >> /etc/security/limits.conf

  curl -O http://archive.apache.org/dist/lucene/solr/8.2.0/solr-8.2.0.tgz

  mkdir /opt/solr || true
  tar xzvf solr-8.2.0.tgz -C /opt/solr --strip-components=1

  mkdir -p /opt/solr/server/solr || true
  
  cd /home/vagrant
  git clone https://github.com/vivo-community/vivo-solr.git vivo-solr || true
  cp -R vivo-solr/vivocore /opt/solr/server/solr

  /opt/solr/bin/solr start -force
  /opt/solr/bin/solr stop

  rm /opt/solr/server/solr/vivocore/conf/schema.xml || true 
  
  /opt/solr/bin/solr start -force
}

installSolr

echo Solr installed.

exit

