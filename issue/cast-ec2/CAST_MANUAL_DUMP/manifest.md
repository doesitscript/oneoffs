# CAST EC2 Instance Snapshot Manifest

**Instance:** i-00a3cb5faf95c6561 (ec2-ecs-cast-02)  
**Account:** 925774240130  
**Region:** us-east-2  
**Generated:** 2025-10-22T10:38:07Z  

## File Mapping to Terraform

| File | Terraform Usage | Description |
|------|----------------|-------------|
| **Raw Files** | | |
| `instance_description.json` | `aws_instance` resource | Complete instance configuration |
| `ami_description.json` | `data.aws_ami` | AMI details and metadata |
| `security_groups.json` | `aws_security_group` | Security group rules and configuration |
| `iam_instance_profile.json` | `aws_iam_instance_profile` | IAM instance profile details |
| `iam_role.json` | `aws_iam_role` | IAM role and assume role policy |
| `iam_role_policies.json` | `aws_iam_role_policy_attachment` | Attached managed policies |
| `ebs_volumes.json` | `aws_ebs_volume` | EBS volume configurations |
| `subnet.json` | `data.aws_subnet` | Subnet details and CIDR |
| `vpc.json` | `data.aws_vpc` | VPC configuration |
| `network_interfaces.json` | `aws_network_interface` | ENI configurations |
| `launch_template.json` | `aws_launch_template` | Launch template (empty - not used) |
| `user_data.txt` | `user_data` parameter | Bootstrap script content |
| `console_output.txt` | Reference only | Console output for debugging |
| `ssm_inventory.json` | Reference only | SSM agent status |
| `tags.json` | `tags` parameter | Resource tags |
| **Normalized Files** | | |
| `instance.json` | `variables.tf` | Core instance parameters |
| `storage.json` | `aws_ebs_volume` blocks | Storage configuration |
| `networking.json` | `aws_security_group` + `aws_network_interface` | Network configuration |
| `iam.json` | `aws_iam_role` + `aws_iam_instance_profile` | IAM configuration |
| `bootstrap.json` | `user_data` + monitoring | Bootstrap and management |
| `tags.json` | `tags` blocks | Tagging strategy |
| `launch_template.json` | Reference only | Launch template status |

## Key Terraform Mappings

- **Instance Type:** `r5a.2xlarge` → `instance_type` variable
- **AMI:** `ami-0684b1bd72f4b0d55` → `ami_id` variable  
- **Key Pair:** `ec2-ecs-cast-02-kp` → `key_name` variable
- **Security Group:** `sg-053b41f329207cd48` → `vpc_security_group_ids`
- **Subnet:** `subnet-0900c846fdabad701` → `subnet_id` variable
- **IAM Role:** `bf-global-devonly-AmazonSSMManagedInstanceCore` → `iam_instance_profile`
- **Storage:** Root 80GB gp2 + Additional 500GB gp3 → `aws_ebs_volume` resources
- **Platform:** Windows → `user_data` encoding and `get_password_data`
