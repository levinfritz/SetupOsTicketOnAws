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

echo "Deployment abgeschlossen!"
