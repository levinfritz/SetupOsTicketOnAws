#!/bin/bash
# Install dependencies
sudo apt update -y
sudo apt install -y curl unzip

# Download Zoho Desk (Placeholder URL for installer)
curl -o zoho_installer.zip https://example.com/zoho/desk_installer.zip
unzip zoho_installer.zip -d /var/www/html/zoho

# Set permissions
sudo chown -R www-data:www-data /var/www/html/zoho

# Restart Apache
sudo systemctl restart apache2
