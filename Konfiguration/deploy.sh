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

echo "Ermittle die öffentliche IP-Adresse des Webservers..."
WEB_SERVER_IP=$(terraform output -raw aws_instance_web_server_public_ip)

echo "Webserver-IP-Adresse: $WEB_SERVER_IP"
echo "Rufen Sie die folgende URL im Browser auf, um die Installation abzuschließen: http://$WEB_SERVER_IP/setup"
