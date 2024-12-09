#!/bin/bash
apt-get update -y
apt-get install -y apache2 php php-mysql libapache2-mod-php unzip curl

# Enable and start Apache
systemctl enable apache2
systemctl start apache2

# Download osTicket
mkdir -p /var/www/html/osticket
curl -L https://github.com/osTicket/osTicket/releases/download/v1.18.1/osTicket-v1.18.1.zip -o /tmp/osTicket.zip

# Extract osTicket and set permissions
unzip /tmp/osTicket.zip -d /var/www/html/osticket
chown -R www-data:www-data /var/www/html/osticket
rm /tmp/osTicket.zip

# Restart Apache to apply changes
systemctl restart apache2
