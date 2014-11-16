# VIVO with Stardog 

[Stardog](http://stardog.com/) is a fast, commercial triple store.  This vagrant is a proof-of-concept for running VIVO with a Stardog backend.  Follow the notes in the [README](https://github.com/lawlesst/vivo-vagrant) master branch for directions on getting started with this vivo-vagrant.  Below are a couple of notes on what's required to get VIVO and Stargdog to talk to each other correctly.

 * You will need a license and a local copy  [Stardog](http://stardog.com/).  The zip file is expected to be at `./provision/stardog/stardog-2.2.2.zip'.  
 * The provisioning scripts currently expect Stardog 2.2.2.  If you need to use a different version, you'll need to edit them slightly.
 * VIVO currently has no way to specify authentication parameters for a triple store, so Stardog must be started with security turned off.  This is extremely dangerous in production environments, but can likely be mitigated via proxy authentication (e.g. Apache or NGINX authentication).
 * By default, SPARQL queries that do not specify a specific named graph query only the default graph.  This is most likely the correct way to handle such queries, but VIVO expects these queries to instead use the union of the default and all named graphs.  A slight configuration change is required for Stardog to support this. 
