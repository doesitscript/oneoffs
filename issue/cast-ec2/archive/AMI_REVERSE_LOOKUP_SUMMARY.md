# AMI Reverse Lookup Summary
## AMI: ami-03018fe8006ce8d21

### 🔍 Basic AMI Information
- **AMI ID**: `ami-03018fe8006ce8d21`
- **AMI Name**: `amidistribution-2025-10-20T16-28-54.190Z`
- **Creation Date**: `2025-10-20T16:51:40.000Z`
- **Platform**: `Windows`
- **OS Version**: `Microsoft Windows Server 2025`
- **Architecture**: `x86_64`
- **State**: `AVAILABLE`
- **Description**: `AMI distribution from Central Image Management Account`

---

## 📋 Pipeline Information

### Pipeline Details
- **Pipeline Name**: `ec2-image-builder-win2025`
- **Pipeline ARN**: `arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2025`
- **Pipeline Status**: `ENABLED`
- **Platform**: `Windows`
- **Description**: `Image Builder Pipeline for ec2-image-builder-win2025`

### Pipeline Schedule
- **Schedule Expression**: `cron(0 22 ? * 2#2 *)` (Runs every 2nd Tuesday at 10:00 PM UTC)
- **Execution Condition**: `EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE`
- **Last Run**: `2025-10-20T16:28:54.331Z`
- **Next Run**: `2025-11-10T22:00:00.000Z`

---

## 📦 Image Recipe Information

### Recipe Details
- **Recipe Name**: `WinServer2025`
- **Recipe ARN**: `arn:aws:imagebuilder:us-east-2:422228628991:image-recipe/winserver2025/1.0.4`
- **Recipe Version**: `1.0.4`
- **Description**: `WinServer2025-Ec2 Image Recipe`
- **Platform**: `Windows`
- **Recipe Created**: `2025-10-20T16:28:16.121Z`

### Base/Parent Image
- **Parent Image**: `arn:aws:imagebuilder:us-east-2:aws:image/windows-server-2025-english-full-base-x86/2025.10.15/1`
- **Working Directory**: `C:/`

### Components Installed (9 components)
1. **amazon-cloudwatch-agent-windows** - Version 1.0.0
2. **aws-cli-version-2-windows** - Version 1.0.0
3. **step1-setup-workingdirectory-windows** - Version 1.0.2 (Custom)
4. **step2-s3-download-windows** - Version 1.0.3 (Custom)
5. **step3-crowdstrike-installation-windows** - Version 1.0.0 (Custom)
6. **step4-qualys-installation-windows** - Version 1.0.2 (Custom)
7. **step5-mecm-staging-windows** - Version 1.0.0 (Custom)
8. **step6-startup-job-setup-windows** - Version 1.0.2 (Custom)
9. **step7-startup-job-setup-windows** - Version 1.0.1 (Custom)

### Block Device Configuration
- **Root Device**: `/dev/sda1`
- **Volume Size**: `100 GB`
- **Volume Type**: `gp3`
- **IOPS**: `3000`
- **Throughput**: `125 MB/s`
- **Encrypted**: `Yes`
- **KMS Key**: `arn:aws:kms:us-east-2:422228628991:alias/image-key`
- **Delete on Termination**: `Yes`

---

## 🏗️ Image Build Version Information

### Build Details
- **Image ARN**: `arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2025/1.0.4/2`
- **Image Name**: `WinServer2025`
- **Version**: `1.0.4`
- **Build Number**: `2` (Second build of version 1.0.4)
- **Build Type**: `USER_INITIATED`
- **Build Created**: `2025-10-20T16:28:54.259Z`
- **Status**: `AVAILABLE`

### Version/Build Breakdown
```
Recipe: winserver2025
Version: 1.0.4
Build: 2
Full Version String: 1.0.4/2
```

---

## 🏭 Infrastructure Configuration

### Build Infrastructure
- **Configuration Name**: `ec2-image-builder`
- **Instance Type**: `t3.medium`
- **Instance Profile**: `ec2-image-builder-instance-profile`
- **Security Group**: `sg-0abb038a635a6127e`
- **Subnet**: `subnet-0696ffc1ce55e5839`
- **Key Pair**: `image-builder-keypair`
- **Terminate on Failure**: `No`
- **SNS Topic**: `arn:aws:sns:us-east-2:422228628991:bread-imagemanagement-alerts`

---

## 🌍 Distribution Configuration

### Distribution Details
- **Distribution Config Name**: `ec2-image-builder`
- **Distributed Regions**:
  1. **us-east-2**: AMI ID `ami-03018fe8006ce8d21`
  2. **us-west-2**: AMI ID `ami-0c0576e419fb58455`

### AMI Distribution Settings
- **AMI Name Pattern**: `amidistribution-2025-10-20T16-28-54.190Z`
- **AMI Tags Applied**: 
  - `Name: GoldenAMI`
- **KMS Key**: `arn:aws:kms:us-east-2:422228628991:key/mrk-6fa2ef2f323e4121a715a6a05fe1cec4`
- **Launch Permissions**: Organization-wide (`o-6wrht8pxbo`)

---

## ✅ Image Testing Configuration

- **Image Tests Enabled**: `Yes`
- **Timeout**: `720 minutes` (12 hours)

---

## 🔄 Workflows Used

1. **Build Workflow**: `arn:aws:imagebuilder:us-east-2:aws:workflow/build/build-image/1.0.2/1`
2. **Test Workflow**: `arn:aws:imagebuilder:us-east-2:aws:workflow/test/test-image/1.0.2/1`

---

## 🏷️ Tags Applied

### Recipe Tags
- `bfh:environment`: `prd`
- `bfh:support-group`: `bfh.awsinfrastructure`

### Pipeline Tags
- `bfh:environment`: `prd`
- `bfh:support-group`: `bfh.awsinfrastructure`

### AMI Tags
- `Name`: `GoldenAMI`
- `CreatedBy`: `EC2 Image Builder`
- `Ec2ImageBuilderArn`: `arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2025/1.0.4/2`

---

## 📊 Summary

**What Pipeline?**: `ec2-image-builder-win2025`
- Pipeline ARN: `arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2025`

**What Recipe?**: `WinServer2025`
- Recipe ARN: `arn:aws:imagebuilder:us-east-2:422228628991:image-recipe/winserver2025/1.0.4`

**What Version?**: `1.0.4`
- Recipe version 1.0.4

**What Build?**: `Build #2` of version `1.0.4`
- Full version: `1.0.4/2`
- This is the second build/iteration of recipe version 1.0.4

---

## 🔗 Quick Reference Commands

### Get Image Builder ARN from AMI:
```bash
aws ec2 describe-images \
  --image-ids ami-03018fe8006ce8d21 \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --query 'Images[0].Tags[?Key==`Ec2ImageBuilderArn`].Value' \
  --output text
```

### Get Full Image Build Details:
```bash
aws imagebuilder get-image \
  --image-build-version-arn "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2025/1.0.4/2" \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --output json
```

### Get Pipeline Details:
```bash
aws imagebuilder get-image-pipeline \
  --image-pipeline-arn "arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2025" \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --output json
```

### Get Recipe Details:
```bash
aws imagebuilder get-image-recipe \
  --image-recipe-arn "arn:aws:imagebuilder:us-east-2:422228628991:image-recipe/winserver2025/1.0.4" \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --output json
```



