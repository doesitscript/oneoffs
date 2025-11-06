# Varonis EC2 Module

A reusable Terraform module for deploying Windows EC2 instances with comprehensive security, IAM, and storage configurations.

## Features

- **Flexible Instance Configuration**: Configurable instance types, AMI selection, and storage options
- **Security**: Configurable security groups with RDP and HTTPS access
- **IAM Integration**: Automatic IAM role creation with SSM, CloudWatch, and Secrets Manager access
- **Storage Management**: Configurable root volume and additional EBS volumes
- **SSH Key Management**: Optional SSH key generation and Secrets Manager storage
- **Monitoring**: CloudWatch integration and detailed monitoring options
- **Tagging**: Comprehensive tagging strategy for resource management

## Usage

### Basic Usage

```hcl
module "varonis_instance" {
  source = "./varonis_mod"

  # Required variables
  app_name  = "varonis"
  environment = "prod"
  vpc_id    = "vpc-12345678"
  subnet_id = "subnet-12345678"

  # Optional configuration
  instance_type = "m5.8xlarge"
  root_volume_size = 250
  
  tags = {
    Project = "Varonis"
    Owner   = "Security Team"
  }
}
```

### Advanced Usage

```hcl
module "varonis_instance" {
  source = "./varonis_mod"

  # Required variables
  app_name    = "varonis"
  environment = "prod"
  vpc_id      = "vpc-12345678"
  subnet_id   = "subnet-12345678"

  # Instance configuration
  instance_type = "m5.8xlarge"
  ami_id        = "ami-12345678"  # Optional: specify custom AMI
  
  # Storage configuration
  root_volume_size = 250
  root_volume_type = "gp3"
  additional_volumes = [
    {
      device_name = "/dev/sdf"
      size        = 500
      type        = "gp3"
      encrypted   = true
    },
    {
      device_name = "/dev/sdg"
      size        = 1000
      type        = "gp3"
      encrypted   = true
    }
  ]

  # Security configuration
  allowed_cidr_blocks = ["10.0.0.0/8", "192.168.0.0/16"]
  rdp_port           = 3389
  https_port         = 443

  # IAM configuration
  secrets_manager_arns = [
    "arn:aws:secretsmanager:us-east-2:123456789012:secret:MySecret-abc123"
  ]
  ssm_parameter_arns = [
    "arn:aws:ssm:us-east-2:123456789012:parameter/MyParameter"
  ]

  # Instance behavior
  disable_api_termination = true
  enable_detailed_monitoring = true
  enable_ebs_optimization = true

  # SSH key management
  enable_ssh_key_generation = true
  ssh_key_name = "varonis-prod-key"

  # User data
  user_data = "brd03w255,prod"

  tags = {
    Project     = "Varonis"
    Environment = "Production"
    Owner       = "Security Team"
    CostCenter  = "Security"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.8.0 |
| aws | >= 5.0 |
| tls | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |
| tls | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app_name | Name of the application (e.g., varonis, cast) | `string` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"prod"` | no |
| vpc_id | VPC ID where the instance will be deployed | `string` | n/a | yes |
| subnet_id | Subnet ID where the instance will be deployed | `string` | n/a | yes |
| instance_type | EC2 instance type | `string` | `"m5.8xlarge"` | no |
| ami_id | AMI ID for the instance. If not provided, will use latest Windows AMI | `string` | `null` | no |
| ami_owner | AWS account ID that owns the AMI | `string` | `"422228628991"` | no |
| ami_name_filter | AMI name filter pattern | `string` | `"amidistribution*"` | no |
| user_data | User data script for instance initialization | `string` | `""` | no |
| root_volume_size | Size of the root EBS volume in GB | `number` | `250` | no |
| root_volume_type | Type of root volume (gp2, gp3, io1, io2) | `string` | `"gp3"` | no |
| additional_volumes | List of additional EBS volumes to attach | `list(object)` | See variables.tf | no |
| allowed_cidr_blocks | List of CIDR blocks allowed to access the instance | `list(string)` | `["10.0.0.0/8"]` | no |
| rdp_port | RDP port number | `number` | `3389` | no |
| https_port | HTTPS port number | `number` | `443` | no |
| enable_ssh_key_generation | Whether to generate and store SSH key in Secrets Manager | `bool` | `true` | no |
| ssh_key_name | Name for the SSH key pair | `string` | `null` | no |
| additional_iam_policies | List of additional IAM policy ARNs to attach | `list(string)` | `[]` | no |
| secrets_manager_arns | List of Secrets Manager ARNs the instance can access | `list(string)` | `[]` | no |
| ssm_parameter_arns | List of SSM Parameter ARNs the instance can access | `list(string)` | `[]` | no |
| disable_api_termination | Whether to disable API termination for the instance | `bool` | `true` | no |
| enable_detailed_monitoring | Whether to enable detailed monitoring for the instance | `bool` | `false` | no |
| enable_ebs_optimization | Whether to enable EBS optimization for the instance | `bool` | `true` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| resource_suffix | Suffix to append to resource names | `string` | `"instance"` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | ID of the EC2 instance |
| instance_arn | ARN of the EC2 instance |
| instance_private_ip | Private IP address of the instance |
| instance_public_ip | Public IP address of the instance (if applicable) |
| instance_private_dns | Private DNS name of the instance |
| instance_public_dns | Public DNS name of the instance (if applicable) |
| instance_availability_zone | Availability zone where the instance is deployed |
| instance_state | Current state of the instance |
| instance_type | Instance type of the EC2 instance |
| instance_ami | AMI ID used for the instance |
| security_group_id | ID of the security group |
| security_group_arn | ARN of the security group |
| security_group_name | Name of the security group |
| iam_role_arn | ARN of the IAM role |
| iam_role_name | Name of the IAM role |
| iam_instance_profile_arn | ARN of the IAM instance profile |
| iam_instance_profile_name | Name of the IAM instance profile |
| ssh_key_name | Name of the SSH key pair (if generated) |
| ssh_key_secret_arn | ARN of the SSH private key stored in Secrets Manager (if generated) |
| root_volume_id | ID of the root EBS volume |
| additional_volume_ids | IDs of the additional EBS volumes |
| volume_attachments | Volume attachment information |
| connection_info | Connection information for the instance |
| deployment_summary | Summary of the deployment |

## Resources Created

This module creates the following resources:

- **EC2 Instance**: Windows instance with configurable type and AMI
- **Security Group**: With RDP and HTTPS access rules
- **IAM Role**: With SSM, CloudWatch, and optional Secrets Manager access
- **IAM Instance Profile**: For EC2 instance role attachment
- **EBS Volumes**: Root volume and optional additional volumes
- **SSH Key Pair**: Optional SSH key generation and Secrets Manager storage
- **IAM Policies**: CloudWatch Logs and optional Secrets Manager/SSM access

## Security Considerations

- **Encryption**: All EBS volumes are encrypted by default
- **Network Security**: Security groups restrict access to specified CIDR blocks
- **IAM**: Least privilege access with only necessary permissions
- **Metadata**: IMDSv2 is enforced for enhanced security
- **API Termination**: Can be disabled for production instances

## Migration from Original Varonis Module

To migrate from the original hardcoded Varonis module:

1. **Extract hardcoded values** into variables
2. **Update module call** to use new variable names
3. **Configure environment-specific values** in your workspace
4. **Test deployment** in a non-production environment first

### Example Migration

**Before (hardcoded):**
```hcl
# Original module with hardcoded values
module "varonis" {
  source = "./varonis"
  tags = {
    Environment = "Production"
  }
}
```

**After (parameterized):**
```hcl
# New module with configurable values
module "varonis" {
  source = "./varonis_mod"
  
  app_name    = "varonis"
  environment = "prod"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  subnet_id   = data.aws_ssm_parameter.subnet_id.value
  
  instance_type = "m5.8xlarge"
  user_data     = "brd03w255,prod"
  
  tags = {
    Environment = "Production"
    Project     = "Varonis"
  }
}
```

## Examples

See the `examples/` directory for complete usage examples:

- `basic/` - Basic deployment with minimal configuration
- `advanced/` - Advanced deployment with all features enabled
- `multi-volume/` - Deployment with multiple EBS volumes
- `custom-ami/` - Deployment with custom AMI selection

## License

This module is licensed under the MIT License. See the LICENSE file for details.
