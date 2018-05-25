# VIVO Vagrant - v1.9.3

[Vagrant](http://www.vagrantup.com/) configuration and install scripts for running [VIVO](http://vivoweb.org) on a virtual machine, aka [Vagrant box](http://docs.vagrantup.com/v2/boxes.html), running an Ubuntu 64 Server 16.04.3 image.

The virtual machine will boot and install VIVO 1.9,3 and its dependencies.  This will take several minutes for the initial install.
It installs VIVO via installing the VIVO 3 tier template located at: https://github.com/vivo-community/vivo-project-template
If you have questions or encounter problems, please email the VIVO technical list at [vivo-tech@googlegroups.com](https://groups.google.com/forum/#!forum/vivo-tech) or open issue here in the Github issue tracker.

## Purpose
 * This virutal machine creates a standalone VIVO/Vitro development environment
 * It downloads eclipse Oxygen for the IDE
 * It downloads the full github repo for VIVO, Vitro, and a third tier.
 * It installs the XFCE4 desktop gui environment
 
## Prerequisites
 * [VirtualBox](https://www.virtualbox.org/) or [VMWare Fusion](http://www.vmware.com/products/fusion).
 * [Vagrant](https://docs.vagrantup.com/v2/installation/index.html).
 * Git - if you are new to git, you might want to use the Github desktop client. [Windows](http://windows.github.com/) and [Mac](http://mac.github.com/) versions are available.
 * The virtual machine is configured to use 4GB of RAM, so please ensure your system has enough memory to accomodate this
 ( or shutdown most of your running applications prior to using this VM )
 * Sometimes it's necessary to install the vagrant virtualbox guest additions plugin in order to get X11, shared drives, and the bi-directional clipboard to work. Do this in the shell that you will start vagrant. Use this command:
   * $ vagrant plugin update vagrant-vbguest

This Vagrant box is intended for development and experimentation only.  Change default user names and passwords.

## Install the VIVO Vagrant box

~~~
$ vagrant plugin update vagrant-vbguest  ( not completly sure if this is required, but it might help X11 and shared file functions )
$ git clone -b gui-developer-v1.9.3 https://github.com/vivo-community/vivo-vagrant vivo-vagrant   ( note -- this will be the name of your VM, feel free to change the target name as appropriate )
$ cd vivo-vagrant
$ vagrant up
~~~

When the Vagrant provisioning script is complete, the VIVO web application will be available in a browser on the host machine at `http://localhost:8080/vivo`.  You can log into your new VIVO with the default admin user (`vivo_root@school.edu`) and password (`rootPassword`), which are specified in the `/provision/vivo/deploy.properties` source file in this repository.


The vivo application will be at `/usr/local/vivo`. Mac users can log into your Vagrant box securely using this command from a Terminal session.  Windows users will want to use an SSH utility, e.g. [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html):

~~~
$ vagrant ssh
~~~

Once you are logged in, you can view the default VIVO log output with this command:

~~~
$ vlog
~~~

## Starting the GUI and development environment
Go to the VirtualBox console -- This is probably labeled as VirtualBoxVM -- it shoudl have a login prompt and perhaps console messages
On the console - ogin to the system with the user/password = vagrant/vagrant
Start the XFCE desktop with the command 
$ startx

### Changing the display
 * set virtualbox to scaled mode  ( this makes resizing much easier _
   * <right ctrl  C> WINDOWS;   <Command C>  MAC
   * In the XFCE desktop - right click -> Applications -> Settings -> Display 
    * Select a display that suites your display - eg 1400x1040 
    * Click Apply
    
### Applications and issues in the desktop
 * eclipse is installed and can be started with the eclipse command in the terminal
 * firefox is installed and can be started with the firefox command in the terminal
 * There are bugs which prevent cutting and pasting between the guest and host -- please report back if this is resolved.
 
 

### Commands / system layout
 * VIVO application: `/usr/local/vivo`.  -- this is the https://github.com/vivo-community/vivo-project-template repo
 * VIVO data directory: `/usr/local/vivo/vdata`
 * VIVO Ttriple store: Mysql
 * Tomcat: `/var/lib/tomcat7/`
 * To start/stop Tomcat run `sudo /etc/init.d/tomcat start|stop|restart`.
 * A Vagrant [shared directory](http://docs.vagrantup.com/v2/synced-folders/) is available at `/work` from the box.
 * Use the `vagrant suspend` and `vagrant resume` commands to manage your Vagrant box when not in use or if you plan to restart or shutdown the host system, as opposed to using the VirtualBox or VMWare Fusion admin user interface.
 
## Re-provisioning

You can, at anytime, re-provision your Vagrant box.  By running the following from your host machine.  This will reinstall all components of the Vagrant box and reinstall VIVO.  This will destroy any changes you've made to your VIVO installation so be sure to backup any data or code changes you have made beforehand.

 ~~~
 $ vagrant up --provision
 ~~~
 
## Reseting the VIVO database  -- !!!! Below is only for TDB --- need to identify the mysql command up update the DOC
From time to time, you might also want to rollback to a clean VIVO database. This can be done by stopping tomcat and removing the file-based TDB triple store: `rm /usr/local/vdata/tdbContentModels`. Warning - this will delete all of the data you have loaded into VIVO and any ontology changes.

 
## Running previous releases of VIVO and Vitro
If you are interested in running VIVO 1.5, 1.6, 1.7, 1.8 there are separate branches for each of those released version.
 ~~~
 $ git clone https://github.com/lawlesst/vivo-vagrant.git vivo-vagrant
 $ cd vivo-vagrant
 $ git checkout v1.x
 $ vagrant up
 ~~~

## Triplestores

VIVO supports alternate triplestores via SPARQL 1.1.  The vivo-vagrant repository contains installation and configuration scripts for two other triple stores in separate branches.  

 * [Stardog](http://stardog.com) - see the [`stardog`](https://github.com/lawlesst/vivo-vagrant/tree/stardog) branch and README to get started.  
 * [AllegroGraph](http://franz.com/agraph/allegrograph/): see the [`allegrograph`](https://github.com/lawlesst/vivo-vagrant/tree/allegrograph) branch and README to get started.  


## Karma
[Karma](http://www.isi.edu/integration/karma/) is a tool for mapping raw data in various formats (CSV, XML, etc) to RDF.  To assist with using Karma to model data for VIVO, a script is included to install Karma and its dependencies.  

To install Karma: run `sudo /home/vagrant/provision/karma.sh install`.  The initial install will take about 10 minutes.  Once it's installed Karma can be started with `/home/vagrant/provision/karma.sh start`.  Karma runs in a web browser and will be available on your machine at `http://localhost:8000/`.

[Violeta Ilik](https://twitter.com/violetailik) has [presented](https://www.youtube.com/watch?v=aBLHGzui0_s) (starting at about 12:30) on how to model data for VIVO with Karma.  More information about Karma can be found in this [tutorial](https://github.com/InformationIntegrationGroup/karma-step-by-step) and on the project's [wiki](https://github.com/InformationIntegrationGroup/Web-Karma/wiki).  
