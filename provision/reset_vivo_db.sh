#!/bin/bash
set -e

#contributed by Darren Weber
#https://github.com/darrenleeweber

cd
sudo service tomcat7 stop 
VIVO_DATABASE=$(grep 'VIVO_DATABASE=' provision/vivo/install.sh | sed s/VIVO.*=// )
mysql -uroot -pvivo -e "DROP DATABASE IF EXISTS $VIVO_DATABASE;"
mysql -uroot -pvivo -e "CREATE DATABASE $VIVO_DATABASE DEFAULT CHARACTER SET utf8;"
sudo service tomcat7 start