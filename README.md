# VIVO Vagrant

[Vagrant](http://www.vagrantup.com/) configuration and install scripts for running [VIVO](http://vivoweb.org) on a virtual machine, aka [Vagrant box](http://docs.vagrantup.com/v2/boxes.html), running an Ubuntu 64 Precise image.

The virtual machine will boot and install VIVO 1.7 and its dependencies.  This will take several minutes for the initial install.

## Prerequisites
 * [VirtualBox](https://www.virtualbox.org/) or [VMWare Fusion](http://www.vmware.com/products/fusion).
 * [Vagrant](https://docs.vagrantup.com/v2/installation/index.html).
 * Git - if you are new to git, you might want to use the Github desktop client. [Windows](http://windows.github.com/) and [Mac](http://mac.github.com/) versions are available.
 * You must obtain a stardog license and the stardog binaries, and then put it in the `provision/stardog` folder.  You can obtain this [here.](http://stardog.com/)

This Vagrant box is intended for development and experimentation only.  Change default user names and passwords.

## Install the VIVO Vagrant box

~~~
$ git clone https://github.com/lawlesst/vivo-vagrant.git vivo-vagrant
$ cd vivo-vagrant
$ vagrant up
~~~

When the Vagrant provisioning script is complete, the VIVO web application will be available in a browser on the host machine at `http://localhost:8080/vivo`.  You can log into your new VIVO with the default admin user (`vivo_root@school.edu`) and password (`rootPassword`), which are specified in the `/provision/vivo/deploy.properties` source file in this repository.

The source will be installed on the virtual machine at `/usr/local/vivo/`. Mac users can log into your Vagrant box securely using this command from a Terminal session.  Windows users will want to use an SSH utility, e.g. [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html):

~~~
$ vagrant ssh
~~~

Once you are logged in, you can view the default VIVO log output with this command:

~~~
$ vlog
~~~

### Commands / system layout
 * VIVO application: `/usr/local/vivo`.  The source at `/usr/local/vivo` is based off a [3-tier VIVO build template](https://github.com/lawlesst/vivo-project-template) and under git version control.
 * VIVO data directory: `/usr/local/vdata`
 * Tomcat: `/var/lib/tomcat7/`
 * To start/stop Tomcat run `sudo /etc/init.d/tomcat start|stop|restart`.
 * A Vagrant [shared directory](http://docs.vagrantup.com/v2/synced-folders/) is available at `/work` from the box.
 * Use the `vagrant suspend` and `vagrant resume` commands to manage your Vagrant box when not in use or if you plan to restart or shutdown the host system, as opposed to using the VirtualBox or VMWare Fusion admin user interface.

## Updates to VIVO and Vitro code
 * From time to time, updates will be made to the current VIVO or Vitro release.  To make sure your VIVO Vagrant box is running the latest code, login to your box, shutdown Tomcat, and checkout the latest [VIVO](https://github.com/vivo-project/VIVO) and [Vitro](https://github.com/vivo-project/Vitro) code from Github.  For example:

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

 * If you are interested in running VIVO 1.5, you can run checkout the v1.5 branch of this repository.
 ~~~
 $ git clone https://github.com/lawlesst/vivo-vagrant.git vivo-vagrant
 $ cd vivo-vagrant
 $ git checkout v1.5
 $ vagrant up
 ~~~

## Karma
[Karma](http://www.isi.edu/integration/karma/) is a tool for mapping raw data in various formats (CSV, XML, etc) to RDF.  To assist with using Karma to model data for VIVO, a script is included to install Karma and its dependencies.  

To install Karma: run `sudo /home/vagrant/provision/karma.sh install`.  The initial install will take about 10 minutes.  Once it's installed Karma can be started with `/home/vagrant/provision/karma.sh start`.  Karma runs in a web browser and will be available on your machine at `http://localhost:8000/`.

[Violeta Ilik](https://twitter.com/violetailik) has [presented](https://www.youtube.com/watch?v=aBLHGzui0_s) (starting at about 12:30) on how to model data for VIVO with Karma.  More information about Karma can be found in this [tutorial](https://github.com/InformationIntegrationGroup/karma-step-by-step) and on the project's [wiki](https://github.com/InformationIntegrationGroup/Web-Karma/wiki).  

## Stardog

[Stardog](http://stardog.com/) is a fast, commercial triple store.  This vagrant is a proof-of-concept for running VIVO with a Stardog backend.  A couple of notes on what's required to get the two to talk to each other correctly.

 * You will need a license and a local copy  [Stardog](http://stardog.com/).  The zip file is expected to be at `./provision/stardog/stardog-2.2.2.zip'.  
 * The provisioning scripts currently expect Stardog 2.2.2.  If you need to use a different version, you'll need to edit them slightly.
 * VIVO currently has no way to specify authentication parameters for a triple store, so Stardog must be started with security turned off.  This is extremely dangerous in production environments, but can likely be mitigated via proxy authentication (e.g. Apache or NGINX authentication).
 * By default, SPARQL queries that do not specify a specific named graph query only the default graph.  This is most likely the correct way to handle such queries, but VIVO expects these queries to instead use the union of the default and all named graphs.  A slight configuration change is required for Stardog to support this. 
