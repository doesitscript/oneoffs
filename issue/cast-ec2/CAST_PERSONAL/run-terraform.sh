#!/bin/bash

# Set AWS Profile
export AWS_PROFILE="CASTSoftware_dev_925774240130_admin"

# Function to run terraform commands
run_terraform() {
    case $1 in
        "init")
            echo "Running: terraform init"
            terraform init
            ;;
        "plan")
            echo "Running: terraform plan -var-file=dev.tfvars"
            terraform plan -var-file=dev.tfvars
            ;;
        "apply")
            echo "Running: terraform apply -var-file=dev.tfvars"
            terraform apply -var-file=dev.tfvars
            ;;
        "validate")
            echo "Running: terraform validate"
            terraform validate
            ;;
        "format")
            echo "Running: terraform fmt -recursive"
            terraform fmt -recursive
            ;;
        *)
            echo "Usage: $0 {init|plan|apply|validate|format}"
            echo "Available commands:"
            echo "  init     - Initialize Terraform"
            echo "  plan     - Create execution plan"
            echo "  apply    - Apply changes"
            echo "  validate - Validate configuration"
            echo "  format   - Format code"
            ;;
    esac
}

# Run the command
run_terraform "$1"
