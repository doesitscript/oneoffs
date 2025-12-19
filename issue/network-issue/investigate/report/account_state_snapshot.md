# Account State Snapshot

**Investigation Date**: 2025-12-19  
**Account ID**: 920411896753  
**Region**: us-east-2  
**Access Profile**: CloudOperations_920411896753_admin  

## ECS Service Configuration

**Cluster Name**: bfh-aws-cloudops-runners-ue2  
**Service Name**: tfc-agent  
**Service Status**: ACTIVE  

**Task Counts**:
- desiredCount: 5
- runningCount: 5  
- pendingCount: 0

**Task Definition**: arn:aws:ecs:us-east-2:920411896753:task-definition/tfc-agent:1  
**Launch Type**: FARGATE  
**Platform Version**: 1.4.0

## Task Stopped Reasons Summary

No stopped tasks found. Service has been running steadily with 5/5 tasks healthy.

Recent events show consistent "steady state" messages:
- 2025-12-19T08:17:16.332Z: "(service tfc-agent) has reached a steady state."
- 2025-12-19T02:16:54.549Z: "(service tfc-agent) has reached a steady state."
- 2025-12-18T20:16:42.757Z: "(service tfc-agent) has reached a steady state."

## Runner Network Configuration

**VPC**: vpc-0ef9fa027c0756355 (tfc-runners)  
**VPC CIDR Blocks**:
- 10.62.51.0/26 (primary)
- 10.62.50.192/26 (secondary)

**Runner Subnets**:
- subnet-0ae9b355369c5d4f8 (us-east-2a, 10.62.51.0/28)
- subnet-03f5dcd1cc0857e1b (us-east-2c, 10.62.51.32/28)  
- subnet-08556aef02d8995f3 (us-east-2b, 10.62.51.16/28)

All subnets have `assignPublicIp: DISABLED`

**Security Groups**: sg-00bdaaa794ba97b7b (tfc-agent)

## Route Table Summary

All three subnets use similar routing configuration:

**Default Routes Present**: YES via Transit Gateway
- 0.0.0.0/0 → tgw-070334cf083fca7cc (Transit Gateway)

**Local Routes**:
- 10.62.50.192/26 → local
- 10.62.51.0/26 → local

**VPC Endpoint Routes**:
- pl-4ca54025 (DynamoDB) → vpce-00e7e61be3017e34e
- pl-7ba54012 (S3) → vpce-0bf2cdc8811b0b38e

## Security Group Egress Summary

**Destinations and Ports**:
- TCP/7146 → 0.0.0.0/0 (TFC agent communication)
- TCP/443 → 0.0.0.0/0 (HTTPS outbound to Terraform Cloud)
- ALL protocols → 10.0.0.0/8 (internal networks)

**Ingress Rules**: None configured (empty IpPermissions array)

## Network ACL Summary

**Allow/Deny Patterns**:
- Rule 100: ALLOW all traffic (ingress and egress)
- Rule 32767: DENY all traffic (default deny, lower priority)

Effective behavior: Allow all traffic (standard default NACL configuration)

## NAT Gateway Presence

**Status**: ABSENT  
No NAT gateways found in VPC vpc-0ef9fa027c0756355

## VPC Endpoint Presence  

**Gateway Endpoints Present**:
- vpce-00e7e61be3017e34e (com.amazonaws.us-east-2.dynamodb)
- vpce-0bf2cdc8811b0b38e (com.amazonaws.us-east-2.s3)

**Interface Endpoints for SSM Services**:
- com.amazonaws.us-east-2.ssm: ABSENT
- com.amazonaws.us-east-2.ssmmessages: ABSENT  
- com.amazonaws.us-east-2.ec2messages: ABSENT

## Key Network Architecture Observations

- Runners operate in private subnets with no public IP assignment
- Outbound internet connectivity via Transit Gateway (not NAT Gateway)
- VPC endpoints provide direct AWS service access for S3 and DynamoDB
- No SSM Session Manager interface endpoints present
- Security groups implement least-privilege egress (specific ports/destinations)
- Multi-AZ deployment across 3 availability zones
- Service consistently maintains desired capacity with no task failures