#!/bin/bash
# AWS CLI command to get latest AMI from Image Builder WinServer2022
# Using Method 3: jq for filtering Ec2ImageBuilderArn containing "winserver2022"
# Equivalent to Terraform: data "aws_ami" "winserver2022_latest"

# Configuration from imagebuilder.json
OWNER="422228628991"
REGION="us-east-2"  # Change to "us-west-2" for that region

echo "🔍 Finding latest Windows AMI where Ec2ImageBuilderArn contains 'winserver2022' in region ${REGION}..."
echo ""

# PART 1: Get all Windows images (owners self)
# PART 2: Filter where Ec2ImageBuilderArn tag contains "winserver2022" and get newest
aws ec2 describe-images \
  --owners "${OWNER}" \
  --region "${REGION}" \
  --filters "Name=platform,Values=windows" \
  --query 'Images[*]' | \
  jq '[.[] | select(.Tags[]? | select(.Key=="Ec2ImageBuilderArn" and (.Value | contains("winserver2022"))))] | sort_by(.CreationDate) | reverse | .[0]'

echo ""
echo "📋 To get just the AMI ID (plain text):"
echo ""
echo "aws ec2 describe-images \\"
echo "  --owners ${OWNER} \\"
echo "  --region ${REGION} \\"
echo "  --filters \"Name=platform,Values=windows\" \\"
echo "  --query 'Images[*]' | \\"
echo "  jq -r '[.[] | select(.Tags[]? | select(.Key==\"Ec2ImageBuilderArn\" and (.Value | contains(\"winserver2022\"))))] | sort_by(.CreationDate) | reverse | .[0].ImageId'"

