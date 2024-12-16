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

# Webserver-IP abrufen
WEB_SERVER_IP=$(terraform output -raw web_server_public_ip)

# Zeige die Webserver-IP an
echo "Die Webserver-Instanz wird gestartet. Bitte warten..."
echo "Webserver IP: $WEB_SERVER_IP"

# Timer für den Installationsprozess
echo "Warte 10 Minuten, bis die Installation abgeschlossen ist..."
for i in {1..5}; do
  echo "Minute $i/5..."
  sleep 60
done


chmod 400 ~/M346-Levin-Noe-Janis/deployer_key.pem
echo "Überprüfe den Status des Webservers und führe die Initialisierung durch..."
ssh -o StrictHostKeyChecking=no -i ~/M346-Levin-Noe-Janis/deployer_key.pem ec2-user@$WEB_SERVER_IP << 'EOF'
# Klone das Repository, falls noch nicht vorhanden
if [ ! -d "M346-Levin-Noe-Janis" ]; then
  sudo yum install git
  git clone https://github.com/levinfritz/M346-Levin-Noe-Janis.git
fi

# Führe das web-init.sh-Skript aus
echo "Führe die Webserver-Initialisierung durch..."
sudo bash M346-Levin-Noe-Janis/Konfiguration/web-init.sh
EOF

# Abschlussmeldung
echo "Die Installation ist abgeschlossen! Öffnen Sie die folgende URL im Browser:"
echo "http://$WEB_SERVER_IP"