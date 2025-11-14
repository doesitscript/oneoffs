#!/bin/bash
# Okta SCIM Sync Trigger Script
# Purpose: Manually trigger Okta to sync a group to AWS IAM Identity Center via SCIM
# Author: Research Team
# Date: November 14, 2025

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Target group information
GROUP_NAME="App-AWS-AA-database-sandbox-941677815499-admin"
AWS_IDENTITY_STORE_ID="d-9a6763d7d3"
AWS_GROUP_ID="711bf5c0-b071-70c1-06da-35d7fbcac52d"
AWS_REGION="us-east-2"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Okta SCIM Manual Sync Trigger Tool             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Target Group: ${YELLOW}${GROUP_NAME}${NC}"
echo ""

# Check prerequisites
echo -e "${BLUE}[1/6] Checking Prerequisites...${NC}"

# Check for required environment variables
if [ -z "$OKTA_DOMAIN" ]; then
    echo -e "  ${RED}✗${NC} OKTA_DOMAIN not set"
    echo ""
    echo "Please set the following environment variables:"
    echo ""
    echo "  export OKTA_DOMAIN=\"breadfinancial.okta.com\""
    echo "  export OKTA_API_TOKEN=\"your_api_token_here\""
    echo ""
    echo "To get an API token:"
    echo "  1. Log into Okta Admin Console"
    echo "  2. Security → API → Tokens"
    echo "  3. Create Token"
    echo ""
    exit 1
fi

if [ -z "$OKTA_API_TOKEN" ]; then
    echo -e "  ${RED}✗${NC} OKTA_API_TOKEN not set"
    exit 1
fi

echo -e "  ${GREEN}✓${NC} Okta domain: ${OKTA_DOMAIN}"
echo -e "  ${GREEN}✓${NC} API token configured"

# Check for curl and jq
if ! command -v curl &> /dev/null; then
    echo -e "  ${RED}✗${NC} curl not found"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "  ${YELLOW}⚠${NC} jq not found (JSON output will be raw)"
    HAS_JQ=false
else
    HAS_JQ=true
    echo -e "  ${GREEN}✓${NC} curl and jq found"
fi

echo ""

# Test Okta API access
echo -e "${BLUE}[2/6] Testing Okta API Access...${NC}"

OKTA_USER=$(curl -s -X GET "https://${OKTA_DOMAIN}/api/v1/users/me" \
    -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
    -H "Accept: application/json")

if echo "$OKTA_USER" | grep -q "errorCode"; then
    echo -e "  ${RED}✗${NC} Okta API authentication failed"
    echo "$OKTA_USER" | jq '.' 2>/dev/null || echo "$OKTA_USER"
    exit 1
fi

if [ "$HAS_JQ" = true ]; then
    USER_EMAIL=$(echo "$OKTA_USER" | jq -r '.profile.email')
    echo -e "  ${GREEN}✓${NC} Authenticated as: ${USER_EMAIL}"
else
    echo -e "  ${GREEN}✓${NC} Authenticated successfully"
fi

echo ""

# Find AWS IAM Identity Center app
echo -e "${BLUE}[3/6] Finding AWS IAM Identity Center App...${NC}"

AWS_APP=$(curl -s -X GET "https://${OKTA_DOMAIN}/api/v1/apps?q=AWS%20IAM%20Identity%20Center" \
    -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
    -H "Accept: application/json")

if [ "$HAS_JQ" = true ]; then
    AWS_APP_ID=$(echo "$AWS_APP" | jq -r '.[0].id')
    AWS_APP_NAME=$(echo "$AWS_APP" | jq -r '.[0].label')

    if [ "$AWS_APP_ID" = "null" ] || [ -z "$AWS_APP_ID" ]; then
        echo -e "  ${RED}✗${NC} AWS IAM Identity Center app not found"
        echo "     Searched for: 'AWS IAM Identity Center'"
        echo "     Available apps:"
        curl -s -X GET "https://${OKTA_DOMAIN}/api/v1/apps" \
            -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
            -H "Accept: application/json" | jq -r '.[].label' | head -10
        exit 1
    fi

    echo -e "  ${GREEN}✓${NC} Found: ${AWS_APP_NAME}"
    echo -e "  ${GREEN}✓${NC} App ID: ${AWS_APP_ID}"
else
    # Without jq, user needs to manually provide the app ID
    echo -e "  ${YELLOW}⚠${NC} Cannot parse JSON without jq"
    echo "     Please set AWS_APP_ID manually:"
    echo "     export AWS_APP_ID=\"your_app_id\""

    if [ -z "$AWS_APP_ID" ]; then
        exit 1
    fi

    echo -e "  ${GREEN}✓${NC} Using provided AWS_APP_ID: ${AWS_APP_ID}"
fi

echo ""

# Find the Okta group
echo -e "${BLUE}[4/6] Finding Okta Group...${NC}"

OKTA_GROUP=$(curl -s -X GET "https://${OKTA_DOMAIN}/api/v1/groups?q=${GROUP_NAME}" \
    -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
    -H "Accept: application/json")

if [ "$HAS_JQ" = true ]; then
    OKTA_GROUP_ID=$(echo "$OKTA_GROUP" | jq -r '.[0].id')
    OKTA_GROUP_NAME=$(echo "$OKTA_GROUP" | jq -r '.[0].profile.name')

    if [ "$OKTA_GROUP_ID" = "null" ] || [ -z "$OKTA_GROUP_ID" ]; then
        echo -e "  ${RED}✗${NC} Group not found: ${GROUP_NAME}"
        exit 1
    fi

    echo -e "  ${GREEN}✓${NC} Found: ${OKTA_GROUP_NAME}"
    echo -e "  ${GREEN}✓${NC} Group ID: ${OKTA_GROUP_ID}"

    # Get member count
    MEMBER_COUNT=$(curl -s -X GET "https://${OKTA_DOMAIN}/api/v1/groups/${OKTA_GROUP_ID}/users" \
        -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
        -H "Accept: application/json" | jq '. | length')

    echo -e "  ${GREEN}✓${NC} Members in Okta: ${MEMBER_COUNT}"

    if [ "$MEMBER_COUNT" -eq 0 ]; then
        echo -e "  ${YELLOW}⚠${NC} Warning: Group is empty in Okta"
        echo "     No members to sync to AWS!"
        echo ""
        echo "     To add members first:"
        echo "     1. Log into Okta Admin Console"
        echo "     2. Directory → Groups → ${GROUP_NAME}"
        echo "     3. Click 'Manage People'"
        echo "     4. Add users"
        echo "     5. Run this script again"
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
else
    echo -e "  ${YELLOW}⚠${NC} Cannot verify group without jq"

    if [ -z "$OKTA_GROUP_ID" ]; then
        echo "     Please set OKTA_GROUP_ID manually:"
        echo "     export OKTA_GROUP_ID=\"your_group_id\""
        exit 1
    fi

    echo -e "  ${GREEN}✓${NC} Using provided OKTA_GROUP_ID: ${OKTA_GROUP_ID}"
fi

echo ""

# Check AWS before sync
echo -e "${BLUE}[5/6] Checking AWS State Before Sync...${NC}"

if command -v aws &> /dev/null; then
    BEFORE_COUNT=$(aws identitystore list-group-memberships \
        --identity-store-id "$AWS_IDENTITY_STORE_ID" \
        --group-id "$AWS_GROUP_ID" \
        --region "$AWS_REGION" \
        --query 'length(GroupMemberships)' \
        --output text 2>/dev/null || echo "0")

    echo -e "  ${GREEN}✓${NC} Current AWS group members: ${BEFORE_COUNT}"
else
    echo -e "  ${YELLOW}⚠${NC} AWS CLI not available (cannot verify)"
    BEFORE_COUNT="unknown"
fi

echo ""

# Trigger the sync
echo -e "${BLUE}[6/6] Triggering SCIM Sync...${NC}"
echo ""
echo -e "${YELLOW}This will trigger Okta to immediately sync the group to AWS via SCIM.${NC}"
echo ""
read -p "Proceed with sync? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo -e "  Triggering sync..."

# Method 1: Assign/reassign group to app (forces push)
SYNC_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X PUT \
    "https://${OKTA_DOMAIN}/api/v1/apps/${AWS_APP_ID}/groups/${OKTA_GROUP_ID}" \
    -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json")

HTTP_CODE=$(echo "$SYNC_RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
RESPONSE_BODY=$(echo "$SYNC_RESPONSE" | sed '/HTTP_CODE:/d')

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    echo -e "  ${GREEN}✓${NC} Sync triggered successfully (HTTP ${HTTP_CODE})"

    if [ "$HAS_JQ" = true ]; then
        echo ""
        echo "Response:"
        echo "$RESPONSE_BODY" | jq '.'
    fi
else
    echo -e "  ${RED}✗${NC} Sync trigger failed (HTTP ${HTTP_CODE})"
    echo ""
    echo "Response:"
    echo "$RESPONSE_BODY"
    exit 1
fi

echo ""
echo -e "${YELLOW}Waiting for SCIM sync to complete...${NC}"
echo -e "This typically takes 2-5 minutes."
echo ""

# Wait and check
for i in {1..6}; do
    echo -e "Checking... (${i}/6) - waiting 30 seconds"
    sleep 30

    if command -v aws &> /dev/null; then
        CURRENT_COUNT=$(aws identitystore list-group-memberships \
            --identity-store-id "$AWS_IDENTITY_STORE_ID" \
            --group-id "$AWS_GROUP_ID" \
            --region "$AWS_REGION" \
            --query 'length(GroupMemberships)' \
            --output text 2>/dev/null || echo "0")

        if [ "$CURRENT_COUNT" != "$BEFORE_COUNT" ]; then
            echo ""
            echo -e "${GREEN}✓ Success! Group membership changed!${NC}"
            echo -e "  Before: ${BEFORE_COUNT} members"
            echo -e "  After:  ${CURRENT_COUNT} members"
            echo ""

            # Show the members
            echo "Current members:"
            aws identitystore list-group-memberships \
                --identity-store-id "$AWS_IDENTITY_STORE_ID" \
                --group-id "$AWS_GROUP_ID" \
                --region "$AWS_REGION" \
                --output table

            echo ""
            echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║              Sync Completed Successfully!              ║${NC}"
            echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
            exit 0
        fi
    fi
done

echo ""
echo -e "${YELLOW}⚠${NC} Sync may still be in progress or no changes detected."
echo ""
echo "Final check:"

if command -v aws &> /dev/null; then
    FINAL_COUNT=$(aws identitystore list-group-memberships \
        --identity-store-id "$AWS_IDENTITY_STORE_ID" \
        --group-id "$AWS_GROUP_ID" \
        --region "$AWS_REGION" \
        --query 'length(GroupMemberships)' \
        --output text 2>/dev/null || echo "0")

    echo -e "  Current AWS members: ${FINAL_COUNT}"

    if [ "$FINAL_COUNT" = "$BEFORE_COUNT" ]; then
        echo ""
        echo -e "${YELLOW}No change detected. Possible reasons:${NC}"
        echo "  1. Okta group is empty (no users to sync)"
        echo "  2. SCIM sync takes longer than 3 minutes"
        echo "  3. SCIM connection has issues"
        echo "  4. Group push settings need configuration"
        echo ""
        echo "Next steps:"
        echo "  - Check Okta Admin Console → Apps → AWS IAM Identity Center → Push Groups"
        echo "  - Verify group has members in Okta"
        echo "  - Check SCIM provisioning logs in Okta"
        echo "  - Wait a few more minutes and check AWS again"
    fi
fi

echo ""
echo "For detailed investigation, run:"
echo "  ./investigate_sync.sh"
echo ""

exit 0
