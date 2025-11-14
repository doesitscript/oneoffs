#!/bin/bash

PROFILE=$1
ACCOUNT_NAME=$2
OUTPUT_DIR="account_diagrams_data"

mkdir -p "$OUTPUT_DIR"

echo "Gathering resources for $ACCOUNT_NAME ($PROFILE)..."

# Get account identity
aws sts get-caller-identity --profile $PROFILE > "$OUTPUT_DIR/${ACCOUNT_NAME}_identity.json" 2>&1

# IAM Identity Center
aws sso-admin list-instances --region us-east-2 --profile $PROFILE > "$OUTPUT_DIR/${ACCOUNT_NAME}_sso_instances.json" 2>&1

# Identity Store groups
IDENTITY_STORE=$(jq -r '.Instances[0].IdentityStoreId // "d-9a6763d7d3"' "$OUTPUT_DIR/${ACCOUNT_NAME}_sso_instances.json" 2>/dev/null)
aws identitystore list-groups --identity-store-id $IDENTITY_STORE --region us-east-2 --profile $PROFILE --max-results 50 > "$OUTPUT_DIR/${ACCOUNT_NAME}_groups.json" 2>&1

# IAM Roles (for bfh_mgmt specifically)
aws iam list-roles --profile $PROFILE --max-items 100 > "$OUTPUT_DIR/${ACCOUNT_NAME}_iam_roles.json" 2>&1

# S3 buckets (for Log Archive)
aws s3 ls --profile $PROFILE > "$OUTPUT_DIR/${ACCOUNT_NAME}_s3_buckets.txt" 2>&1

# CloudTrail trails
aws cloudtrail describe-trails --profile $PROFILE --region us-east-2 > "$OUTPUT_DIR/${ACCOUNT_NAME}_cloudtrail.json" 2>&1

# VPCs
aws ec2 describe-vpcs --profile $PROFILE --region us-east-2 > "$OUTPUT_DIR/${ACCOUNT_NAME}_vpcs.json" 2>&1

echo "✓ Data collected for $ACCOUNT_NAME"
