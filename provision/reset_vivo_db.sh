#!/bin/bash
set -e

cd

systemctl stop tomcat

VIVO_DATABASE=vivo110dev
# save the database schema (without data)
mysqldump --user=root --password=vivo  --single-transaction --no-data $VIVO_DATABASE > "${VIVO_DATABASE}_schema.sql"
# destroy the database
mysql --user=root --password=vivo  -e "DROP DATABASE IF EXISTS $VIVO_DATABASE;"
# recreate the database
mysql --user=root --password=vivo  -e "CREATE DATABASE $VIVO_DATABASE DEFAULT CHARACTER SET utf8;"
mysql --user=root --password=vivo -e "GRANT ALL ON vivo110dev.* TO 'vivo'@'localhost' IDENTIFIED BY 'vivo';"
mysql --user=root --password=vivo  $VIVO_DATABASE < "${VIVO_DATABASE}_schema.sql"

rm -rf /opt/vivo/solr/data

systemctl start tomcat
