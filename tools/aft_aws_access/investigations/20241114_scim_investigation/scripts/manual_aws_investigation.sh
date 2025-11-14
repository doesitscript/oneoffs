#!/bin/bash
# Manual AWS Investigation Script
# Purpose: Commands to run on YOUR machine with AWS CLI configured
# This script provides copy-paste commands since automated execution failed

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
IDENTITY_STORE_ID="d-9a6763d7d3"
TARGET_GROUP_ID="711bf5c0-b071-70c1-06da-35d7fbcac52d"
TARGET_GROUP_NAME="App-AWS-AA-database-sandbox-941677815499-admin"
AWS_REGION="us-east-2"
USER_TO_SEARCH="aa-a837831"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     AWS Manual Investigation - Command Reference            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}These commands are for you to copy and run manually${NC}"
echo -e "${YELLOW}since AWS CLI is not configured in the automation environment${NC}"
echo ""

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}INVESTIGATION 1: CloudTrail - Recent SCIM Activity${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

cat << 'EOF'
# Get recent SCIM events (last sync activity)
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=identitystore.amazonaws.com \
  --max-results 20 \
  --region us-east-2 \
  --output json > scim_events.json

# View events in table format
cat scim_events.json | jq -r '.Events[] | [.EventTime, .EventName, .Username] | @tsv' | column -t

# Count by event type
cat scim_events.json | jq -r '.Events[] | .EventName' | sort | uniq -c

# Find CreateGroupMembership events specifically
cat scim_events.json | jq '.Events[] | select(.EventName == "CreateGroupMembership")'

EOF

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}INVESTIGATION 2: Find Functional Groups (With Members)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

cat << 'EOF'
# List ALL groups
aws identitystore list-groups \
  --identity-store-id d-9a6763d7d3 \
  --region us-east-2 \
  --output json > all_groups.json

# Count total groups
cat all_groups.json | jq '.Groups | length'

# Show group names
cat all_groups.json | jq -r '.Groups[] | .DisplayName' | sort

# Check each group for members (this will take a while)
cat all_groups.json | jq -r '.Groups[] | .GroupId' | while read gid; do
  count=$(aws identitystore list-group-memberships \
    --identity-store-id d-9a6763d7d3 \
    --group-id "$gid" \
    --region us-east-2 \
    --query 'length(GroupMemberships)' \
    --output text 2>/dev/null || echo "0")

  if [ "$count" != "0" ] && [ "$count" != "None" ]; then
    name=$(cat all_groups.json | jq -r ".Groups[] | select(.GroupId == \"$gid\") | .DisplayName")
    echo "Group: $name ($gid) - Members: $count"
  fi
done > functional_groups.txt

# View results
cat functional_groups.txt

EOF

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}INVESTIGATION 3: Compare Functional vs Empty Group${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

cat << 'EOF'
# Pick a functional group ID from the previous output
FUNCTIONAL_GROUP_ID="<paste_group_id_here>"
EMPTY_GROUP_ID="711bf5c0-b071-70c1-06da-35d7fbcac52d"

# Get details of functional group
aws identitystore describe-group \
  --identity-store-id d-9a6763d7d3 \
  --group-id "$FUNCTIONAL_GROUP_ID" \
  --region us-east-2

# Get its members
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id "$FUNCTIONAL_GROUP_ID" \
  --region us-east-2

# Search CloudTrail for when this group got members
aws cloudtrail lookup-events \
  --region us-east-2 \
  --max-results 100 \
  --output json | jq ".Events[] | select(.CloudTrailEvent | contains(\"$FUNCTIONAL_GROUP_ID\"))"

# Search specifically for CreateGroupMembership events
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
  --max-results 50 \
  --region us-east-2 \
  --output json | jq ".Events[] | select(.CloudTrailEvent | contains(\"$FUNCTIONAL_GROUP_ID\"))"

EOF

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}INVESTIGATION 4: Search for User aa-a837831${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

cat << 'EOF'
# Search by exact username
aws identitystore list-users \
  --identity-store-id d-9a6763d7d3 \
  --region us-east-2 \
  --filters AttributePath=UserName,AttributeValue=aa-a837831

# If not found, get ALL users and search
aws identitystore list-users \
  --identity-store-id d-9a6763d7d3 \
  --region us-east-2 \
  --output json > all_users.json

# Search for partial match
cat all_users.json | jq '.Users[] | select(.UserName | contains("a837831"))'

# Or search for any user with "aa-" prefix
cat all_users.json | jq '.Users[] | select(.UserName | startswith("aa-"))'

# Count total users
cat all_users.json | jq '.Users | length'

# If you find the user, save the UserId
USER_ID=$(cat all_users.json | jq -r '.Users[] | select(.UserName | contains("a837831")) | .UserId')
echo "User ID: $USER_ID"

EOF

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}INVESTIGATION 5: What CloudTrail Events Look Like for Working Groups${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

cat << 'EOF'
# Get ALL CreateGroupMembership events
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
  --max-results 50 \
  --region us-east-2 \
  --output json > group_membership_events.json

# Parse and understand the structure
cat group_membership_events.json | jq '.Events[0]' > sample_event.json

# View the sample event
cat sample_event.json | jq '.'

# Extract key information from all events
cat group_membership_events.json | jq -r '.Events[] |
  .CloudTrailEvent | fromjson |
  {
    time: .eventTime,
    user: .userIdentity.principalId,
    groupId: .requestParameters.GroupId,
    memberId: .requestParameters.MemberId.UserId
  }'

EOF

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}INVESTIGATION 6: Trigger Points - What Causes Group Population${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

cat << 'EOF'
# Look for the source of CreateGroupMembership events
cat group_membership_events.json | jq -r '.Events[] |
  .CloudTrailEvent | fromjson |
  {
    eventTime: .eventTime,
    userAgent: .userAgent,
    sourceIPAddress: .sourceIPAddress,
    userType: .userIdentity.type
  }' | head -20

# The userAgent will tell you if it's:
# - "AWS Internal" = SCIM sync from Okta
# - "console.amazonaws.com" = Manual via AWS Console
# - "AWS CLI" = Manual via AWS CLI
# - Contains "Okta" or "SCIM" = Okta SCIM client

EOF

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}INVESTIGATION 7: Check Empty Group for Any Historical Activity${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

cat << 'EOF'
# Search for ANY events related to our target empty group
EMPTY_GROUP_ID="711bf5c0-b071-70c1-06da-35d7fbcac52d"

# Search all CloudTrail events for this group ID
aws cloudtrail lookup-events \
  --region us-east-2 \
  --max-results 100 \
  --output json | \
  jq ".Events[] | select(.CloudTrailEvent | contains(\"$EMPTY_GROUP_ID\"))"

# Specifically look for group creation
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroup \
  --region us-east-2 \
  --max-results 20 | \
  jq ".Events[] | select(.CloudTrailEvent | contains(\"$EMPTY_GROUP_ID\"))"

# Look for any group membership attempts (even failed ones)
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
  --region us-east-2 \
  --max-results 100 | \
  jq ".Events[] | select(.CloudTrailEvent | contains(\"$EMPTY_GROUP_ID\"))"

EOF

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}QUICK SUMMARY COMMANDS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

cat << 'EOF'
# One-liner: Find all groups with members
aws identitystore list-groups --identity-store-id d-9a6763d7d3 --region us-east-2 --output json | \
jq -r '.Groups[] | .GroupId' | while read gid; do
  count=$(aws identitystore list-group-memberships --identity-store-id d-9a6763d7d3 --group-id "$gid" --region us-east-2 --query 'length(GroupMemberships)' --output text 2>/dev/null)
  if [ "$count" != "0" ] && [ "$count" != "None" ]; then
    aws identitystore describe-group --identity-store-id d-9a6763d7d3 --group-id "$gid" --region us-east-2 --query 'DisplayName' --output text
  fi
done

# One-liner: Last 10 SCIM events
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=identitystore.amazonaws.com \
  --max-results 10 \
  --region us-east-2 \
  --query 'Events[*].[EventTime,EventName]' \
  --output table

# One-liner: Search for user
aws identitystore list-users \
  --identity-store-id d-9a6763d7d3 \
  --region us-east-2 | \
  jq '.Users[] | select(.UserName | contains("a837831"))'

EOF

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}EXPECTED FINDINGS${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "When you run these commands, you should find:"
echo ""
echo "1. ${GREEN}Recent SCIM Events:${NC}"
echo "   - CreateGroupMembership events from Okta SCIM client"
echo "   - Shows which groups ARE being populated"
echo "   - Shows timing of syncs"
echo ""
echo "2. ${GREEN}Functional Groups:${NC}"
echo "   - Several groups WITH members"
echo "   - Pattern: App-AWS-AA-{account}-{id}-{role}"
echo "   - These were successfully synced from Okta"
echo ""
echo "3. ${GREEN}Empty Group Difference:${NC}"
echo "   - Target group has NO CloudTrail events"
echo "   - OR has CreateGroup but no CreateGroupMembership"
echo "   - Indicates Okta never pushed members to it"
echo ""
echo "4. ${GREEN}User aa-a837831:${NC}"
echo "   - Exists in Identity Center"
echo "   - May or may not be in any groups"
echo "   - UserId needed for manual addition"
echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}SAVE YOUR RESULTS${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Recommended: Save all output to files for analysis"
echo ""

cat << 'EOF'
# Create investigation folder
mkdir -p aws_investigation_$(date +%Y%m%d)
cd aws_investigation_$(date +%Y%m%d)

# Run all investigations and save
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=identitystore.amazonaws.com \
  --max-results 50 --region us-east-2 > 01_scim_events.json

aws identitystore list-groups \
  --identity-store-id d-9a6763d7d3 \
  --region us-east-2 > 02_all_groups.json

aws identitystore list-users \
  --identity-store-id d-9a6763d7d3 \
  --region us-east-2 > 03_all_users.json

# Generate summary
echo "Investigation completed: $(date)" > README.txt
echo "Total groups: $(cat 02_all_groups.json | jq '.Groups | length')" >> README.txt
echo "Total users: $(cat 03_all_users.json | jq '.Users | length')" >> README.txt
echo "Recent SCIM events: $(cat 01_scim_events.json | jq '.Events | length')" >> README.txt

EOF

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}End of Command Reference${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Copy and paste these commands to your terminal with AWS access"
echo ""
