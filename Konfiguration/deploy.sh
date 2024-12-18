#!/bin/bash
set -e

# Installiere Terraform
echo "Installiere Terraform..."
sudo apt-get update -y
sudo apt-get install -y wget unzip
wget https://releases.hashicorp.com/terraform/1.5.5/terraform_1.5.5_linux_amd64.zip
unzip terraform_1.5.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_1.5.5_linux_amd64.zip

# Initialisiere Terraform
echo "Initialisiere Terraform..."
terraform init

# Wende Terraform-Konfiguration an
echo "Wende Terraform-Konfiguration an..."
terraform apply -auto-approve

# Webserver- und Datenbankserver-IPs abrufen
WEB_SERVER_IP=$(terraform output -raw web_server_public_ip)
DB_SERVER_PUBLIC_IP=$(terraform output -raw db_server_public_ip)

# Zeige die Server-IPs an
echo "Die Server-Instanzen werden gestartet. Bitte warten..."
echo "Webserver IP: $WEB_SERVER_IP"
echo "Datenbankserver IP: $DB_SERVER_PUBLIC_IP"

# Timer für den Installationsprozess
echo "Warte 5 Minuten, bis die Installation abgeschlossen ist..."
for i in {1..5}; do
  echo "Minute $i/5..."
  sleep 60
done

# Abschlussmeldung
echo "Die Installation ist abgeschlossen!"
echo "Webserver: http://$WEB_SERVER_IP"
