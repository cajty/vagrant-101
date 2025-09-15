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
    web.vm.provision "shell", inline: <<-SHELL
      # Update system
      apt-get update
      apt-get upgrade -y

      # Install Nginx
      apt-get install -y nginx git

      # Start and enable Nginx
      systemctl start nginx
      systemctl enable nginx

      # Create website directory if not exists
      mkdir -p /var/www/html

      # Clone a public GitHub repository (example - replace with your choice)
      # Remove default nginx page
      rm -f /var/www/html/index.nginx-debian.html

      # Clone a sample website (replace URL with your preferred repository)
      cd /tmp
      git clone https://github.com/startbootstrap/startbootstrap-landing-page.git website
      cp -r website/* /var/www/html/ 2>/dev/null || echo "Using synced folder content"

      # Set proper permissions
      chown -R www-data:www-data /var/www/html
      chmod -R 755 /var/www/html

      # Configure firewall
      ufw allow 'Nginx Full'
      ufw allow ssh

      # Restart Nginx
      systemctl restart nginx

      echo "Web server setup complete!"
      echo "Website accessible at: http://192.168.56.10"
    SHELL
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
    db.vm.provision "shell", inline: <<-SHELL
      # Update system
      dnf update -y

      # Install MySQL 8.0
      dnf install -y mysql-server mysql

      # Start and enable MySQL
      systemctl start mysqld
      systemctl enable mysqld

      # Get temporary root password
      TEMP_PASS=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}' | tail -1)

      # Configure MySQL root password and create database
      mysql --connect-expired-password -u root -p"$TEMP_PASS" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'RootPass123!';
CREATE DATABASE demo_db;
USE demo_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (nom, email) VALUES
('Jean Dupont', 'jean.dupont@example.com'),
('Marie Martin', 'marie.martin@example.com'),
('Pierre Bernard', 'pierre.bernard@example.com'),
('Sophie Dubois', 'sophie.dubois@example.com'),
('Michel Laurent', 'michel.laurent@example.com'),
('Catherine Moreau', 'catherine.moreau@example.com'),
('David Simon', 'david.simon@example.com'),
('Julie Petit', 'julie.petit@example.com'),
('Thomas Roux', 'thomas.roux@example.com'),
('Emma Leroy', 'emma.leroy@example.com');

-- Create user for remote access
CREATE USER 'demo_user'@'%' IDENTIFIED BY 'DemoPass123!';
GRANT ALL PRIVILEGES ON demo_db.* TO 'demo_user'@'%';
FLUSH PRIVILEGES;
EOF

      # Configure MySQL for remote access
      sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf 2>/dev/null || echo "MySQL config file not found at expected location"

      # For CentOS/RHEL, the config might be in different location
      if [ -f /etc/my.cnf ]; then
        echo "[mysqld]" >> /etc/my.cnf
        echo "bind-address = 0.0.0.0" >> /etc/my.cnf
      fi

      # Configure firewall
      firewall-cmd --permanent --add-port=3306/tcp
      firewall-cmd --reload

      # Restart MySQL
      systemctl restart mysqld

      echo "Database server setup complete!"
      echo "MySQL accessible at: localhost:3307"
      echo "Database: demo_db"
      echo "User: demo_user / Password: DemoPass123!"
      echo "Root password: RootPass123!"
    SHELL
  end

end