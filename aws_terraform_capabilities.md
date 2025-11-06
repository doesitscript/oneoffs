# AWS and Terraform Capabilities

## AWS Services & Resources

| Category | AWS Service | Terraform Resource | Use Case / Notes |
|----------|-------------|-------------------|------------------|
| **Compute** | EC2 | `aws_instance` | Windows/Linux instances (CAST, Varonis) |
| | EC2 | `aws_security_group` | Security groups for instances, ECS tasks, NLB |
| | EC2 | `aws_key_pair` | SSH key pairs for EC2 access |
| | EC2 | `aws_ebs_volume` | EBS volumes (gp3, io2) with encryption |
| | EC2 | `aws_volume_attachment` | Attach EBS volumes to instances |
| | ECS | `aws_ecs_cluster` | Container orchestration clusters |
| | ECS | `aws_ecs_service` | ECS services with Fargate |
| | ECS | `aws_ecs_task_definition` | Container task definitions |
| | EKS | `aws_eks_cluster` | Kubernetes clusters (Harness delegate) |
| | EKS | `aws_eks_access_policy_association` | EKS access policies |
| | EKS | `aws_eks_access_entry` | EKS access entries |
| **Networking** | ELB | `aws_lb` | Network Load Balancers (NLB) |
| | ELB | `aws_lb_target_group` | Target groups for load balancers |
| | ELB | `aws_lb_listener` | HTTPS/HTTP listeners |
| | ELB | `aws_lb_listener_rule` | Listener rules from YAML configs |
| | Route53 | `aws_route53_record` | DNS records for applications |
| | Route53 | `aws_route53_zone` | Private hosted zones (data source) |
| | VPC | `aws_vpc` (data) | VPC lookups by tags/IDs |
| | VPC | `aws_subnets` (data) | Subnet lookups |
| | VPC | `aws_subnet` (data) | Individual subnet lookups |
| | VPC | `aws_security_group_rule` | Standalone security group rules |
| | VPC | `aws_vpc_security_group_ingress_rule` | Ingress rules (new format) |
| | VPC | `aws_vpc_security_group_egress_rule` | Egress rules (new format) |
| | VPC | `aws_vpc_endpoint` | VPC endpoints (commented but configured) |
| **Security & Identity** | IAM | `aws_iam_role` | IAM roles for EC2, ECS, Lambda, EKS |
| | IAM | `aws_iam_policy` | Custom IAM policies |
| | IAM | `aws_iam_role_policy_attachment` | Attach managed/custom policies |
| | IAM | `aws_iam_instance_profile` | Instance profiles for EC2 |
| | Secrets Manager | `aws_secretsmanager_secret` | Store SSH keys, secrets |
| | Secrets Manager | `aws_secretsmanager_secret_version` | Secret versions |
| | ACM | `aws_acm_certificate` (data) | SSL/TLS certificate lookups |
| **Storage** | S3 | `aws_s3_bucket` | S3 buckets for Sectigo, Harness |
| | S3 | `aws_s3_bucket_server_side_encryption_configuration` | S3 encryption |
| | S3 | `aws_s3_bucket_public_access_block` | Block public access |
| | S3 | `aws_s3_bucket_notification` | S3 event notifications to SNS |
| | S3 | `aws_s3_object` | Store configuration files |
| **Serverless** | Lambda | `aws_lambda_function` | Python Lambda functions |
| | Lambda | `aws_lambda_permission` | API Gateway invoke permissions |
| | API Gateway | `aws_api_gateway_rest_api` | REST APIs |
| | API Gateway | `aws_api_gateway_stage` | API stages |
| | API Gateway | `aws_api_gateway_deployment` | API deployments |
| | API Gateway | `aws_api_gateway_api_key` | API keys |
| | API Gateway | `aws_api_gateway_usage_plan` | Usage plans |
| | API Gateway | `aws_api_gateway_usage_plan_key` | Link keys to plans |
| **Database** | DynamoDB | `aws_dynamodb_table` | NoSQL tables for Sectigo connector |
| **Messaging** | SNS | `aws_sns_topic` | SNS topics |
| | SNS | `aws_sns_topic_policy` | Topic policies |
| | SNS | `aws_sns_topic_subscription` | SQS subscriptions |
| | SQS | `aws_sqs_queue` | Dead letter queues, main queues |
| | SQS | `aws_sqs_queue_policy` | Queue policies |
| **Monitoring & Logging** | CloudWatch | `aws_cloudwatch_log_group` | Log groups for ECS, Lambda |
| | Application Auto Scaling | `aws_appautoscaling_target` | ECS auto scaling targets |
| | Application Auto Scaling | `aws_appautoscaling_policy` | CPU-based scaling policies |
| **Management** | CloudFormation | `aws_cloudformation_stack` | Stack deployments (Sailpoint) |
| | CloudFormation | `aws_cloudformation_stack_set` | Stack sets for multi-account |
| | SSM | `aws_ssm_parameter` (data) | Parameter Store lookups |
| | Organizations | `aws_organizations_organization` (data) | Org data |
| | Organizations | `aws_organizations_organizational_unit` (data) | OU data |
| | Organizations | `aws_organizations_organizational_unit_descendant_accounts` (data) | Account lists |
| **General** | Region | `aws_region` (data) | Current region lookups |
| | Account | `aws_caller_identity` (data) | Current account/ARN lookups |
| | AMI | `aws_ami` (data) | AMI lookups (Windows, custom) |

## Terraform Features & Patterns

| Feature | Usage | Examples |
|---------|-------|----------|
| **Modules** | Reusable infrastructure components | ECS, IAM, NLB, Route53 modules |
| **Data Sources** | Lookup existing resources | VPCs, subnets, AMIs, certificates |
| **Providers** | Multi-region, multi-account | Primary/secondary regions, hub providers |
| **Provider Aliases** | Cross-account access | `aws.hub_main`, `aws.secondary` |
| **Backend** | Terraform Cloud | Workspace-based state management |
| **Lifecycle Rules** | Prevent unwanted replacements | `ignore_changes = [ami, version]` |
| **Local Values** | Computed values | Resource naming, configuration |
| **Variables** | Parameterization | Environment, instance types, regions |
| **Outputs** | Expose module values | ARNs, DNS names, IDs |
| **Conditional Logic** | Dynamic resource creation | Multi-region deployments |
| **TLS Provider** | Generate keys | SSH key pair generation |
| **YAML Configuration** | External configs | ECS manifests, listener rules |
| **Merge Functions** | Tag management | Combine default and custom tags |
| **Count/Meta-arguments** | Conditional modules | Multi-region deployments |

## Infrastructure Patterns

| Pattern | Description | Implementation |
|---------|-------------|----------------|
| **EC2 Windows Instances** | CAST, Varonis deployments | Domain join, encrypted volumes, SSM access |
| **ECS Fargate** | Containerized applications | NLB, auto-scaling, CloudWatch logs |
| **Multi-Region** | DR/HA deployments | Primary/secondary provider pattern |
| **Cross-Account Access** | Hub account resources | Provider aliases for Network Hub |
| **Secret Management** | Secure credential storage | Secrets Manager for SSH keys |
| **Certificate Management** | ACM integration | Sectigo connector via Lambda |
| **Load Balancer Rules** | Dynamic routing | YAML-driven listener rules |
| **Auto Scaling** | ECS capacity management | CPU-based target tracking |
| **Network Security** | VPC isolation | Security groups, private subnets |
| **IAM Best Practices** | Least privilege | Role-based access, instance profiles |

## Key Components

1. **cast/** - EC2 Windows instance deployment (CAST application)
2. **varonis/** - EC2 Windows instance deployment (Varonis security tool)
3. **ecs/** - ECS Fargate deployment with NLB and Route53
4. **harness-delegate/** - EKS cluster for Harness CI/CD
5. **sectigo-acm-connector/** - Lambda-based ACM certificate management
6. **centralized-ingress-alb/** - Shared ALB for ingress
7. **application-ingress-target-group/** - Target group management
8. **lb-listener-rules/** - Dynamic listener rule configuration
9. **controltower-logs/** - Log aggregation (S3, SNS, SQS)
10. **sailpoint-iam/** - IAM inventory via CloudFormation
11. **tfc-workspaces/** - Terraform Cloud workspace management
12. **tfe-sectigo-workspaces/** - TFE workspace management

## Deployment Environments

- **Development** (`dev`)
- **Production** (`prod`)
- **UAT/Testing** (`uat`)
- **Multi-region**: `us-east-2` (primary), `us-west-2` (secondary)

