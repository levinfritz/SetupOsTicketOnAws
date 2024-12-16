#!/bin/bash
set -e

# Update Pakete und installiere Docker
sudo yum update -y
sudo amazon-linux-extras enable docker
sudo yum install -y docker

# Starte und aktiviere Docker
sudo systemctl start docker
sudo systemctl enable docker

# Installiere Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-linux-x86_64" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose

# Prüfe die Installation von Docker und Docker Compose
docker --version
docker-compose --version

# Erstelle Verzeichnis für osTicket und docker-compose.yml
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
      MYSQL_HOST: db
      MYSQL_DATABASE: osticket
      MYSQL_USER: osticket_user
      MYSQL_PASSWORD: securepassword
    depends_on:
      - db

  db:
    image: mariadb:10.5
    container_name: osticket_db
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: osticket
      MYSQL_USER: osticket_user
      MYSQL_PASSWORD: Riethuesli>12345
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
EOF

# Starte Docker Compose
sudo docker-compose up -d
