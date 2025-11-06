# Minimal Terraform configuration for CAST Software Dev Account
# Account: 925774240130
# Profile: CASTSoftware_dev_925774240130_admin

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = "CASTSoftware_dev_925774240130_admin"
  region  = "us-east-2"
}
