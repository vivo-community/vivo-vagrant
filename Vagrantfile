# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.provider "virtualbox" do |v,override|
    config.vm.box = "ubuntu/xenial64"
	  v.gui = true
	  v.cpus = 2
	  v.memory = 4096
	  v.customize ['modifyvm', :id, '--clipboard', 'bidirectional']  
  end

  config.vm.provider "vmware_fusion" do |v,override|
	v.gui = false
	v.vmx["numvcpus"] = "1"
	v.vmx["memsize"] = "1024"
	override.vm.box     = "precise64_vmware_fusion"
	override.vm.box_url = "http://files.vagrantup.com/precise64_vmware_fusion.box"
  end

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  # config.vm.network :hostonly, "192.168.33.10"

  # Assign this VM to a bridged network, allowing you to connect directly to a
  # network using the host's network device. This makes the VM appear as another
  # physical device on your network.
  # config.vm.network :bridged

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  config.vm.network "forwarded_port", guest: 80, host: 8081
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 8000, host: 8000

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  config.vm.synced_folder "work", "/work"
  config.vm.synced_folder "provision", "/home/vagrant/provision"

  #config.vm.share_folder "v-data", "/work", "work"
  #config.vm.share_folder "provision", "/home/vagrant/provision", "provision"

  # Setup box
  config.vm.provision "bootstrap", type: "shell" do |s|
    s.path = "provision/bootstrap.sh"
    s.privileged = true
  end

  # Install VIVO
  config.vm.provision "vivo", type: "shell" do |s|
    s.path = "provision/vivo/install.sh"
    s.privileged = true
  end

end
