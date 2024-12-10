#!/bin/bash

# Install prerequisites
echo "Installing prerequisites..."
sudo apt update && sudo apt install -y unzip wget awscli terraform

# Clone repository
echo "Cloning repository..."
git clone https://github.com/levinfritz/M346-Levin-Noe-Janis.git
cd M346-Levin-Noe-Janis

# Run Terraform scripts
echo "Initializing Terraform..."
terraform init

echo "Applying Terraform configuration..."
terraform apply -auto-approve

# Download osTicket
echo "Downloading osTicket..."
wget -O osTicket.zip https://github.com/osTicket/osTicket/releases/download/v1.18.1/osTicket-v1.18.1.zip
unzip osTicket.zip -d ./osTicket

echo "Setup complete. Please check your AWS Console for the deployed resources."
