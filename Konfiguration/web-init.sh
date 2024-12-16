#!/bin/bash
set -euxo pipefail

# Prüfen, ob yum verfügbar ist
if ! type yum &> /dev/null; then
    echo "yum ist nicht verfügbar. Bitte installieren Sie die erforderlichen Pakete manuell."
    exit 1
fi

# Update und Installation
yum update -y
yum install -y docker git curl

# Docker Compose prüfen und installieren (modern)
if ! docker compose version &> /dev/null; then
    echo "Docker Compose ist nicht verfügbar. Bitte installieren."
    exit 1
fi

# Erstellen des Arbeitsverzeichnisses
WORKDIR="/srv/osticket"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

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
      MYSQL_PASSWORD: ${MYSQL_USER_PASSWORD:-Riethuesli>12345s}
    depends_on:
      - db

  db:
    image: mariadb:10.5
    container_name: osticket_db
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:-rootpassword}
      MYSQL_DATABASE: osticket
      MYSQL_USER: osticket_user
      MYSQL_PASSWORD: ${MYSQL_USER_PASSWORD:-Riethuesli>12345s}
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
EOF

# Container starten
docker compose up -d
echo "Die Container wurden erfolgreich gestartet."
