require 'rubygems'
require 'allegro_graph'

server = AllegroGraph::Server.new :username => "test", :password => "xyzzy"
repository = AllegroGraph::Repository.new server, "vivo"
repository.create_if_missing!
