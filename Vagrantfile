# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

#  Web Server (Ubuntu 22.04)
  config.vm.define "web-server" do |web|
    web.vm.box = "ubuntu/jammy64"
    web.vm.hostname = "web-server"

    # Network configuration
    web.vm.network "private_network", ip: "192.168.56.10"
    web.vm.network "public_network"

    # Synced folder
    web.vm.synced_folder "./website/", "/var/www/html/",
      owner: "www-data", group: "www-data"

    # Provider configuration
    web.vm.provider "virtualbox" do |vb|
      vb.name = "web-server"
      vb.memory = "1024"
      vb.cpus = 1
    end

    # Provisioning script for web server
    web.vm.provision "shell", path: "scripts/provision-web-ubuntu.sh"
  end

  # Machine 2: Database Server (CentOS 9)
  config.vm.define "db-server" do |db|
    db.vm.box = "generic/centos9s"  # CentOS 9 Stream
    db.vm.hostname = "db-server"

    # Network configuration
    db.vm.network "private_network", ip: "192.168.56.20"
    db.vm.network "forwarded_port", guest: 3306, host: 3307

    # Provider configuration
    db.vm.provider "virtualbox" do |vb|
      vb.name = "db-server"
      vb.memory = "1024"
      vb.cpus = 1
    end

    # Provisioning script for database server
    db.vm.provision "shell", path: "scripts/provision-db-centos.sh"
  end

end