#!/bin/bash
set -e

# MariaDB installieren
echo "Installiere MariaDB..."
sudo yum update -y
sudo yum install -y mariadb-server

# MariaDB starten und aktivieren
echo "Starte MariaDB..."
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Warte, bis der MariaDB-Dienst läuft
sleep 5

# Datenbank einrichten
echo "Richte die Datenbank ein..."
sudo mysql <<EOF
CREATE DATABASE IF NOT EXISTS osticket;
CREATE USER IF NOT EXISTS 'osticket_user'@'%' IDENTIFIED BY 'securepassword';
GRANT ALL PRIVILEGES ON osticket.* TO 'osticket_user'@'%';
FLUSH PRIVILEGES;
EOF

# Konfiguration anpassen: Remote-Zugriff erlauben
echo "Passe MariaDB-Konfiguration an..."
sudo sed -i "s/^bind-address\s*=.*/bind-address = 0.0.0.0/" /etc/my.cnf

# MariaDB neu starten, um Änderungen zu übernehmen
echo "Starte MariaDB neu..."
sudo systemctl restart mariadb

# Firewall-Regeln (falls benötigt)
echo "Konfiguriere Firewall..."
sudo firewall-cmd --add-service=mysql --permanent
sudo firewall-cmd --reload

echo "Datenbankserver ist eingerichtet und bereit!"
