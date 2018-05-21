#!/bin/bash

#
# Setup the base box
#
set -o verbose
#Exit on first error
set -e

#Update Ubuntu packages. Comment out during development
/usr/share/debconf/fix_db.pl
apt-get clean
apt-get -f install
apt-get update -y

#Set time zone
area="America"
zone="Denver"
echo "$area/$zone" > /tmp/timezone
cp -f /tmp/timezone /etc/timezone
cp -f /usr/share/zoneinfo/$area/$zone /etc/localtime

# Basics.
apt-get install -y git vim screen wget curl raptor-utils unzip

# Install open jdk 8
installJava(){
    add-apt-repository ppa:openjdk-r/ppa -y
    apt-get update -y
    apt-get install openjdk-8-jdk -y
}

# Maven
installMaven () {
	cd /usr/local
	rm -rf /usr/bin/mvn
	rm -rf /usr/local/apache-maven-3.3.9
	wget http://mirrors.sonic.net/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
	tar -xvf apache-maven-3.3.9-bin.tar.gz
	ln -s /usr/local/apache-maven-3.3.9/bin/mvn /usr/bin/mvn
}

# Install Tomcat 7 with JAVA_HOME export so Tomcat starts when install completes,
installTomcat () {
	export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
	apt-get install -y tomcat7
	sed -i '/#JAVA_HOME.*$/a JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' /etc/default/tomcat7
}

# MySQL
 echo mysql-server mysql-server/root_password password vivo | debconf-set-selections
 echo mysql-server mysql-server/root_password_again password vivo | debconf-set-selections
 apt-get install -y mysql-server
 apt-get install -y mysql-client



#ca-certificates-java must be explicitly installed as it is needed for maven based installation
#/var/lib/dpkg/info/ca-certificates-java.postinst configure

# Make Karma scripts executable
#chmod +x /home/vagrant/provision/karma.sh

#Need following installed prior to running local VirtualBox additions
apt-get -y install linux-headers-$(uname -r) build-essential dkms
apt-get -y install gcc make perl

# Need to exit, then mount local VirtualBox additions
#echo "Exiting and shutting down so you can mount the VirtualBox additions cd from the virtualbox console"
#echo "hit any key to continue"
#read x

#echo "mounting VBoxLinuxAdditions"
#yes | /mnt/VBoxLinuxAdditions.run

#Install X window manager
echo Installing X
/usr/share/debconf/fix_db.pl
apt-get -q -y -f build-dep dictionaries-common 
apt-get -y install dictionaries-common
#apt-get -q -y -f build-dep virtualbox-ose-guest-utils virtualbox-guest-x11 virtualbox-ose-guest-x11 virtualbox-ose-guest-dkms
#apt-get -y install virtualbox-ose-guest-utils virtualbox-guest-x11 virtualbox-ose-guest-x11 virtualbox-ose-guest-dkms
apt-get -y install xfce4
apt-get -y install virtualbox-guest-dkms


installJava
installMaven
installTomcat

apt-get -y install firefox

cd /tmp
wget http://eclipse.bluemix.net/packages/oxygen.3a/data/eclipse-jee-oxygen-3a-linux-gtk-x86_64.tar.gz
cd /opt
tar -xvzf /tmp/eclipse-jee-oxygen-3a-linux-gtk-x86_64.tar.gz
mv eclipse eclipse-jee-oxygen-3a
ln -s /opt/eclipse-jee-oxygen-3a/eclipse /usr/local/bin/eclipse
cp /home/vagrant/provision/eclipse.desktop /opt/eclipse-jee-oxygen-3a
cd /opt/eclipse-jee-oxygen-3a
desktop-file-install eclipse.desktop 


echo Box boostrapped.

exit

