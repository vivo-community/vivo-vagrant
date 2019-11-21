#!/bin/bash
set -e

source /home/vagrant/provision/.env

cd

systemctl stop tomcat

# save the database schema (without data)
mysqldump --user=root --single-transaction --no-data $VIVO_DATABASE > "${VIVO_DATABASE}_schema.sql"
# destroy the database
mysql --user=root  -e "DROP DATABASE IF EXISTS $VIVO_DATABASE;"
# recreate the database
mysql --user=root -e "CREATE DATABASE $VIVO_DATABASE DEFAULT CHARACTER SET utf8;"
mysql --user=root -e "GRANT ALL ON $VIVO_DATABASE.* TO 'vivo'@'localhost' IDENTIFIED BY 'vivo';"
mysql --user=root $VIVO_DATABASE < "${VIVO_DATABASE}_schema.sql"

rm -rf /opt/vivo/solr/data

systemctl start tomcat
