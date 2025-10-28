# AWS Instance Profile Documentation

## Overview

This document explains AWS Instance Profiles, their relationship to IAM roles and policies, and how they're implemented in the CAST EC2 infrastructure.

## What is an Instance Profile?

An **instance profile** is an AWS IAM container that holds an IAM role and makes it available for EC2 instances to assume. Think of it as a "bridge" that allows your EC2 instance to use AWS services with specific permissions.

### Key Components

1. **IAM Role** - Defines what permissions the instance has
2. **Instance Profile** - The container that holds the role and attaches it to EC2
3. **Trust Policy** - Allows EC2 service to assume the role
4. **Policies** - Define specific permissions for AWS services

## How IAM Components Work Together

```
EC2 Instance
    ↓ (uses)
Instance Profile
    ↓ (contains)
IAM Role
    ↓ (has permissions from)
├── SSM Core Policy (AWS managed)
├── CloudWatch Logs Policy (custom)
└── Secrets Access Policy (custom)
```

## CAST Implementation

### 1. IAM Role (The Foundation)

```terraform
resource "aws_iam_role" "cast_role" {
  name = "${local.name_prefix}-role-${var.env}-${data.aws_region.current.name}"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
```

**Purpose**: This is the "identity" that your EC2 instance will assume. The trust policy says "only EC2 service can use this role."

### 2. Instance Profile (The Container)

```terraform
resource "aws_iam_instance_profile" "cast_profile" {
  name = "${local.name_prefix}-profile-${var.env}-${data.aws_region.current.name}"
  role = aws_iam_role.cast_role.name

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-profile"
  })
}
```

**Purpose**: This is the "bridge" that connects your EC2 instance to the IAM role. AWS requires this container - you can't attach a role directly to EC2.

### 3. Policies (The Permissions)

#### SSM Core Policy (Remote Access)
```terraform
resource "aws_iam_role_policy_attachment" "ssm_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.cast_role.name
}
```

**Purpose**: Enables remote access via AWS Systems Manager Session Manager without SSH/RDP keys.

#### CloudWatch Logs Policy (Monitoring)
```terraform
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "${local.name_prefix}-cloudwatch-policy-${var.env}-${data.aws_region.current.name}"
  description = "Policy for CloudWatch Logs access for ${local.name_prefix} instance"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = "arn:aws:logs:*:*:log-group:/aws/${local.name_prefix}/*"
      }
    ]
  })
}
```

**Purpose**: Allows the instance to send logs to CloudWatch for centralized monitoring and logging.

#### Secrets Access Policy (Domain Join)
```terraform
resource "aws_iam_policy" "secrets_access_policy" {
  name        = "${local.name_prefix}-secrets-policy-${var.env}-${data.aws_region.current.name}"
  description = "Policy for cross-account secrets access to customer-image-mgmt"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "arn:aws:secretsmanager:*:422228628991:secret:BreadDomainSecret-CORP*"
      }
    ]
  })
}
```

**Purpose**: Enables cross-account access to domain secrets for CAST domain joining functionality.

## EC2 Instance Configuration

The instance profile is attached to the EC2 instance:

```terraform
resource "aws_instance" "cast" {
  ami                    = data.aws_ami.windows_ami.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.cast_profile.name  # ← This line connects everything
  key_name               = aws_key_pair.cast_key.key_name
  subnet_id              = local.cast_subnet_id
  vpc_security_group_ids = [aws_security_group.cast_sg.id]
  # ... other configuration
}
```

## Resource Naming Convention

With `env = "dev"` from tfvars, the resources are named:

- **Instance Profile**: `cast-profile-dev-us-east-2`
- **IAM Role**: `cast-role-dev-us-east-2`
- **Secrets Policy**: `cast-secrets-policy-dev-us-east-2`
- **CloudWatch Policy**: `cast-cloudwatch-policy-dev-us-east-2`

## Why Instance Profiles Matter for CAST

Instance profiles are **essential** for CAST because they enable:

1. **SSM Session Manager** - Remote access without SSH/RDP keys
2. **CloudWatch Logs** - Centralized logging and monitoring
3. **Cross-Account Secrets Access** - Domain joining functionality
4. **Security Compliance** - Proper IAM permissions following least privilege

## Key Fixes Applied

### Problem
The original configuration had hardcoded "Production" in resource names:
- Instance Profile: `cast-profile-Production-us-east-2`
- Secrets Policy: `cast-secrets-policy-Production-us-east-2`

### Solution
Changed to use `${var.env}` variable for environment-aware naming:
- Instance Profile: `cast-profile-${var.env}-us-east-2`
- Secrets Policy: `cast-secrets-policy-${var.env}-us-east-2`

This ensures consistent, environment-aware naming that matches the dev deployment.

## Important Configuration Notes

### Terraform Variable vs Environment Variable

**CRITICAL**: `var.env` refers to a **Terraform variable**, NOT an environment variable.

```terraform
# This is a Terraform variable (what we use):
variable "env" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Set in tfvars file:
env = "dev"
```

**NOT** an environment variable like `$ENV` or `%ENV%`.

### Cross-Account Secrets Access

**⚠️ CRITICAL DEPENDENCY**: The secrets access policy grants access to account `422228628991`:

```terraform
Resource = "arn:aws:secretsmanager:*:422228628991:secret:BreadDomainSecret-CORP*"
```

**Pre-deployment Verification Required**:
1. Verify account `422228628991` (SharedServices-imagemanagement) exists
2. Confirm secrets matching pattern `BreadDomainSecret-CORP*` exist
3. Ensure cross-account permissions are properly configured

### Instance Profile Attachment

The instance profile is correctly attached to the EC2 instance:

```terraform
resource "aws_instance" "cast" {
  iam_instance_profile = aws_iam_instance_profile.cast_profile.name  # ← Critical connection
  # ... other configuration
}
```

**Without this line, the EC2 instance would have NO IAM permissions.**

## Best Practices

1. **Environment-Aware Naming**: Always use variables for environment-specific naming
2. **Least Privilege**: Only grant permissions that are actually needed
3. **Cross-Account Access**: Use specific ARNs for cross-account resources
4. **Consistent Tagging**: Apply consistent tags across all IAM resources
5. **Documentation**: Document the purpose of each policy and permission

## Pre-Deployment Verification

### Critical Checks Before Deployment

1. **Cross-Account Secrets Verification**:
```bash
# Verify the target account and secrets exist
aws secretsmanager list-secrets \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --query 'SecretList[?contains(Name, `BreadDomainSecret-CORP`)]'
```

2. **Terraform Variable Validation**:
```bash
# Ensure tfvars file is used
terraform plan -var-file="cast.tfvars.MVP2"

# Verify variable values
terraform console
> var.env
> var.name_prefix
```

3. **Instance Profile Naming Check**:
```bash
# Verify no naming conflicts exist
aws iam list-instance-profiles --query 'InstanceProfiles[?contains(InstanceProfileName, `cast-profile-dev`)]'
```

## Troubleshooting

### Common Issues

1. **Instance Profile Not Attached**: Ensure `iam_instance_profile` is set in EC2 resource
2. **Insufficient Permissions**: Check that all required policies are attached to the role
3. **Cross-Account Access**: Verify ARNs are correct for cross-account resources
4. **Naming Conflicts**: Ensure resource names are unique within the account/region
5. **Terraform Variable Confusion**: Remember `var.env` is a Terraform variable, not `$ENV`

### Verification Commands

```bash
# Check instance profile attachment
aws ec2 describe-instances --instance-ids i-1234567890abcdef0 --query 'Reservations[0].Instances[0].IamInstanceProfile'

# List attached policies
aws iam list-attached-role-policies --role-name cast-role-dev-us-east-2

# Test permissions (from within the instance)
aws sts get-caller-identity

# Verify cross-account access
aws secretsmanager describe-secret \
  --secret-id "arn:aws:secretsmanager:us-east-2:422228628991:secret:BreadDomainSecret-CORP-XXXXX"
```

## References

- [AWS IAM Instance Profiles Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html)
- [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [AWS CloudWatch Logs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/)
- [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/)

---

**Created**: $(date)  
**Project**: CAST EC2 Infrastructure  
**Environment**: Development  
**Account**: 925774240130 (CAST Software Dev)
