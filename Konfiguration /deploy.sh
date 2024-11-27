
#!/bin/bash
# AWS Deployment Script
echo "Starting deployment..."

# Install Terraform if not installed
if ! [ -x "$(command -v terraform)" ]; then
  echo "Terraform not found. Installing..."
  sudo apt update -y
  sudo apt install -y wget unzip
  wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
  unzip terraform_1.5.7_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
fi

# Initialize and deploy Terraform
terraform init
terraform apply -auto-approve

echo "Infrastructure deployed. Proceeding with Zoho installation."

# Get instance IP and run installation script
INSTANCE_IP=$(terraform output -raw instance_ip)
ssh -o StrictHostKeyChecking=no ubuntu@$INSTANCE_IP 'bash -s' < install_zoho.sh

echo "Deployment completed. Access Zoho at http://$INSTANCE_IP"
