#!/bin/bash
set -e

echo "Installiere Terraform..."
sudo apt-get update -y
sudo apt-get install -y wget unzip
wget https://releases.hashicorp.com/terraform/1.5.5/terraform_1.5.5_linux_amd64.zip
unzip terraform_1.5.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_1.5.5_linux_amd64.zip

echo "Initialisiere Terraform..."
terraform init

echo "Wende Terraform-Konfiguration an..."
terraform apply -auto-approve

# IP-Adressen ermitteln
WEB_SERVER_PUBLIC_IP=$(terraform output -raw web_server_public_ip)
DB_SERVER_PRIVATE_IP=$(terraform output -raw db_server_private_ip)

echo "Webserver öffentliche IP: $WEB_SERVER_PUBLIC_IP"
echo "Datenbankserver private IP: $DB_SERVER_PRIVATE_IP"

# Die Datenbank-IP in das Webserver-Setup einfügen
sed -i "s/<DB_SERVER_PRIVATE_IP>/$DB_SERVER_PRIVATE_IP/g" web-init.sh

echo "Die Infrastruktur wurde erfolgreich bereitgestellt!"
echo "Rufen Sie die folgende URL im Browser auf, um osTicket zu verwenden: http://$WEB_SERVER_PUBLIC_IP"
