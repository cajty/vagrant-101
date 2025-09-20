#!/bin/bash

echo "=== Starting Web Server Provisioning ==="

# Update system
apt-get update -y

# Install Nginx, MySQL client
apt-get install -y nginx mysql-client

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx

# Configure firewall
ufw allow 'Nginx Full'
ufw allow ssh
echo "y" | ufw enable

# Remove default nginx page
rm -f /var/www/html/index.nginx-debian.html

# Ensure correct permissions for synced folder
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Test database connectivity (retry logic)
echo "=== Testing Database Connectivity ==="
DB_STATUS="Failed"
USER_COUNT="Unknown"

for i in {1..20}; do
  if mysql -h 192.168.56.20 -u demo_user -p'DemoPass123!' test_db -e "SELECT 1;" >/dev/null 2>&1; then
    echo "Database connection successful!"
    DB_STATUS="Connected"
    USER_COUNT=$(mysql -h 192.168.56.20 -u demo_user -p'DemoPass123!' test_db -s -e "SELECT COUNT(*) FROM users;" 2>/dev/null)
    break
  else
    echo "Waiting for database... (attempt $i/30)"
    sleep 10
  fi
done

# Get network info
PUBLIC_IP=$(hostname -I | awk '{print $1}')
PRIVATE_IP=$(hostname -I | awk '{print $2}')

echo "=== Web Server Info ==="
echo "Nginx Status: $(systemctl is-active nginx)"
echo "Public IP: $PUBLIC_IP"
echo "Private IP: $PRIVATE_IP"
echo "Database Status: ${DB_STATUS}"
echo "Users in database: ${USER_COUNT}"
echo "=== Web Server Provisioning Complete ==="