#!/bin/bash
set -e

# Aktualisieren und benötigte Pakete installieren
apt-get update -y
apt-get install -y apache2 php php-mysql libapache2-mod-php unzip curl \
  php-imap php-mbstring php-intl php-soap php-xml php-json

# Apache aktivieren und starten
systemctl enable apache2
systemctl start apache2

# osTicket herunterladen und entpacken
mkdir -p /var/www/html/osticket
curl -L https://github.com/osTicket/osTicket/releases/download/v1.18.1/osTicket-v1.18.1.zip -o /tmp/osTicket.zip
unzip /tmp/osTicket.zip -d /var/www/html/osticket
chown -R www-data:www-data /var/www/html/osticket
rm /tmp/osTicket.zip

# Apache-Konfiguration anpassen
cat <<EOF > /etc/apache2/sites-available/osticket.conf
<VirtualHost *:80>
    DocumentRoot /var/www/html/osticket
    <Directory /var/www/html/osticket>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Standard-Website deaktivieren und osTicket aktivieren
a2dissite 000-default.conf
a2ensite osticket.conf
a2enmod rewrite
systemctl restart apache2

# Setup-Berechtigungen anpassen
chmod -R 755 /var/www/html/osticket
chown -R www-data:www-data /var/www/html/osticket

echo "osTicket-Setup ist abgeschlossen. Rufen Sie die IP-Adresse des Servers im Browser auf, um die Installation abzuschließen."
