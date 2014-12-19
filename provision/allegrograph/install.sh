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
wget http://franz.com/ftp/pri/acl/ag/ag4.14.1/linuxamd64.64/agraph-4.14.1-linuxamd64.64.tar.gz
tar zxf agraph-4.14.1-linuxamd64.64.tar.gz

# AllegroGraph installation (non interactive mode)
agraph-4.14.1/configure-agraph --non-interactive --runas-user agraph --create-runas-user --super-user test --super-password xyzzy

# AllegroGraph permissions
sudo chown -R agraph:agraph /home/vagrant/data
sudo chown -R agraph:agraph /home/vagrant/log

# AllegroGraph service
agraph-4.14.1/agraph --config agraph-4.14.1/agraph.cfg --load-file /home/vagrant/provision/allegrograph/patch-spr41929.fasl

# AllegroGraph client (creates a new repository)
ruby /home/vagrant/provision/allegrograph/create_vivo_repository.rb
