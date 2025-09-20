#!/bin/bash

echo "=== Starting Database Server Provisioning ==="

# Update system
dnf update -y

# Install MySQL
dnf install -y mysql-server mysql

# Start and enable MySQL
systemctl start mysqld
systemctl enable mysqld

# Start firewall service
systemctl start firewalld
systemctl enable firewalld

# add the port rules
firewall-cmd --permanent --add-port=3306/tcp
firewall-cmd --reload

# Basic MySQL setup
mysql -u root << 'EOF'
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

# Create database and user
mysql -u root << 'EOF'
CREATE DATABASE test_db;
CREATE USER 'demo_user'@'%' IDENTIFIED BY 'DemoPass123!';
GRANT ALL PRIVILEGES ON test_db.* TO 'demo_user'@'%';
FLUSH PRIVILEGES;
EOF

# Execute SQL files
echo "=== Creating database schema ==="
mysql -u root test_db < /vagrant/database/create-table.sql

echo "=== Loading demo data ==="
mysql -u root test_db < /vagrant/database/insert-data.sql

# Configure MySQL for external connections
echo "bind-address = 0.0.0.0" >> /etc/my.cnf.d/mysql-server.cnf
systemctl restart mysqld

echo "=== Database Info ==="
echo "MySQL Status: $(systemctl is-active mysqld)"
echo "Database: test_db"
echo "User: demo_user / DemoPass123!"
echo "Port forwarding: host:3307 -> guest:3306"
mysql -u demo_user -p'DemoPass123!' test_db -e "SELECT COUNT(*) as user_count FROM users;" 2>/dev/null
echo "=== Database Server Provisioning Complete ==="