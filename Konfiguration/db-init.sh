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
-- Erstelle die Datenbank, falls sie nicht existiert
CREATE DATABASE osticket;

-- Erstelle den Benutzer neu
CREATE USER 'osticketuser'@'%' IDENTIFIED BY 'securepassword';

-- Weise Berechtigungen zu
GRANT ALL PRIVILEGES ON osticket.* TO 'osticketuser'@'%';

-- Übernehme die Änderungen
FLUSH PRIVILEGES;
EOF

# Konfiguration anpassen: Remote-Zugriff erlauben
echo "Passe MariaDB-Konfiguration an..."
sudo sed -i "s/^bind-address\s*=.*/bind-address = 0.0.0.0/" /etc/my.cnf

# MariaDB neu starten, um Änderungen zu übernehmen
echo "Starte MariaDB neu..."
sudo systemctl restart mariadb

echo "Datenbankserver ist eingerichtet und bereit!"
