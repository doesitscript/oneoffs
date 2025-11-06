# CAST EC2 Deployment Guide

## Quick Start

This guide shows you how to deploy a CAST EC2 instance using the refactored Varonis module.

### 1. **Prepare Your Configuration**

Create a workspace configuration file (e.g., `cast-workspace/main.tf`):

```hcl
module "cast_instance" {
  source = "../varonis_mod"

  # Required variables
  app_name    = "cast"
  environment = "prod"
  vpc_id      = "vpc-xxxxxxxx"      # Your CAST VPC ID
  subnet_id   = "subnet-xxxxxxxx"   # Your CAST subnet ID

  # CAST-specific configuration
  instance_type = "r5a.24xlarge"
  ami_id        = "ami-xxxxxxxx"    # Your CAST AMI ID

  # Storage
  root_volume_size = 100
  additional_volumes = [
    {
      device_name = "/dev/sdf"
      size        = 500
      type        = "gp3"
      encrypted   = true
    }
  ]

  # Security
  allowed_cidr_blocks = ["10.0.0.0/8"]  # Your allowed networks

  # Tags
  tags = {
    Project     = "CAST"
    Application = "CAST Software"
    Owner       = "CAST Team"
  }
}
```

### 2. **Initialize and Deploy**

```bash
# Navigate to your workspace
cd cast-workspace

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 3. **Access Your Instance**

After deployment, you can access your CAST instance:

```bash
# Get connection information
terraform output connection_info

# RDP to the instance (if public IP is available)
# Use the private IP if accessing via VPN
```

## Configuration Options

### **Required Variables**
- `app_name`: Application name (e.g., "cast")
- `environment`: Environment (e.g., "prod", "dev")
- `vpc_id`: VPC ID where instance will be deployed
- `subnet_id`: Subnet ID where instance will be deployed

### **Instance Configuration**
- `instance_type`: EC2 instance type (default: "m5.8xlarge")
- `ami_id`: AMI ID (optional, will use latest Windows AMI if not specified)
- `user_data`: User data script for initialization

### **Storage Configuration**
- `root_volume_size`: Root volume size in GB (default: 250)
- `root_volume_type`: Root volume type (default: "gp3")
- `additional_volumes`: List of additional EBS volumes

### **Security Configuration**
- `allowed_cidr_blocks`: CIDR blocks allowed to access instance
- `rdp_port`: RDP port (default: 3389)
- `https_port`: HTTPS port (default: 443)

### **IAM Configuration**
- `secrets_manager_arns`: Secrets Manager ARNs for access
- `ssm_parameter_arns`: SSM Parameter ARNs for access
- `additional_iam_policies`: Additional IAM policy ARNs

## Example Configurations

### **Basic CAST Deployment**
```hcl
module "cast" {
  source = "../varonis_mod"
  
  app_name    = "cast"
  environment = "prod"
  vpc_id      = var.cast_vpc_id
  subnet_id   = var.cast_subnet_id
  
  instance_type = "r5a.24xlarge"
  ami_id        = var.cast_ami_id
  
  tags = { Project = "CAST" }
}
```

### **Advanced CAST Deployment**
```hcl
module "cast" {
  source = "../varonis_mod"
  
  app_name    = "cast"
  environment = "prod"
  vpc_id      = var.cast_vpc_id
  subnet_id   = var.cast_subnet_id
  
  # Instance configuration
  instance_type = "r5a.24xlarge"
  ami_id        = var.cast_ami_id
  user_data     = "brd03w255,prod"
  
  # Storage
  root_volume_size = 100
  additional_volumes = [
    {
      device_name = "/dev/sdf"
      size        = 500
      type        = "gp3"
      encrypted   = true
    }
  ]
  
  # Security
  allowed_cidr_blocks = [
    "10.0.0.0/8",
    "192.168.0.0/16"
  ]
  
  # IAM
  secrets_manager_arns = [
    "arn:aws:secretsmanager:us-east-2:123456789012:secret:CAST-Secret-abc123"
  ]
  
  # Monitoring
  enable_detailed_monitoring = true
  
  # Tags
  tags = {
    Project     = "CAST"
    Application = "CAST Software"
    Environment = "Production"
    Owner       = "CAST Team"
    CostCenter  = "Development"
  }
}
```

## Troubleshooting

### **Common Issues**

1. **VPC/Subnet not found**
   - Verify VPC and subnet IDs are correct
   - Ensure they exist in the target region

2. **AMI not found**
   - Verify AMI ID is correct
   - Ensure AMI is available in the target region

3. **Security group rules**
   - Check that allowed CIDR blocks include your access networks
   - Verify RDP and HTTPS ports are open

4. **IAM permissions**
   - Ensure deployment role has necessary permissions
   - Check that Secrets Manager and SSM ARNs are accessible

### **Getting Help**

- Check the module outputs for connection information
- Review CloudWatch logs for instance initialization issues
- Verify security group rules and network connectivity

## Next Steps

1. **Test in development** environment first
2. **Customize configuration** for your specific needs
3. **Set up monitoring** and alerting
4. **Document your deployment** process
5. **Plan for scaling** if needed

The refactored module provides a solid foundation for your CAST EC2 deployment while maintaining flexibility for future changes and reusability across different environments.
