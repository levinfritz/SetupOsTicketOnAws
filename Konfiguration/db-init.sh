#!/bin/bash
apt-get update -y
apt-get install -y mariadb-server

# Start MariaDB
systemctl enable mariadb
systemctl start mariadb

# Configure database
mysql -e "CREATE DATABASE osticket;"
mysql -e "CREATE USER 'osticket_user'@'%' IDENTIFIED BY 'Riethuesli>12345s';"
mysql -e "GRANT ALL PRIVILEGES ON osticket.* TO 'osticket_user'@'%';"
mysql -e "FLUSH PRIVILEGES;"
