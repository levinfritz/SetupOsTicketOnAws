#!/bin/bash
apt-get update -y
apt-get install -y mariadb-server
systemctl enable mariadb
systemctl start mariadb
mysql -e "CREATE DATABASE zoho;"
mysql -e "CREATE USER 'zoho_user'@'%' IDENTIFIED BY 'securepassword';"
mysql -e "GRANT ALL PRIVILEGES ON zoho.* TO 'zoho_user'@'%';"
mysql -e "FLUSH PRIVILEGES;"