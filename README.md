# VIVO Vagrant

>*September 29, 2013* - this is an initial pass at installing VIVO via a Vagrant bootstrap script.  Testing needed.

[Vagrant](http://www.vagrantup.com/) configuration and install scripts for running [VIVO](http://vivoweb.org) on an Ubuntu 64 Precise image.

The VIVO web application will be available at `http://localhost:8080/vivo`.  The source will be at `/usr/local/vivo/`.

The box will boot and install VIVO 1.5.1 and dependencies.  This will take several minutes for the initial install.

## Install

~~~
$ git clone vivo-vagrant
$ vagrant up
~~~

## Notes
 * This is intended for development only.  Change passwords if you intend to use this config for deployment.
 * The source at `/usr/local/vivo` is based off a [template](https://github.com/lawlesst/vivo-project-template) and under git
 version control.
 * Various other development tools, mainly Python, are installed too.  Comment those out if they are not needed.
 * Your VIVO environment will be dropped and reconfigured anytime that `vagrant reload` or `vagrant provision` is run.
 Be sure to backup any data or code before running these commands.

