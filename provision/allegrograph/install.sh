#!/bin/bash
#
#
#Install AllegroGraph.
#
#
#AllegroGraph requirements
sudo apt-get install -y python-cjson python-pycurl rubygems
sudo gem install json agraph --no-ri

# AllegroGraph License
cat /home/vagrant/provision/allegrograph/license_ag.txt

# AllegroGraph 4.14.1
sudo wget http://franz.com/ftp/pri/acl/ag/ag4.14.1/linuxamd64.64/agraph-4.14.1-linuxamd64.64.tar.gz
sudo tar zxf agraph-4.14.1-linuxamd64.64.tar.gz

# AllegroGraph installation (non interactive mode)
sudo agraph-4.14.1/configure-agraph --non-interactive --runas-user agraph --create-runas-user --super-user test --super-password xyzzy

# AllegroGraph service
sudo agraph-4.14.1/agraph-control --config agraph-4.14.1/agraph.cfg start

# AllegroGraph client (creates a new repository)
ruby /home/vagrant/provision/allegrograph/create_vivo_repository.rb
