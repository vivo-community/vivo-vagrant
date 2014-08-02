# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  #
  # This configuration is for a local box, using VirtualBox as the provider
  config.vm.provider "virtualbox" do |vb, override|
    #Memory
    vb.memory = 2048

    #Synced folders
    override.vm.synced_folder "provision", "/home/vagrant/provision"
    override.vm.synced_folder "work", "/work"

    override.vm.network "forwarded_port", guest: 8080, host: 8080

    #Provision - privileged is false because we don't want to run this as root but as the logged in user.
    override.vm.provision "shell", path: "provision/bootstrap.sh", privileged: false
    override.vm.provision "shell", path: "provision/vivo/install.sh", privileged: false
  end

  #This configuration is for an AWS EC2 instance, requiring the vagrant-aws plugin
  config.vm.provider "aws" do |aws, override|
    aws_unix_user = "ubuntu"
    aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    #The region, ami, and instance type should be moved to environment variables.
    aws.region = "us-east-1"
    # Ubuntu
    aws.ami = "ami-3251905a"
    aws.instance_type = "t1.micro"  #also see m1.small, m3.medium, m1.medium, and larger
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
    aws.security_groups = [ENV['AWS_SECURITY_GROUP']]
    #The name could also be an env variable.
    aws.tags = {
      'Name' => 'VIVO Vagrant Test',
    }
    override.vm.box = "dummy"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
    override.ssh.username = aws_unix_user  #Overrides default 'vagrant' user name
    override.ssh.private_key_path = ENV['MY_PRIVATE_AWS_SSH_KEY_PATH']

    #Install base packages.
    override.vm.provision "shell", path: "provision/bootstrap.sh", privileged: false
    #Get the provision dir and put it in the home directory.  We aren't using shared folders on AWS.
    #Provision AWS on Windows did not copy the provision directory to AWS, causing the VIVO install to fail.
    override.vm.provision "shell", inline: "rm -rf /home/#{aws_unix_user}/provision/; svn export https://github.com/lawlesst/vivo-vagrant/branches/aws/provision /home/#{aws_unix_user}/provision", privileged: false
    #Install VIVO
    override.vm.provision "shell", path: "provision/vivo/install.sh", privileged: false
  end

end
