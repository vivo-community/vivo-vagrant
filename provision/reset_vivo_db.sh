#!/bin/bash
set -e

#contributed by Darren Weber
#https://github.com/darrenleeweber

cd  # start at $HOME path
sudo service tomcat7 stop
VIVO_DATABASE=$(grep 'VIVO_DATABASE=' provision/vivo/install.sh | sed s/VIVO.*=// )
# save the database schema (without data)
mysqldump -uroot -pvivo --single-transaction --no-data $VIVO_DATABASE > "${VIVO_DATABASE}_schema.sql"
# destroy the database
mysql -uroot -pvivo -e "DROP DATABASE IF EXISTS $VIVO_DATABASE;"
# recreate the database
mysql -uroot -pvivo -e "CREATE DATABASE $VIVO_DATABASE DEFAULT CHARACTER SET utf8;"
mysql -uroot -pvivo $VIVO_DATABASE < "${VIVO_DATABASE}_schema.sql"
# remove solr data so vivo will reindex on startup
sudo rm -rf /usr/local/vdata/solr/data
sudo service tomcat7 start
