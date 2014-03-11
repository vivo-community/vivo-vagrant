# VIVO Vagrant

[Vagrant](http://www.vagrantup.com/) configuration and install scripts for running [VIVO](http://vivoweb.org) on an Ubuntu 64 Precise image.

The VIVO web application will be available at `http://localhost:8080/vivo`.  The source will be at `/usr/local/vivo/`.

The box will boot and install VIVO 1.6 and dependencies.  This will take several minutes for the initial install.

## Prerequisites
 * [VirtualBox](https://www.virtualbox.org/).
 * [Vagrant](https://docs.vagrantup.com/v2/installation/index.html).
 * Git - if you are new to git, you might want to use the Github desktop client. [Windows](http://windows.github.com/) and [Mac](http://mac.github.com/) are available.

## Install the VIVO Vagrant box

### VIVO 1.6
~~~
$ git clone https://github.com/lawlesst/vivo-vagrant.git vivo-vagrant
$ cd vivo-vagrant
$ vagrant up
~~~

### VIVO 1.5
~~~
$ git clone https://github.com/lawlesst/vivo-vagrant.git vivo-vagrant
$ cd vivo-vagrant
$ git checkout v1.5
$ vagrant up
~~~

## Notes
 * This is intended for development only.  Change passwords if you intend to use this config for deployment.
 * The source at `/usr/local/vivo` is based off a [template](https://github.com/lawlesst/vivo-project-template) and under git
 version control.
 * On older versions of Vagrant it might be necessary to start Vagrant with the `$ vagrant up --no-provision` flag to prevent the VIVO installation script from running each time.
 * Various other development tools, mainly Python, are installed too.  Comment those out if they are not needed.
 * Vagrant supports virtualization utilities other than [VirtualBox](https://www.virtualbox.org/) but this package hasn't been tested with those.  Please report back if you are using another tool with this package.  

## Updates to VIVO and Vitro code
 * From time to time, updates will be made to the current VIVO or Vitro release.  To make sure your VIVO Vagrant box is running the latest code.  Login to your box, shutdown Tomcat, and checkout the latest VIVO and Vitro code from Github.  For example:
 
 ~~~
 $ sudo /etc/init.d/tomcat7 stop
 $ cd /usr/local/vivo
 $ cd VIVO
 $ git pull
 $ cd ../Vitro
 $ git pull
 $ cd ..
 $ sudo ant all
 $ sudo /etc/init.d/tomcat7 start
 ~~~
 * You can also, at anytime, re-provision your Vagrant box.  By running the following from your host machine.  Be sure to backup any data or code changes you have made beforehand.  
 
 ~~~
 $ vagrant up --provision
 ~~~


