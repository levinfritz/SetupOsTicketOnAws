#!/bin/bash
set -e

# Installiere Docker
apt-get update -y
apt-get install -y docker.io curl

# Installiere Docker Compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Erstelle das Arbeitsverzeichnis für osTicket
mkdir -p /srv/osticket
cd /srv/osticket

# Docker Compose Datei erstellen
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
      MYSQL_PASSWORD: securepassword
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
EOF

# Starte die Docker-Container
docker-compose up -d
