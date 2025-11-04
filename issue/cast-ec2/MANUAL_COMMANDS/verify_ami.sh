#!/bin/bash
# Quick script to verify if Windows Server 2022 AMIs exist matching the Terraform filters

REGION=${AWS_REGION:-us-east-2}
OWNER="422228628991"

echo "Checking for Windows Server 2022 AMIs matching Terraform filters..."
echo "Region: $REGION"
echo "Owner: $OWNER"
echo ""

aws ec2 describe-images \
  --owners $OWNER \
  --region $REGION \
  --filters \
    "Name=tag-key,Values=Ec2ImageBuilderArn" \
    "Name=tag:Name,Values=GoldenAMI" \
    "Name=platform-details,Values=Windows" \
    "Name=virtualization-type,Values=hvm" \
    "Name=architecture,Values=x86_64" \
    "Name=state,Values=available" \
  --query 'Images[*].{AMI_ID:ImageId,Name:Name,ARN:Tags[?Key==`Ec2ImageBuilderArn`].Value | [0],CreationDate:CreationDate}' \
  --output table | grep -i winserver2022

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Windows Server 2022 AMIs found!"
else
  echo ""
  echo "❌ No Windows Server 2022 AMIs found matching the criteria"
  echo ""
  echo "This means:"
  echo "  - Either no winserver2022 AMIs have been built yet"
  echo "  - Or the AMIs exist but don't match the filters (wrong tags, region, etc.)"
  echo ""
  echo "Solution options:"
  echo "  1. Wait for Image Builder pipeline to create winserver2022 AMIs"
  echo "  2. Temporarily set var.ami_id in your tfvars to use a specific AMI"
  echo "  3. Check if winserver2025 AMIs exist instead (and update recipe filter if needed)"
fi

