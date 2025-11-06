#!/bin/bash

# Deploy the adapted CAST EC2 configuration
# This script uses the simplified Varonis-based approach

set -e

echo "🚀 Deploying CAST EC2 with adapted Varonis configuration..."

# Initialize Terraform
echo "📋 Initializing Terraform..."
terraform init

# Plan the deployment
echo "📊 Planning deployment..."
terraform plan -var-file="dev.tfvars"

# Ask for confirmation
read -p "🤔 Do you want to apply these changes? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔨 Applying changes..."
    terraform apply -var-file="dev.tfvars" -auto-approve
    
    echo "✅ Deployment complete!"
    echo "📋 Instance details:"
    terraform output
    
    echo ""
    echo "🔑 To get the SSH key for RDP:"
    echo "aws secretsmanager get-secret-value --secret-id \$(terraform output -raw ssh_key_secret_arn) --query SecretString --output text"
else
    echo "❌ Deployment cancelled."
fi

