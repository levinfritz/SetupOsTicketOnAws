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

#Timer auf 4 Minuten mit Statusanzeige
echo "Warte 4 Minuten, bis die Installation abgeschlossen ist..."

total_minutes=4
total_seconds=$((total_minutes * 60)) 
bar_length=20                        
for ((elapsed_seconds=0; elapsed_seconds<=total_seconds; elapsed_seconds+=1)); do
  percent=$((elapsed_seconds * 100 / total_seconds))
  filled_length=$((percent * bar_length / 100))

  bar=$(printf "%-${bar_length}s" "=" | tr ' ' '=')
  arrow=">"
  bar="[${bar:0:filled_length}${arrow}${bar:filled_length:bar_length}]"
  
  echo -ne "${percent}% ${bar}\r"
  
  sleep 1
done

# Abschlussmeldung
echo -e "\nInstallation abgeschlossen!"

# Abschlussmeldung
echo "Die Installation ist abgeschlossen!"
echo "Webserver: http://$WEB_SERVER_IP"
echo "DBserver:  $DB_SERVER_PUBLIC_IP"
