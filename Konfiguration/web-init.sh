#!/bin/bash
set -e

# Apache und PHP installieren
echo "Installiere Apache und PHP 8.2..."
sudo yum update -y
sudo amazon-linux-extras enable php8.2
sudo yum install -y httpd php php-mysqli wget unzip

# Apache starten und aktivieren
echo "Starte Apache..."
sudo systemctl start httpd
sudo systemctl enable httpd

# osTicket herunterladen und einrichten
echo "Lade osTicket herunter..."
wget -O /tmp/osTicket.zip https://github.com/osTicket/osTicket/releases/download/v1.18.1/osTicket-v1.18.1.zip
sudo mkdir -p /var/www/html/osticket
sudo unzip /tmp/osTicket.zip -d /var/www/html/osticket

# Berechtigungen anpassen
echo "Passe Berechtigungen an..."
sudo chown -R apache:apache /var/www/html/osticket
sudo chmod -R 755 /var/www/html/osticket

# Konfigurationsdateien verschieben
echo "Kopiere Konfigurationsdateien..."
cd /var/www/html/osticket/upload
sudo mv include/ost-sampleconfig.php include/ost-config.php
sudo chmod 0666 include/ost-config.php

# Firewall-Regeln für HTTP
echo "Konfiguriere Firewall..."
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload

# Apache neu starten
echo "Starte Apache neu..."
sudo systemctl restart httpd

echo "Webserver ist eingerichtet! Besuchen Sie die URL, um osTicket zu konfigurieren."
