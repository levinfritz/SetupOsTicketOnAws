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

# Verschiebe osTicket-Dateien in das Apache-Webroot
echo "Verschiebe osTicket-Dateien ins Webroot..."
sudo mv /var/www/html/osticket/upload/* /var/www/html/
sudo rm -rf /var/www/html/osticket  # Entferne das alte Verzeichnis

# Berechtigungen anpassen
echo "Passe Berechtigungen an..."
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html
sudo chmod 0666 /var/www/html/include/ost-config.php

# Apache-Konfiguration aktualisieren
echo "Passe Apache-Konfiguration an..."
sudo sed -i "s|DocumentRoot \"/var/www/html\"|DocumentRoot \"/var/www/html\"|" /etc/httpd/conf/httpd.conf
cat <<EOF | sudo tee /etc/httpd/conf.d/osticket.conf
<Directory "/var/www/html">
    AllowOverride All
    Require all granted
</Directory>
EOF

# Apache neu starten
echo "Starte Apache neu..."
sudo systemctl restart httpd

# PHP-Info-Seite erstellen (optional, für Tests)
echo "Erstelle PHP-Info-Seite..."
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

echo "Webserver ist eingerichtet! Besuchen Sie die URL, um osTicket zu konfigurieren."
