#!/bin/bash
set -e

# Docker installieren
echo "Installiere Docker..."
sudo yum update -y
sudo amazon-linux-extras enable docker
sudo yum install -y docker

# Docker starten und aktivieren
echo "Starte Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Docker Compose installieren
echo "Installiere Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-linux-x86_64" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose

# Docker-Setup für osTicket
echo "Richte Docker-Setup ein..."
sudo mkdir -p /srv/osticket
cd /srv/osticket

cat <<EOF > docker-compose.yml
version: '3.8'

services:
  web:
    image: osticket/osticket:latest
    container_name: osticket_web
    ports:
      - "80:80"
    environment:
      MYSQL_HOST: <DB_SERVER_PRIVATE_IP>
      MYSQL_DATABASE: osticket
      MYSQL_USER: osticketuser
      MYSQL_PASSWORD: securepassword
    depends_on:
      - db

  db:
    image: mariadb:10.5
    container_name: osticket_db
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: osticket
      MYSQL_USER: osticketuser
      MYSQL_PASSWORD: securepassword
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
EOF

# Docker Compose starten
echo "Starte osTicket-Container..."
sudo docker-compose up -d

echo "Webserver ist eingerichtet und osTicket läuft!"
