#!/bin/bash
set -e

# Variablen
DB_SERVER_PRIVATE_IP="<DB_SERVER_PRIVATE_IP>"
DB_NAME="osticket"
DB_USER="osticket_user"
DB_PASSWORD="Riethuesli>12345"

# osTicket konfigurieren
apt-get update -y
apt-get install -y apache2 php php-mysql libapache2-mod-php unzip curl \
  php-imap php-mbstring php-intl php-soap php-xml php-json

systemctl enable apache2
systemctl start apache2

# osTicket herunterladen und entpacken
mkdir -p /var/www/html/osticket
curl -L https://github.com/osTicket/osTicket/releases/download/v1.18.1/osTicket-v1.18.1.zip -o /tmp/osTicket.zip
unzip /tmp/osTicket.zip -d /var/www/html/osticket
chown -R www-data:www-data /var/www/html/osticket
rm /tmp/osTicket.zip

# Apache-Konfiguration für osTicket
cat <<EOF > /etc/apache2/sites-available/osticket.conf
<VirtualHost *:80>
    DocumentRoot /var/www/html/osticket
    <Directory /var/www/html/osticket>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

a2dissite 000-default.conf
a2ensite osticket.conf
a2enmod rewrite
systemctl restart apache2

# Automatische Konfiguration von osTicket
cp /var/www/html/osticket/include/ost-sampleconfig.php /var/www/html/osticket/include/ost-config.php
chmod 0666 /var/www/html/osticket/include/ost-config.php

# Datenbankinformationen in die Konfiguration eintragen
sed -i "s/'DBHOST', 'localhost'/'DBHOST', '$DB_SERVER_PRIVATE_IP'/g" /var/www/html/osticket/include/ost-config.php
sed -i "s/'DBNAME', 'osTicket'/'DBNAME', '$DB_NAME'/g" /var/www/html/osticket/include/ost-config.php
sed -i "s/'DBUSER', 'osticket'/'DBUSER', '$DB_USER'/g" /var/www/html/osticket/include/ost-config.php
sed -i "s/'DBPASS', 'password'/'DBPASS', '$DB_PASSWORD'/g" /var/www/html/osticket/include/ost-config.php

# Setup-Berechtigungen anpassen
chmod -R 755 /var/www/html/osticket
chown -R www-data:www-data /var/www/html/osticket

echo "osTicket ist bereit. Rufen Sie die IP-Adresse des Webservers im Browser auf, um osTicket zu verwenden."
