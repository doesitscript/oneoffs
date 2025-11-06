terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    #FIXME Add TLS provider here for the SSH key pair generation
    # tls = {
    #   source  = "hashicorp/tls"
    #   version = "~> 4.0"
    # }
  }
}

# TODO: remove hardcoded profile and region
provider "aws" {
  profile = "CASTSoftware_dev_925774240130_admin"
  region  = "us-east-2"
}
