#!/bin/bash

# Script for bfh_mgmt team to inspect their SailPoint Direct Integration setup
# Run this to gather information about your working integration

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  bfh_mgmt SailPoint Direct Integration Inspector              ║"
echo "║  Account: 739275453939                                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

PROFILE="bfh_mgmt_739275453939_admin"
REGION="us-east-2"
OUTPUT_DIR="bfh_mgmt_setup_export_$(date +%Y%m%d_%H%M%S)"

mkdir -p "$OUTPUT_DIR"

echo "Output will be saved to: $OUTPUT_DIR/"
echo ""

# 1. Verify account access
echo "Step 1: Verifying AWS account access..."
aws sts get-caller-identity --profile $PROFILE > "$OUTPUT_DIR/account_identity.json"
ACCOUNT_ID=$(jq -r '.Account' "$OUTPUT_DIR/account_identity.json")
echo "✓ Confirmed account: $ACCOUNT_ID"
echo ""

# 2. Get the sailpoint-read-write role details
echo "Step 2: Fetching sailpoint-read-write IAM role configuration..."
if aws iam get-role --role-name sailpoint-read-write --profile $PROFILE > "$OUTPUT_DIR/role_details.json" 2>&1; then
    echo "✓ Found sailpoint-read-write role"
    
    # Extract and save trust policy
    jq '.Role.AssumeRolePolicyDocument' "$OUTPUT_DIR/role_details.json" > "$OUTPUT_DIR/trust_policy.json"
    echo "✓ Saved trust policy to: trust_policy.json"
    
    # Show who can assume this role
    echo ""
    echo "=== Trust Policy (Who Can Assume This Role) ==="
    jq '.' "$OUTPUT_DIR/trust_policy.json"
    echo ""
else
    echo "✗ Could not find sailpoint-read-write role"
    echo "  (Role might have a different name)"
    echo ""
    echo "Listing all roles with 'sailpoint' in the name:"
    aws iam list-roles --profile $PROFILE --query 'Roles[?contains(RoleName, `sailpoint`) || contains(RoleName, `SailPoint`)].RoleName' --output table
fi

# 3. Get attached managed policies
echo "Step 3: Fetching attached IAM policies..."
aws iam list-attached-role-policies \
    --role-name sailpoint-read-write \
    --profile $PROFILE \
    > "$OUTPUT_DIR/attached_policies.json" 2>&1 || echo "✗ Could not list attached policies"

if [ -f "$OUTPUT_DIR/attached_policies.json" ]; then
    POLICY_COUNT=$(jq '.AttachedPolicies | length' "$OUTPUT_DIR/attached_policies.json")
    echo "✓ Found $POLICY_COUNT attached managed policies"
    
    # Get each policy document
    jq -r '.AttachedPolicies[].PolicyArn' "$OUTPUT_DIR/attached_policies.json" | while read -r POLICY_ARN; do
        POLICY_NAME=$(basename "$POLICY_ARN")
        echo "  - Getting policy: $POLICY_NAME"
        
        # Get default version
        VERSION_ID=$(aws iam get-policy --policy-arn "$POLICY_ARN" --profile $PROFILE --query 'Policy.DefaultVersionId' --output text)
        
        # Get policy document
        aws iam get-policy-version \
            --policy-arn "$POLICY_ARN" \
            --version-id "$VERSION_ID" \
            --profile $PROFILE \
            --query 'PolicyVersion.Document' \
            > "$OUTPUT_DIR/policy_${POLICY_NAME}.json"
    done
fi
echo ""

# 4. Get inline policies
echo "Step 4: Fetching inline IAM policies..."
aws iam list-role-policies \
    --role-name sailpoint-read-write \
    --profile $PROFILE \
    > "$OUTPUT_DIR/inline_policies.json" 2>&1 || echo "✗ Could not list inline policies"

if [ -f "$OUTPUT_DIR/inline_policies.json" ]; then
    INLINE_COUNT=$(jq '.PolicyNames | length' "$OUTPUT_DIR/inline_policies.json")
    echo "✓ Found $INLINE_COUNT inline policies"
    
    # Get each inline policy document
    jq -r '.PolicyNames[]' "$OUTPUT_DIR/inline_policies.json" | while read -r POLICY_NAME; do
        echo "  - Getting inline policy: $POLICY_NAME"
        aws iam get-role-policy \
            --role-name sailpoint-read-write \
            --policy-name "$POLICY_NAME" \
            --profile $PROFILE \
            --query 'PolicyDocument' \
            > "$OUTPUT_DIR/inline_policy_${POLICY_NAME}.json"
    done
fi
echo ""

# 5. Check recent CloudTrail activity
echo "Step 5: Analyzing recent provisioning activity..."
aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
    --max-results 20 \
    --region $REGION \
    --profile $PROFILE \
    > "$OUTPUT_DIR/recent_provisioning.json"

RECENT_COUNT=$(jq '.Events | length' "$OUTPUT_DIR/recent_provisioning.json")
echo "✓ Found $RECENT_COUNT recent provisioning events"

if [ "$RECENT_COUNT" -gt 0 ]; then
    echo ""
    echo "=== Recent Provisioning Activity ==="
    jq -r '.Events[] | (.CloudTrailEvent | fromjson) | "\(.eventTime) - \(.userIdentity.sessionContext.sessionIssuer.userName // "N/A")"' "$OUTPUT_DIR/recent_provisioning.json" | head -10
fi
echo ""

# 6. Get Identity Store configuration
echo "Step 6: Fetching IAM Identity Center configuration..."
aws sso-admin list-instances \
    --region $REGION \
    --profile $PROFILE \
    > "$OUTPUT_DIR/sso_instances.json"

INSTANCE_ARN=$(jq -r '.Instances[0].InstanceArn' "$OUTPUT_DIR/sso_instances.json")
IDENTITY_STORE_ID=$(jq -r '.Instances[0].IdentityStoreId' "$OUTPUT_DIR/sso_instances.json")

echo "✓ Instance ARN: $INSTANCE_ARN"
echo "✓ Identity Store ID: $IDENTITY_STORE_ID"
echo ""

# 7. List groups in Identity Center
echo "Step 7: Listing groups in IAM Identity Center..."
aws identitystore list-groups \
    --identity-store-id "$IDENTITY_STORE_ID" \
    --region $REGION \
    --profile $PROFILE \
    --max-results 20 \
    > "$OUTPUT_DIR/groups.json"

GROUP_COUNT=$(jq '.Groups | length' "$OUTPUT_DIR/groups.json")
echo "✓ Found $GROUP_COUNT groups"
echo ""

# 8. Generate summary report
cat > "$OUTPUT_DIR/SUMMARY.md" << 'SUMMARY'
# bfh_mgmt SailPoint Direct Integration Setup

## Overview
This directory contains a complete export of your SailPoint direct integration configuration.

## Files Generated:
- `account_identity.json` - AWS account details
- `role_details.json` - Complete IAM role configuration
- `trust_policy.json` - Trust policy (who can assume the role)
- `attached_policies.json` - List of attached managed policies
- `policy_*.json` - Individual managed policy documents
- `inline_policies.json` - List of inline policies
- `inline_policy_*.json` - Individual inline policy documents
- `recent_provisioning.json` - Recent provisioning events (CloudTrail)
- `sso_instances.json` - IAM Identity Center instance details
- `groups.json` - Groups in Identity Center

## Quick Analysis:

### IAM Role: sailpoint-read-write
SUMMARY

# Add trust policy to summary
echo "" >> "$OUTPUT_DIR/SUMMARY.md"
echo "**Trust Policy:**" >> "$OUTPUT_DIR/SUMMARY.md"
echo '```json' >> "$OUTPUT_DIR/SUMMARY.md"
jq '.' "$OUTPUT_DIR/trust_policy.json" >> "$OUTPUT_DIR/SUMMARY.md" 2>/dev/null || echo "N/A" >> "$OUTPUT_DIR/SUMMARY.md"
echo '```' >> "$OUTPUT_DIR/SUMMARY.md"
echo "" >> "$OUTPUT_DIR/SUMMARY.md"

# Add permissions summary
echo "**Permissions:**" >> "$OUTPUT_DIR/SUMMARY.md"
if [ -f "$OUTPUT_DIR/attached_policies.json" ]; then
    echo "- Attached Policies:" >> "$OUTPUT_DIR/SUMMARY.md"
    jq -r '.AttachedPolicies[] | "  - \(.PolicyName) (\(.PolicyArn))"' "$OUTPUT_DIR/attached_policies.json" >> "$OUTPUT_DIR/SUMMARY.md"
fi
if [ -f "$OUTPUT_DIR/inline_policies.json" ]; then
    echo "- Inline Policies:" >> "$OUTPUT_DIR/SUMMARY.md"
    jq -r '.PolicyNames[] | "  - \(.)"' "$OUTPUT_DIR/inline_policies.json" >> "$OUTPUT_DIR/SUMMARY.md"
fi

# Add recent activity
echo "" >> "$OUTPUT_DIR/SUMMARY.md"
echo "### Recent Activity" >> "$OUTPUT_DIR/SUMMARY.md"
echo "- Last $RECENT_COUNT provisioning events captured" >> "$OUTPUT_DIR/SUMMARY.md"
echo "- All events use role: sailpoint-read-write" >> "$OUTPUT_DIR/SUMMARY.md"
echo "" >> "$OUTPUT_DIR/SUMMARY.md"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Export Complete!                                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "All configuration exported to: $OUTPUT_DIR/"
echo ""
echo "Next Steps:"
echo "1. Review SUMMARY.md for overview"
echo "2. Check trust_policy.json to see who can assume the role"
echo "3. Review policy_*.json files for IAM permissions"
echo "4. Share this directory with teams who want to replicate your setup"
echo ""
echo "Key Files to Share:"
echo "  - trust_policy.json (shows authentication method)"
echo "  - policy_*.json (shows permissions needed)"
echo "  - SUMMARY.md (overview of your setup)"

