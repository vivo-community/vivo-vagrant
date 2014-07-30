# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Share an additional folder to the guest VM. The first argument is
  # a path to a directory on the host machine, and the second is the path on
  # the guest to mount the folder.
  config.vm.synced_folder "work", "/work"

  # This configuration is for a local box, using VirtualBox as the provider
  config.vm.provider "virtualbox" do |vb, override|
    override.vm.box = "precise64"
    override.vm.box_url = "http://files.vagrantup.com/precise64.box" 

    #vb.customize ["modifyvm", :id, "--memory", 2048]
    vb.memory = 2048

    config.vm.synced_folder "provision", "/home/vagrant/provision"

    config.vm.network "forwarded_port", guest: 80, host: 8081
    config.vm.network "forwarded_port", guest: 8080, host: 8080
    config.vm.network "forwarded_port", guest: 8000, host: 8000
    config.vm.network "forwarded_port", guest: 5000, host: 5000
    config.vm.network "forwarded_port", guest: 3030, host: 3030
  end

  # This configuration is for an AWS EC2 instance, requiring the vagrant-aws plugin
  config.vm.provider "aws" do |aws, override|
    aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    aws.region = "us-west-1"
    # Ubuntu Server 14.04 LTS, SSD Volume Type (64-bit, HVM hardware-assisted, EC2-VPC, t2.micro free tier eligible)
    #aws.ami = "ami-a7fdfee2"  
    #aws.instance_type = "t2.micro"  #also see t2.small, t2.medium, and larger
    # Ubuntu Server 14.04 LTS, SSD Volume Type (64-bit, PV paravirtual, EC2-Classic, t1.micro free tier eligible)
    aws.ami = "ami-f1fdfeb4"  
    aws.instance_type = "t1.micro"  #also see m1.small, m3.medium, m1.medium, and larger
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
    aws.security_groups = [ENV['AWS_SECURITY_GROUP']]
    aws.tags = {
      'Name' => 'VIVO Vagrant Test',
    }

    override.vm.box = "dummy"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
    override.ssh.username = "ubuntu"  #Overrides default 'vagrant' user name
    override.ssh.private_key_path = ENV['MY_PRIVATE_AWS_SSH_KEY_PATH']

    config.vm.synced_folder "provision", "/home/ubuntu/provision"
  end

  #config.vm.provision "shell", path: "provision/bootstrap.sh"
  config.vm.provision "shell", path: "provision/bootstrap.sh", privileged: false
end
