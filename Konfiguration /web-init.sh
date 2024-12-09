#!/bin/bash
apt-get update -y
apt-get install -y apache2 curl
systemctl enable apache2
systemctl start apache2
mkdir -p /var/www/html/zoho
curl -L https://example.com/zoho/download -o /var/www/html/zoho/index.html
chown -R www-data:www-data /var/www/html/zoho