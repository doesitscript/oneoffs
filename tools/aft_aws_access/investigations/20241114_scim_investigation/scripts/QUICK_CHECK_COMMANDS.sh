#!/bin/bash

# Quick Check Script for AWS IAM Identity Center Group
# Use this to check if group has received any new members
# Created: November 14, 2025

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  AWS Group Membership Status Check                           ║"
echo "║  Account: database_sandbox (941677815499)                     ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Configuration
PROFILE="database_sandbox_941677815499_admin"
IDENTITY_STORE_ID="d-9a6763d7d3"
GROUP_ID="711bf5c0-b071-70c1-06da-35d7fbcac52d"
REGION="us-east-2"
INVESTIGATION_DATE="2025-11-14T00:00:00Z"

echo "Step 1: Verifying AWS access..."
aws sts get-caller-identity --profile $PROFILE --query 'Account' --output text
echo ""

echo "Step 2: Checking current group members..."
MEMBER_COUNT=$(aws identitystore list-group-memberships \
  --identity-store-id $IDENTITY_STORE_ID \
  --group-id $GROUP_ID \
  --region $REGION \
  --profile $PROFILE \
  --query 'length(GroupMemberships)' \
  --output text 2>/dev/null || echo "0")

echo "Current member count: $MEMBER_COUNT"
echo ""

if [ "$MEMBER_COUNT" -eq 0 ]; then
    echo "❌ Group is STILL EMPTY (no change since Nov 14, 2025)"
else
    echo "✅ Group HAS MEMBERS! ($MEMBER_COUNT members found)"
    echo ""
    echo "Fetching member details..."
    aws identitystore list-group-memberships \
      --identity-store-id $IDENTITY_STORE_ID \
      --group-id $GROUP_ID \
      --region $REGION \
      --profile $PROFILE
fi

echo ""
echo "Step 3: Checking CloudTrail for recent activity..."
EVENT_COUNT=$(aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
  --start-time $INVESTIGATION_DATE \
  --max-results 50 \
  --region $REGION \
  --profile $PROFILE \
  --query 'length(Events)' \
  --output text 2>/dev/null || echo "0")

echo "New events since Nov 14, 2025: $EVENT_COUNT"
echo ""

if [ "$EVENT_COUNT" -gt 0 ]; then
    echo "✅ NEW ACTIVITY DETECTED!"
    echo ""
    echo "Analyzing provisioning method..."
    
    aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
      --start-time $INVESTIGATION_DATE \
      --max-results 50 \
      --region $REGION \
      --profile $PROFILE \
      > recent_events_$(date +%Y%m%d_%H%M%S).json
    
    echo "User agents detected:"
    jq -r '.Events[].CloudTrailEvent | fromjson | .userAgent' recent_events_*.json | sort | uniq -c
    echo ""
    
    echo "Provisioning method:"
    USER_AGENT=$(jq -r '.Events[0].CloudTrailEvent | fromjson | .userAgent' recent_events_*.json)
    
    if [[ "$USER_AGENT" == *"aws-cli"* ]]; then
        echo "📋 Manual AWS CLI"
    elif [[ "$USER_AGENT" == "AWS Internal" ]]; then
        echo "🖥️  Manual AWS Console"
    elif [[ "$USER_AGENT" == *"aws-sdk-go"* ]]; then
        echo "🤖 SailPoint Direct Integration (SIGNIFICANT!)"
    elif [[ "$USER_AGENT" == *"okta"* ]] || [[ "$USER_AGENT" == *"scim"* ]]; then
        echo "🔄 Okta SCIM Sync (VERY SIGNIFICANT - was broken!)"
    else
        echo "❓ Unknown: $USER_AGENT"
    fi
else
    echo "⚠️  No new activity (group likely still empty)"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  Check Complete                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "For detailed investigation, see: INSTRUCTIONS_FOR_NEXT_AGENT.md"

