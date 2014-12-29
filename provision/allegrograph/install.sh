#!/bin/bash
#
#
#Install AllegroGraph.
#
#

#AG superuser
export AGRAPH_ROOT_USER=test
export AGRAPH_ROOT_PASSWORD=xyzzy
export AGRAPH_VIVO_REPOSITORY=vivo
export AGRAPH_ADMIN=http://$AGRAPH_ROOT_USER:$AGRAPH_ROOT_PASSWORD@localhost:10035

#AllegroGraph requirements
sudo apt-get install -y python-cjson python-pycurl

# AllegroGraph License
cat /home/vagrant/provision/allegrograph/license_ag.txt

# AllegroGraph 4.14.1
wget http://franz.com/ftp/pri/acl/ag/ag4.14.1/linuxamd64.64/agraph-4.14.1-linuxamd64.64.tar.gz
tar zxf agraph-4.14.1-linuxamd64.64.tar.gz

# AllegroGraph installation (non interactive mode)
agraph-4.14.1/configure-agraph --non-interactive --runas-user agraph --create-runas-user --super-user $AGRAPH_ROOT_USER --super-password $AGRAPH_ROOT_PASSWORD

# AllegroGraph permissions
sudo chown -R agraph:agraph /home/vagrant/data
sudo chown -R agraph:agraph /home/vagrant/log

# AllegroGraph service
agraph-4.14.1/agraph --config agraph-4.14.1/agraph.cfg --load-file /home/vagrant/provision/allegrograph/patch-spr41929.fasl

# AllegroGraph client (creates a new repository)
curl -X PUT $AGRAPH_ADMIN/repositories/$AGRAPH_VIVO_REPOSITORY

# AllegroGraph create anonymous user and grant access to the VIVO repository
curl -X PUT $AGRAPH_ADMIN/users/anonymous
curl -X PUT -d read=true -d write=true -d repository=$AGRAPH_VIVO_REPOSITORY -d catalog=/ $AGRAPH_ADMIN/users/anonymous/access