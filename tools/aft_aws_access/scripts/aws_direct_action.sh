#!/bin/bash
# AWS Direct Action Script - Investigate and Populate IAM Identity Center Group
# Purpose: Check what you can do from AWS side and optionally take action
# Author: Research Team
# Date: November 14, 2025

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
GROUP_ID="711bf5c0-b071-70c1-06da-35d7fbcac52d"
GROUP_NAME="App-AWS-AA-database-sandbox-941677815499-admin"
AWS_REGION="us-east-2"
SCIM_ENDPOINT="https://scim.us-east-2.amazonaws.com/Hw554936506-e755-4811-8646-adb52f76906a/scim/v2"
SCIM_TOKEN="78f3b96c-ba48-44ca-88da-1e7b2ac73e7b"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   AWS Direct Action - IAM Identity Center Group Management    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}⚠️  WARNING: This script can directly modify AWS IAM Identity Center${NC}"
echo -e "${YELLOW}   Bypasses SailPoint governance - use only in emergencies${NC}"
echo ""

# Check prerequisites
echo -e "${CYAN}[1/8] Checking Prerequisites...${NC}"

if ! command -v aws &> /dev/null; then
    echo -e "  ${RED}✗${NC} AWS CLI not installed"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "  ${YELLOW}⚠${NC} jq not installed (JSON parsing will be limited)"
    JQ_AVAILABLE=false
else
    JQ_AVAILABLE=true
fi

echo -e "  ${GREEN}✓${NC} Prerequisites checked"
echo ""

# Check AWS credentials
echo -e "${CYAN}[2/8] Checking AWS Credentials...${NC}"

if ! aws sts get-caller-identity --region "$AWS_REGION" &> /dev/null; then
    echo -e "  ${RED}✗${NC} AWS credentials not configured"
    echo ""
    echo "Please configure AWS credentials:"
    echo "  aws configure sso"
    echo "  OR"
    echo "  aws configure"
    exit 1
fi

ACCOUNT=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
IDENTITY=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null)

echo -e "  ${GREEN}✓${NC} AWS credentials valid"
echo -e "  ${GREEN}✓${NC} Account: $ACCOUNT"
echo -e "  ${GREEN}✓${NC} Identity: $IDENTITY"
echo ""

# Check current group state
echo -e "${CYAN}[3/8] Checking Current Group State...${NC}"

if ! GROUP_INFO=$(aws identitystore describe-group \
    --identity-store-id "$IDENTITY_STORE_ID" \
    --group-id "$GROUP_ID" \
    --region "$AWS_REGION" 2>&1); then
    echo -e "  ${RED}✗${NC} Cannot access group"
    echo -e "  ${YELLOW}Error:${NC} $GROUP_INFO"
    exit 1
fi

echo -e "  ${GREEN}✓${NC} Group exists: $GROUP_NAME"

MEMBERS=$(aws identitystore list-group-memberships \
    --identity-store-id "$IDENTITY_STORE_ID" \
    --group-id "$GROUP_ID" \
    --region "$AWS_REGION" 2>&1)

if [ "$JQ_AVAILABLE" = true ]; then
    MEMBER_COUNT=$(echo "$MEMBERS" | jq '.GroupMemberships | length' 2>/dev/null || echo "0")
else
    MEMBER_COUNT=$(echo "$MEMBERS" | grep -c "MemberId" || echo "0")
fi

echo -e "  ${GREEN}✓${NC} Current members: $MEMBER_COUNT"

if [ "$MEMBER_COUNT" -eq 0 ]; then
    echo -e "  ${YELLOW}⚠${NC} Group is EMPTY"
else
    echo -e "  ${GREEN}✓${NC} Group has members"
    if [ "$JQ_AVAILABLE" = true ]; then
        echo ""
        echo "Current members:"
        echo "$MEMBERS" | jq -r '.GroupMemberships[] | "  - " + .MemberId.UserId'
    fi
fi

echo ""

# List available users
echo -e "${CYAN}[4/8] Listing Available Users...${NC}"

USERS=$(aws identitystore list-users \
    --identity-store-id "$IDENTITY_STORE_ID" \
    --region "$AWS_REGION" 2>&1)

if [ "$JQ_AVAILABLE" = true ]; then
    USER_COUNT=$(echo "$USERS" | jq '.Users | length' 2>/dev/null || echo "0")
    echo -e "  ${GREEN}✓${NC} Found $USER_COUNT users in Identity Center"
    echo ""
    echo "Sample users (first 10):"
    echo "$USERS" | jq -r '.Users[0:10][] | "  - " + .UserName + " (ID: " + .UserId + ")"' 2>/dev/null || echo "  (Unable to parse users)"
else
    echo -e "  ${GREEN}✓${NC} Users retrieved (install jq to see details)"
fi

echo ""

# Check SCIM endpoint
echo -e "${CYAN}[5/8] Testing SCIM Endpoint...${NC}"

SCIM_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X GET "${SCIM_ENDPOINT}/Groups" \
    -H "Authorization: Bearer ${SCIM_TOKEN}" \
    -H "Content-Type: application/scim+json" 2>&1)

HTTP_CODE=$(echo "$SCIM_RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "  ${GREEN}✓${NC} SCIM endpoint accessible (HTTP 200)"
    if [ "$JQ_AVAILABLE" = true ]; then
        SCIM_DATA=$(echo "$SCIM_RESPONSE" | sed '/HTTP_CODE:/d')
        GROUP_COUNT=$(echo "$SCIM_DATA" | jq '.Resources | length' 2>/dev/null || echo "?")
        echo -e "  ${GREEN}✓${NC} Total groups in SCIM: $GROUP_COUNT"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} SCIM endpoint returned HTTP $HTTP_CODE"
fi

echo ""

# Check CloudTrail for recent SCIM activity
echo -e "${CYAN}[6/8] Checking Recent SCIM Activity...${NC}"

RECENT_EVENTS=$(aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=EventSource,AttributeValue=identitystore.amazonaws.com \
    --max-results 5 \
    --region "$AWS_REGION" \
    --output json 2>&1)

if [ "$JQ_AVAILABLE" = true ]; then
    EVENT_COUNT=$(echo "$RECENT_EVENTS" | jq '.Events | length' 2>/dev/null || echo "0")
    if [ "$EVENT_COUNT" -gt 0 ]; then
        LAST_EVENT=$(echo "$RECENT_EVENTS" | jq -r '.Events[0].EventTime' 2>/dev/null)
        echo -e "  ${GREEN}✓${NC} Found $EVENT_COUNT recent SCIM events"
        echo -e "  ${GREEN}✓${NC} Last activity: $LAST_EVENT"
    else
        echo -e "  ${YELLOW}⚠${NC} No recent SCIM events found"
    fi
else
    echo -e "  ${GREEN}✓${NC} CloudTrail queried (install jq to see details)"
fi

echo ""

# Decision point
echo -e "${CYAN}[7/8] Action Options...${NC}"
echo ""
echo "You have the following options:"
echo ""
echo -e "${GREEN}1)${NC} Add a user directly to the group (bypasses SailPoint/Okta)"
echo -e "${GREEN}2)${NC} Search for a specific user by email"
echo -e "${GREEN}3)${NC} List all current group members"
echo -e "${GREEN}4)${NC} Remove a user from the group"
echo -e "${GREEN}5)${NC} Export current state to file"
echo -e "${GREEN}6)${NC} Exit (no changes)"
echo ""
read -p "Select option (1-6): " OPTION

case $OPTION in
    1)
        echo ""
        echo -e "${YELLOW}⚠️  WARNING: Adding users directly bypasses SailPoint governance${NC}"
        echo -e "${YELLOW}   You should add the user to the Okta group afterward${NC}"
        echo ""
        read -p "Enter user email: " USER_EMAIL

        echo ""
        echo "Finding user..."
        USER_DATA=$(aws identitystore list-users \
            --identity-store-id "$IDENTITY_STORE_ID" \
            --region "$AWS_REGION" \
            --filters AttributePath=UserName,AttributeValue="$USER_EMAIL" 2>&1)

        if [ "$JQ_AVAILABLE" = true ]; then
            USER_ID=$(echo "$USER_DATA" | jq -r '.Users[0].UserId' 2>/dev/null)
            if [ "$USER_ID" = "null" ] || [ -z "$USER_ID" ]; then
                echo -e "${RED}✗${NC} User not found: $USER_EMAIL"
                exit 1
            fi
        else
            echo -e "${RED}✗${NC} jq required for this operation"
            exit 1
        fi

        echo -e "${GREEN}✓${NC} Found user: $USER_EMAIL"
        echo -e "${GREEN}✓${NC} User ID: $USER_ID"
        echo ""

        read -p "Enter business justification: " JUSTIFICATION
        read -p "Approved by (manager name): " APPROVER
        echo ""

        echo -e "${YELLOW}Ready to add user to group. This action:${NC}"
        echo "  - Grants immediate access to database-sandbox AWS account"
        echo "  - Bypasses SailPoint approval workflow"
        echo "  - May be overridden by next SCIM sync from Okta"
        echo ""
        read -p "Proceed? (yes/NO): " CONFIRM

        if [ "$CONFIRM" != "yes" ]; then
            echo "Aborted."
            exit 0
        fi

        echo ""
        echo "Adding user to group..."

        MEMBERSHIP_RESULT=$(aws identitystore create-group-membership \
            --identity-store-id "$IDENTITY_STORE_ID" \
            --group-id "$GROUP_ID" \
            --member-id UserId="$USER_ID" \
            --region "$AWS_REGION" 2>&1)

        if [ $? -eq 0 ]; then
            if [ "$JQ_AVAILABLE" = true ]; then
                MEMBERSHIP_ID=$(echo "$MEMBERSHIP_RESULT" | jq -r '.MembershipId' 2>/dev/null)
            else
                MEMBERSHIP_ID="(jq not available)"
            fi

            echo -e "${GREEN}✓ SUCCESS!${NC} User added to group"
            echo ""
            echo "═══════════════════════════════════════════════════════════"
            echo "EMERGENCY ACCESS GRANTED - DOCUMENTATION REQUIRED"
            echo "═══════════════════════════════════════════════════════════"
            echo "Date: $(date)"
            echo "User: $USER_EMAIL"
            echo "User ID: $USER_ID"
            echo "Group: $GROUP_NAME"
            echo "Membership ID: $MEMBERSHIP_ID"
            echo "Justification: $JUSTIFICATION"
            echo "Approved By: $APPROVER"
            echo "Granted By: $IDENTITY"
            echo ""
            echo "⚠️  CRITICAL FOLLOW-UP ACTIONS REQUIRED:"
            echo "1. Add user to Okta group: $GROUP_NAME"
            echo "2. Create SailPoint access request (retroactive)"
            echo "3. Document in change management system"
            echo "4. If temporary: Remove by [specify date]"
            echo ""
            echo "User can now access account at:"
            echo "https://d-9a6763d7d3.awsapps.com/start"
            echo "═══════════════════════════════════════════════════════════"
        else
            echo -e "${RED}✗${NC} Failed to add user"
            echo "$MEMBERSHIP_RESULT"
            exit 1
        fi
        ;;

    2)
        echo ""
        read -p "Enter email to search: " SEARCH_EMAIL

        echo ""
        echo "Searching for user..."
        USER_SEARCH=$(aws identitystore list-users \
            --identity-store-id "$IDENTITY_STORE_ID" \
            --region "$AWS_REGION" \
            --filters AttributePath=UserName,AttributeValue="$SEARCH_EMAIL" 2>&1)

        if [ "$JQ_AVAILABLE" = true ]; then
            echo "$USER_SEARCH" | jq '.'
        else
            echo "$USER_SEARCH"
        fi
        ;;

    3)
        echo ""
        echo "Current group members:"
        aws identitystore list-group-memberships \
            --identity-store-id "$IDENTITY_STORE_ID" \
            --group-id "$GROUP_ID" \
            --region "$AWS_REGION" \
            --output table
        ;;

    4)
        echo ""
        echo "Current members:"
        CURRENT_MEMBERS=$(aws identitystore list-group-memberships \
            --identity-store-id "$IDENTITY_STORE_ID" \
            --group-id "$GROUP_ID" \
            --region "$AWS_REGION" 2>&1)

        if [ "$JQ_AVAILABLE" = true ]; then
            echo "$CURRENT_MEMBERS" | jq -r '.GroupMemberships[] | "  - " + .MemberId.UserId + " (Membership ID: " + .MembershipId + ")"'
            echo ""
            read -p "Enter Membership ID to remove: " MEMBERSHIP_ID

            echo ""
            echo -e "${YELLOW}⚠️  WARNING: Removing user from group${NC}"
            read -p "Confirm removal? (yes/NO): " CONFIRM

            if [ "$CONFIRM" = "yes" ]; then
                aws identitystore delete-group-membership \
                    --identity-store-id "$IDENTITY_STORE_ID" \
                    --membership-id "$MEMBERSHIP_ID" \
                    --region "$AWS_REGION"

                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✓${NC} User removed from group"
                else
                    echo -e "${RED}✗${NC} Failed to remove user"
                fi
            else
                echo "Aborted."
            fi
        else
            echo "$CURRENT_MEMBERS"
            echo ""
            echo "Install jq for interactive removal"
        fi
        ;;

    5)
        OUTPUT_FILE="aws_group_state_$(date +%Y%m%d_%H%M%S).json"
        echo ""
        echo "Exporting current state to $OUTPUT_FILE..."

        {
            echo "{"
            echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
            echo "  \"group\": {"
            echo "    \"id\": \"$GROUP_ID\","
            echo "    \"name\": \"$GROUP_NAME\","
            echo "    \"identityStoreId\": \"$IDENTITY_STORE_ID\""
            echo "  },"
            echo "  \"members\": "
            aws identitystore list-group-memberships \
                --identity-store-id "$IDENTITY_STORE_ID" \
                --group-id "$GROUP_ID" \
                --region "$AWS_REGION" \
                --output json | jq '.GroupMemberships'
            echo "}"
        } > "$OUTPUT_FILE"

        echo -e "${GREEN}✓${NC} State exported to $OUTPUT_FILE"
        ;;

    6)
        echo ""
        echo "Exiting without changes."
        exit 0
        ;;

    *)
        echo ""
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${CYAN}[8/8] Complete${NC}"
echo ""

exit 0
