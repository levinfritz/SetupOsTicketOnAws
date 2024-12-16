#!/bin/bash
set -e

# Überprüfen Sie, ob yum verfügbar ist
if ! command -v yum &> /dev/null; then
    echo "yum ist nicht verfügbar. Bitte installieren Sie die erforderlichen Pakete manuell."
    exit 1
fi

# Installiere Docker und Git
yum update -y
yum install -y docker git curl

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
      MYSQL_PASSWORD: Riethuesli>12345s
    depends_on:
      - db

  db:
    image: mariadb:10.5
    container_name: osticket_db
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: osticket
      MYSQL_USER: osticket_user
      MYSQL_PASSWORD: Riethuesli>12345s
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
EOF

# Starte die Docker-Container
docker-compose up -d