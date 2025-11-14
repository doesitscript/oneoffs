#!/bin/bash
# SCIM Pipeline Investigation Starter Script
# Purpose: Help you investigate why the AWS group is empty and test manual sync
# Author: Research Team
# Date: November 14, 2025

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IDENTITY_STORE_ID="d-9a6763d7d3"
GROUP_ID="711bf5c0-b071-70c1-06da-35d7fbcac52d"
GROUP_NAME="App-AWS-AA-database-sandbox-941677815499-admin"
AWS_REGION="us-east-2"
SCIM_ENDPOINT="https://scim.us-east-2.amazonaws.com/Hw554936506-e755-4811-8646-adb52f76906a/scim/v2"
SCIM_TOKEN="78f3b96c-ba48-44ca-88da-1e7b2ac73e7b"

# Output file
OUTPUT_FILE="investigation_results_$(date +%Y%m%d_%H%M%S).txt"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   AWS IAM Identity Center - SCIM Investigation Tool   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Target Group: ${YELLOW}${GROUP_NAME}${NC}"
echo -e "Output File: ${YELLOW}${OUTPUT_FILE}${NC}"
echo ""

# Create output file
cat > "$OUTPUT_FILE" << EOF
SCIM Pipeline Investigation Report
Generated: $(date)
Group: ${GROUP_NAME}
Group ID: ${GROUP_ID}
Identity Store: ${IDENTITY_STORE_ID}

═══════════════════════════════════════════════════════════════

EOF

# Function to log both to console and file
log() {
    echo -e "$1" | tee -a "$OUTPUT_FILE"
}

log_file_only() {
    echo "$1" >> "$OUTPUT_FILE"
}

# Check prerequisites
echo -e "${BLUE}[1/7] Checking Prerequisites...${NC}"
log "1. PREREQUISITES CHECK"
log "────────────────────────────────────────────────────────────"

# Check AWS CLI
if command -v aws &> /dev/null; then
    log_file_only "✅ AWS CLI installed: $(aws --version)"
    echo -e "  ${GREEN}✓${NC} AWS CLI found"
else
    log "❌ AWS CLI not found - install it first!"
    echo -e "  ${RED}✗${NC} AWS CLI not found"
    exit 1
fi

# Check jq
if command -v jq &> /dev/null; then
    log_file_only "✅ jq installed: $(jq --version)"
    echo -e "  ${GREEN}✓${NC} jq found"
else
    log "⚠️  jq not found - JSON output will be raw"
    echo -e "  ${YELLOW}⚠${NC} jq not found (optional)"
fi

# Check curl
if command -v curl &> /dev/null; then
    log_file_only "✅ curl installed"
    echo -e "  ${GREEN}✓${NC} curl found"
else
    log "❌ curl not found - needed for API calls"
    echo -e "  ${RED}✗${NC} curl not found"
    exit 1
fi

log ""
echo ""

# Check AWS credentials
echo -e "${BLUE}[2/7] Checking AWS Credentials...${NC}"
log "2. AWS CREDENTIALS CHECK"
log "────────────────────────────────────────────────────────────"

if aws sts get-caller-identity --region "$AWS_REGION" &> /dev/null; then
    ACCOUNT=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
    USER=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null)
    log_file_only "✅ AWS Credentials valid"
    log_file_only "   Account: $ACCOUNT"
    log_file_only "   Identity: $USER"
    echo -e "  ${GREEN}✓${NC} AWS credentials valid (Account: $ACCOUNT)"
else
    log "❌ AWS credentials not configured or invalid"
    echo -e "  ${RED}✗${NC} AWS credentials invalid"
    exit 1
fi

log ""
echo ""

# Check current group state
echo -e "${BLUE}[3/7] Checking AWS Group State...${NC}"
log "3. AWS GROUP CURRENT STATE"
log "────────────────────────────────────────────────────────────"

# Get group details
if GROUP_INFO=$(aws identitystore describe-group \
    --identity-store-id "$IDENTITY_STORE_ID" \
    --group-id "$GROUP_ID" \
    --region "$AWS_REGION" 2>&1); then

    log_file_only "$GROUP_INFO"
    echo -e "  ${GREEN}✓${NC} Group exists in AWS IAM Identity Center"

    # Get member count
    if MEMBERS=$(aws identitystore list-group-memberships \
        --identity-store-id "$IDENTITY_STORE_ID" \
        --group-id "$GROUP_ID" \
        --region "$AWS_REGION" 2>&1); then

        MEMBER_COUNT=$(echo "$MEMBERS" | jq '.GroupMemberships | length' 2>/dev/null || echo "0")
        log_file_only ""
        log_file_only "Group Memberships:"
        log_file_only "$MEMBERS"
        log ""
        log "Current Member Count: ${MEMBER_COUNT}"

        if [ "$MEMBER_COUNT" -eq 0 ]; then
            echo -e "  ${YELLOW}⚠${NC} Group is EMPTY (0 members)"
            log "Status: ⚠️  GROUP IS EMPTY"
        else
            echo -e "  ${GREEN}✓${NC} Group has $MEMBER_COUNT members"
            log "Status: ✅ Group has members"
        fi
    else
        log "❌ Could not list group memberships"
        log_file_only "$MEMBERS"
        echo -e "  ${RED}✗${NC} Error listing memberships"
    fi
else
    log "❌ Group not found or no access"
    log_file_only "$GROUP_INFO"
    echo -e "  ${RED}✗${NC} Cannot access group"
    exit 1
fi

log ""
echo ""

# Check SCIM activity
echo -e "${BLUE}[4/7] Checking Recent SCIM Activity...${NC}"
log "4. RECENT SCIM EVENTS (CloudTrail)"
log "────────────────────────────────────────────────────────────"

if SCIM_EVENTS=$(aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=EventSource,AttributeValue=identitystore.amazonaws.com \
    --max-results 10 \
    --region "$AWS_REGION" \
    --output json 2>&1); then

    EVENT_COUNT=$(echo "$SCIM_EVENTS" | jq '.Events | length' 2>/dev/null || echo "0")
    log "Recent events found: $EVENT_COUNT"
    log_file_only ""
    log_file_only "$SCIM_EVENTS"

    if [ "$EVENT_COUNT" -gt 0 ]; then
        echo -e "  ${GREEN}✓${NC} Found $EVENT_COUNT recent SCIM events"

        # Show last event time
        if command -v jq &> /dev/null; then
            LAST_EVENT=$(echo "$SCIM_EVENTS" | jq -r '.Events[0].EventTime' 2>/dev/null)
            log "Last SCIM event: $LAST_EVENT"
            echo -e "  ${GREEN}✓${NC} Last activity: $LAST_EVENT"
        fi
    else
        echo -e "  ${YELLOW}⚠${NC} No recent SCIM events (might indicate sync issues)"
        log "⚠️  No recent SCIM events found"
    fi
else
    log "❌ Could not query CloudTrail"
    log_file_only "$SCIM_EVENTS"
    echo -e "  ${RED}✗${NC} CloudTrail query failed"
fi

log ""
echo ""

# Test SCIM endpoint
echo -e "${BLUE}[5/7] Testing SCIM Endpoint...${NC}"
log "5. SCIM ENDPOINT CONNECTIVITY TEST"
log "────────────────────────────────────────────────────────────"

if SCIM_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X GET "${SCIM_ENDPOINT}/Groups" \
    -H "Authorization: Bearer ${SCIM_TOKEN}" \
    -H "Content-Type: application/scim+json" 2>&1); then

    HTTP_CODE=$(echo "$SCIM_RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
    SCIM_DATA=$(echo "$SCIM_RESPONSE" | sed '/HTTP_CODE:/d')

    log_file_only "SCIM Endpoint: ${SCIM_ENDPOINT}/Groups"
    log_file_only "HTTP Response Code: $HTTP_CODE"
    log_file_only ""
    log_file_only "$SCIM_DATA"

    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "  ${GREEN}✓${NC} SCIM endpoint responding (HTTP 200)"
        log "SCIM Status: ✅ Endpoint healthy"

        if command -v jq &> /dev/null; then
            GROUP_COUNT=$(echo "$SCIM_DATA" | jq '.Resources | length' 2>/dev/null || echo "?")
            echo -e "  ${GREEN}✓${NC} Total groups in SCIM: $GROUP_COUNT"
            log "Total groups visible via SCIM: $GROUP_COUNT"
        fi
    elif [ "$HTTP_CODE" = "401" ]; then
        echo -e "  ${RED}✗${NC} SCIM authentication failed (token may be expired)"
        log "SCIM Status: ❌ Authentication failed (401)"
    else
        echo -e "  ${YELLOW}⚠${NC} SCIM returned HTTP $HTTP_CODE"
        log "SCIM Status: ⚠️  HTTP $HTTP_CODE"
    fi
else
    log "❌ Could not connect to SCIM endpoint"
    log_file_only "$SCIM_RESPONSE"
    echo -e "  ${RED}✗${NC} SCIM connection failed"
fi

log ""
echo ""

# Check for API tokens
echo -e "${BLUE}[6/7] Checking API Access Options...${NC}"
log "6. API ACCESS CAPABILITIES"
log "────────────────────────────────────────────────────────────"

echo -e "  ${YELLOW}ℹ${NC} To enable full investigation, set these environment variables:"
echo ""
echo -e "  ${YELLOW}Okta API:${NC}"
echo "    export OKTA_DOMAIN=\"breadfinancial.okta.com\""
echo "    export OKTA_API_TOKEN=\"<your_token>\""
echo ""
echo -e "  ${YELLOW}SailPoint API:${NC}"
echo "    export SAILPOINT_TENANT=\"breadfinancial\""
echo "    export SAILPOINT_CLIENT_ID=\"<your_client_id>\""
echo "    export SAILPOINT_CLIENT_SECRET=\"<your_secret>\""
echo ""

# Check if Okta vars are set
if [ -n "$OKTA_API_TOKEN" ] && [ -n "$OKTA_DOMAIN" ]; then
    log "Okta API: ✅ Environment variables set"
    echo -e "  ${GREEN}✓${NC} Okta API configured"

    # Try to test it
    if OKTA_TEST=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X GET "https://${OKTA_DOMAIN}/api/v1/users/me" \
        -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
        -H "Accept: application/json" 2>&1); then

        OKTA_HTTP=$(echo "$OKTA_TEST" | grep "HTTP_CODE:" | cut -d: -f2)
        if [ "$OKTA_HTTP" = "200" ]; then
            echo -e "  ${GREEN}✓${NC} Okta API access confirmed"
            log "Okta API Status: ✅ Authenticated successfully"
        else
            echo -e "  ${RED}✗${NC} Okta API authentication failed (HTTP $OKTA_HTTP)"
            log "Okta API Status: ❌ Failed (HTTP $OKTA_HTTP)"
        fi
    fi
else
    log "Okta API: ⚠️  Not configured (limited investigation)"
    echo -e "  ${YELLOW}⚠${NC} Okta API not configured"
fi

# Check if SailPoint vars are set
if [ -n "$SAILPOINT_CLIENT_ID" ] && [ -n "$SAILPOINT_TENANT" ]; then
    log "SailPoint API: ✅ Environment variables set"
    echo -e "  ${GREEN}✓${NC} SailPoint API configured"
else
    log "SailPoint API: ⚠️  Not configured (limited investigation)"
    echo -e "  ${YELLOW}⚠${NC} SailPoint API not configured"
fi

log ""
echo ""

# Summary and recommendations
echo -e "${BLUE}[7/7] Summary & Recommendations${NC}"
log "7. SUMMARY & NEXT STEPS"
log "────────────────────────────────────────────────────────────"

log ""
log "FINDINGS:"

if [ "$MEMBER_COUNT" -eq 0 ]; then
    log "- AWS group is EMPTY (needs population)"
    log "- SCIM endpoint is accessible"
    log "- Waiting for Okta to push members via SCIM"
    log ""
    log "LIKELY CAUSES:"
    log "1. No users assigned in Okta group"
    log "2. SailPoint hasn't provisioned anyone yet"
    log "3. Okta group push not configured/enabled"
    log "4. SCIM sync is not triggering"
    log ""
    log "NEXT STEPS:"
    log ""
    log "Option A: If you have Okta API access"
    log "  1. Find the Okta group: ${GROUP_NAME}"
    log "  2. Check if any users are in the Okta group"
    log "  3. Manually trigger group push to AWS"
    log "  4. Run: curl -X POST \"https://\${OKTA_DOMAIN}/api/v1/apps/\${AWS_APP_ID}/groups/\${OKTA_GROUP_ID}\""
    log ""
    log "Option B: If you have SailPoint access"
    log "  1. Create Access Profile for this AWS group"
    log "  2. Assign users to the Access Profile"
    log "  3. SailPoint will provision to Okta"
    log "  4. Okta will SCIM sync to AWS"
    log ""
    log "Option C: Contact administrators"
    log "  - SailPoint team: to create access profiles"
    log "  - Okta team: to verify SCIM configuration"
    log ""
else
    log "✅ Group has members - sync appears to be working"
    log ""
    log "VERIFICATION:"
    log "- Check if you have expected access to account 941677815499"
    log "- Navigate to: https://d-9a6763d7d3.awsapps.com/start"
    log "- Verify 'database-sandbox' appears in your account list"
fi

log ""
log "═══════════════════════════════════════════════════════════════"
log "Full details saved to: ${OUTPUT_FILE}"
log "Review the file for complete API responses and troubleshooting data."

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Investigation Complete!                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "📄 Full report: ${YELLOW}${OUTPUT_FILE}${NC}"
echo ""
echo -e "📚 For detailed API commands and manual sync procedures, see:"
echo -e "   ${BLUE}research/HANDS_ON_INVESTIGATION.md${NC}"
echo ""

if [ "$MEMBER_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Group is currently empty. Manual intervention may be needed.${NC}"
    echo ""
    echo -e "To trigger a manual sync (if you have Okta API access):"
    echo -e "  ${BLUE}./trigger_okta_sync.sh${NC}"
    echo ""
fi

exit 0
