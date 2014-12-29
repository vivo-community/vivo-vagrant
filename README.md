# VIVO Vagrant with AllegroGraph
This Vagrant box is intended for development and experimentation only.  __Change default user names and passwords.__

The provisiong script will install the VIVO web application with the [AllegroGraph](http://franz.com/agraph/allegrograph/) graph database.

## Install / setup
~~~
$ git clone https://github.com/lawlesst/vivo-vagrant vivo-vagrant
$ cd vivo-vagrant
$ git checkout allegrograph
$ vagrant up
~~~

When the Vagrant provisioning script is complete, the __VIVO web application__ will be available in a browser on the host machine at `http://localhost:8080/vivo` and __AllegroGraph Triple Store__ at `http://localhost:10035`.

You can log into your new VIVO with the default admin user (`vivo_root@school.edu`) and password (`rootPassword`) and AllegroGraph with the login (`test`) and password (`xyzzy`), which are specified in the `/provision/vivo/deploy.properties` source file in this repository and `/provision/allegrograph/install.sh`.