# Hands-On Investigation Guide: Triggering Group Sync & Provisioning

**Date:** November 14, 2025  
**Purpose:** Research what SailPoint/Okta admins actually DO and which commands/APIs you can try  
**Approach:** Non-destructive investigation → Safe read commands → Manual trigger methods

---

## 🎯 Goal

Find out how to manually trigger the sync pipeline:
```
SailPoint → Okta → SCIM → AWS IAM Identity Center
```

---

## 🔍 Part 1: Safe Investigation Commands (Read-Only)

These are 100% safe - they just read current state.

### A. AWS IAM Identity Center - Current State

```bash
# 1. List all groups (see what exists)
aws identitystore list-groups \
  --identity-store-id d-9a6763d7d3 \
  --region us-east-2

# 2. Get specific group details
aws identitystore describe-group \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2

# 3. List current members (should be empty)
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2

# 4. List all users in Identity Center
aws identitystore list-users \
  --identity-store-id d-9a6763d7d3 \
  --region us-east-2

# 5. Search for specific user by email
aws identitystore list-users \
  --identity-store-id d-9a6763d7d3 \
  --filters AttributePath=UserName,AttributeValue=josh.castillo@breadfinancial.com \
  --region us-east-2

# 6. Check SCIM sync configuration
aws sso-admin describe-instance \
  --instance-arn arn:aws:sso:::instance/ssoins-6684b61b096c0add \
  --region us-east-2
```

**What to look for:**
- Current group membership count
- User IDs available in the identity store
- SCIM configuration status

---

### B. AWS CloudTrail - SCIM Activity Logs

```bash
# 1. Check recent SCIM events (last 24 hours)
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateUser \
  --max-results 50 \
  --region us-east-2

# 2. Check group membership changes
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
  --max-results 50 \
  --region us-east-2

# 3. Check for SCIM errors
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=identitystore.amazonaws.com \
  --max-results 50 \
  --region us-east-2 \
  --query 'Events[?contains(CloudTrailEvent, `errorCode`)]'

# 4. Export detailed events to file for analysis
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=identitystore.amazonaws.com \
  --max-results 50 \
  --region us-east-2 \
  --output json > scim_events.json
```

**What to look for:**
- When was the last SCIM sync?
- Are there any error codes?
- Which service principal is making the calls? (should be Okta)

---

### C. Okta API - Current Configuration (Read-Only)

First, you need an Okta API token. Get one from:
1. Okta Admin Console → Security → API → Tokens → Create Token

```bash
# Set your Okta domain and API token
export OKTA_DOMAIN="breadfinancial.okta.com"  # or your specific domain
export OKTA_API_TOKEN="your_api_token_here"

# 1. Find the AWS IAM Identity Center app
curl -X GET "https://${OKTA_DOMAIN}/api/v1/apps?q=AWS%20IAM%20Identity%20Center" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Accept: application/json" | jq '.'

# Save the app ID from the response
export AWS_APP_ID="<app_id_from_response>"

# 2. Check app provisioning configuration
curl -X GET "https://${OKTA_DOMAIN}/api/v1/apps/${AWS_APP_ID}" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Accept: application/json" | jq '.features'

# 3. Get provisioning connection details
curl -X GET "https://${OKTA_DOMAIN}/api/v1/apps/${AWS_APP_ID}/connections" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Accept: application/json" | jq '.'

# 4. Find the specific group in Okta
curl -X GET "https://${OKTA_DOMAIN}/api/v1/groups?q=App-AWS-AA-database-sandbox" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Accept: application/json" | jq '.'

# Save the group ID
export OKTA_GROUP_ID="<group_id_from_response>"

# 5. List current members of the Okta group
curl -X GET "https://${OKTA_DOMAIN}/api/v1/groups/${OKTA_GROUP_ID}/users" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Accept: application/json" | jq '.'

# 6. Check if group is assigned to AWS app
curl -X GET "https://${OKTA_DOMAIN}/api/v1/apps/${AWS_APP_ID}/groups" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Accept: application/json" | jq '.'

# 7. Check group push mappings
curl -X GET "https://${OKTA_DOMAIN}/api/v1/apps/${AWS_APP_ID}/groups/${OKTA_GROUP_ID}" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Accept: application/json" | jq '.'
```

**What to look for:**
- Is the group assigned to the AWS app?
- What's the push status?
- Are there any sync errors?

---

### D. SailPoint IdentityNow API - Investigation

You'll need SailPoint API credentials:
1. SailPoint Admin Console → Admin → API Management → Personal Access Tokens

```bash
# Set your SailPoint tenant and credentials
export SAILPOINT_TENANT="breadfinancial"  # Your tenant name
export SAILPOINT_CLIENT_ID="your_client_id"
export SAILPOINT_CLIENT_SECRET="your_client_secret"

# 1. Get OAuth token
SAILPOINT_TOKEN=$(curl -X POST "https://${SAILPOINT_TENANT}.api.identitynow.com/oauth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "client_id=${SAILPOINT_CLIENT_ID}" \
  -d "client_secret=${SAILPOINT_CLIENT_SECRET}" | jq -r '.access_token')

# 2. List all sources (should see Okta)
curl -X GET "https://${SAILPOINT_TENANT}.api.identitynow.com/v3/sources" \
  -H "Authorization: Bearer ${SAILPOINT_TOKEN}" \
  -H "Accept: application/json" | jq '.[] | select(.name | contains("Okta"))'

# Save Okta source ID
export OKTA_SOURCE_ID="<source_id_from_response>"

# 3. List access profiles (look for AWS-related ones)
curl -X GET "https://${SAILPOINT_TENANT}.api.identitynow.com/v3/access-profiles" \
  -H "Authorization: Bearer ${SAILPOINT_TOKEN}" \
  -H "Accept: application/json" | jq '.[] | select(.name | contains("AWS"))'

# 4. List entitlements for Okta source
curl -X GET "https://${SAILPOINT_TENANT}.api.identitynow.com/v3/entitlements?filters=source.id eq \"${OKTA_SOURCE_ID}\"" \
  -H "Authorization: Bearer ${SAILPOINT_TOKEN}" \
  -H "Accept: application/json" | jq '.'

# 5. Search for the specific AWS group entitlement
curl -X GET "https://${SAILPOINT_TENANT}.api.identitynow.com/v3/entitlements?filters=name co \"database-sandbox-941677815499-admin\"" \
  -H "Authorization: Bearer ${SAILPOINT_TOKEN}" \
  -H "Accept: application/json" | jq '.'

# 6. Check provisioning status for Okta source
curl -X GET "https://${SAILPOINT_TENANT}.api.identitynow.com/v3/sources/${OKTA_SOURCE_ID}/provisioning-policies" \
  -H "Authorization: Bearer ${SAILPOINT_TOKEN}" \
  -H "Accept: application/json" | jq '.'
```

**What to look for:**
- Does an access profile exist for this AWS group?
- Is the Okta group mapped as an entitlement?
- What's the provisioning policy?

---

## 🔧 Part 2: Manual Trigger Commands (Non-Destructive Test)

### A. Okta: Manually Trigger SCIM Sync

**Method 1: Via Okta API (Push Group)**

```bash
# This tells Okta to immediately sync a group to AWS via SCIM
curl -X POST "https://${OKTA_DOMAIN}/api/v1/apps/${AWS_APP_ID}/groups/${OKTA_GROUP_ID}" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "priority": 0
  }'

# Check the push status
curl -X GET "https://${OKTA_DOMAIN}/api/v1/apps/${AWS_APP_ID}/groups/${OKTA_GROUP_ID}" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Accept: application/json" | jq '.lastMembershipUpdated, .status'
```

**Method 2: Via Okta Admin Console (Manual)**

1. Okta Admin Console → Applications → AWS IAM Identity Center
2. Navigate to "Push Groups" tab
3. Find the group: `App-AWS-AA-database-sandbox-941677815499-admin`
4. Click "Push Now" or the circular sync icon
5. Monitor status

**Method 3: Direct SCIM API Call (Advanced)**

```bash
# Get the SCIM endpoint from AWS (you already have it)
SCIM_ENDPOINT="https://scim.us-east-2.amazonaws.com/Hw554936506-e755-4811-8646-adb52f76906a/scim/v2"
SCIM_TOKEN="78f3b96c-ba48-44ca-88da-1e7b2ac73e7b"

# List groups via SCIM (read-only check)
curl -X GET "${SCIM_ENDPOINT}/Groups" \
  -H "Authorization: Bearer ${SCIM_TOKEN}" \
  -H "Content-Type: application/scim+json" | jq '.'

# Get specific group details via SCIM
curl -X GET "${SCIM_ENDPOINT}/Groups?filter=displayName eq \"App-AWS-AA-database-sandbox-941677815499-admin\"" \
  -H "Authorization: Bearer ${SCIM_TOKEN}" \
  -H "Content-Type: application/scim+json" | jq '.'

# List users via SCIM
curl -X GET "${SCIM_ENDPOINT}/Users" \
  -H "Authorization: Bearer ${SCIM_TOKEN}" \
  -H "Content-Type: application/scim+json" | jq '.'
```

⚠️ **WARNING:** Don't use PATCH/POST/DELETE on SCIM endpoints - let Okta manage this!

---

### B. SailPoint: Manually Trigger Provisioning

**Method 1: Trigger Account Aggregation (Refresh from Okta)**

```bash
# This tells SailPoint to re-read all accounts from Okta
curl -X POST "https://${SAILPOINT_TENANT}.api.identitynow.com/cc/api/source/loadAccounts/${OKTA_SOURCE_ID}" \
  -H "Authorization: Bearer ${SAILPOINT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "disableOptimization": false
  }'

# Check aggregation status
curl -X GET "https://${SAILPOINT_TENANT}.api.identitynow.com/v3/sources/${OKTA_SOURCE_ID}/load-accounts/status" \
  -H "Authorization: Bearer ${SAILPOINT_TOKEN}" \
  -H "Accept: application/json" | jq '.'
```

**Method 2: Trigger Entitlement Aggregation**

```bash
# Refresh entitlements (groups) from Okta
curl -X POST "https://${SAILPOINT_TENANT}.api.identitynow.com/cc/api/source/loadEntitlements/${OKTA_SOURCE_ID}" \
  -H "Authorization: Bearer ${SAILPOINT_TOKEN}" \
  -H "Content-Type: application/json"
```

**Method 3: Manual Provisioning for a Specific User**

```bash
# First, find a user
curl -X GET "https://${SAILPOINT_TENANT}.api.identitynow.com/v3/search?query=josh.castillo" \
  -H "Authorization: Bearer ${SAILPOINT_TOKEN}" \
  -H "Accept: application/json" | jq '.'

# Save identity ID
export IDENTITY_ID="<identity_id_from_response>"

# Create an access request (like the user would do)
curl -X POST "https://${SAILPOINT_TENANT}.api.identitynow.com/v3/access-requests" \
  -H "Authorization: Bearer ${SAILPOINT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "requestedFor": "'${IDENTITY_ID}'",
    "requestType": "GRANT_ACCESS",
    "requestedItems": [
      {
        "type": "ACCESS_PROFILE",
        "id": "<access_profile_id>",
        "comment": "Testing sync pipeline"
      }
    ]
  }'
```

**Method 4: Check Provisioning Status**

```bash
# Check recent provisioning events
curl -X GET "https://${SAILPOINT_TENANT}.api.identitynow.com/v3/account-activities?type=provisioning" \
  -H "Authorization: Bearer ${SAILPOINT_TOKEN}" \
  -H "Accept: application/json" | jq '.'

# Check specific user's accounts
curl -X GET "https://${SAILPOINT_TENANT}.api.identitynow.com/v3/accounts?filters=identityId eq \"${IDENTITY_ID}\"" \
  -H "Authorization: Bearer ${SAILPOINT_TOKEN}" \
  -H "Accept: application/json" | jq '.'
```

---

### C. Test the Full Pipeline

**Test Case: Add yourself to the group (if you're in Okta admin)**

```bash
# 1. Get your user ID in Okta
curl -X GET "https://${OKTA_DOMAIN}/api/v1/users/me" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Accept: application/json" | jq '.id'

export MY_OKTA_USER_ID="<your_user_id>"

# 2. Add yourself to the Okta group
curl -X PUT "https://${OKTA_DOMAIN}/api/v1/groups/${OKTA_GROUP_ID}/users/${MY_OKTA_USER_ID}" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Accept: application/json"

# 3. Trigger immediate sync to AWS
curl -X POST "https://${OKTA_DOMAIN}/api/v1/apps/${AWS_APP_ID}/groups/${OKTA_GROUP_ID}" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Content-Type: application/json"

# 4. Wait 2-5 minutes, then check AWS
sleep 300

# 5. Verify in AWS IAM Identity Center
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2

# 6. Remove yourself if this was just a test
curl -X DELETE "https://${OKTA_DOMAIN}/api/v1/groups/${OKTA_GROUP_ID}/users/${MY_OKTA_USER_ID}" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}"
```

---

## 🔬 Part 3: Diagnostic Scripts

### Script 1: Full Pipeline Health Check

```bash
#!/bin/bash
# save as: check_scim_pipeline.sh

echo "=== SCIM Pipeline Health Check ==="
echo ""

# AWS Side
echo "1. Checking AWS IAM Identity Center..."
aws identitystore describe-group \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2 \
  --query 'DisplayName' \
  --output text

MEMBER_COUNT=$(aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2 \
  --query 'length(GroupMemberships)' \
  --output text)

echo "   Current members: ${MEMBER_COUNT}"
echo ""

# Okta Side
echo "2. Checking Okta group..."
OKTA_MEMBERS=$(curl -s -X GET "https://${OKTA_DOMAIN}/api/v1/groups/${OKTA_GROUP_ID}/users" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Accept: application/json" | jq '. | length')

echo "   Okta group members: ${OKTA_MEMBERS}"
echo ""

# Compare
echo "3. Sync Status:"
if [ "$MEMBER_COUNT" -eq "$OKTA_MEMBERS" ]; then
  echo "   ✅ Synced! AWS and Okta match."
else
  echo "   ⚠️  Out of sync! AWS has ${MEMBER_COUNT}, Okta has ${OKTA_MEMBERS}"
  echo "   → Try triggering a manual sync"
fi
echo ""

# Recent SCIM activity
echo "4. Recent SCIM events (last 24 hours):"
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=identitystore.amazonaws.com \
  --max-results 5 \
  --region us-east-2 \
  --query 'Events[*].[EventTime,EventName]' \
  --output table
```

### Script 2: Find What SailPoint Knows

```bash
#!/bin/bash
# save as: sailpoint_group_search.sh

echo "=== SailPoint Group Discovery ==="

# Search for AWS-related entitlements
curl -s -X GET "https://${SAILPOINT_TENANT}.api.identitynow.com/v3/entitlements?filters=name co \"database-sandbox\"" \
  -H "Authorization: Bearer ${SAILPOINT_TOKEN}" \
  -H "Accept: application/json" | jq -r '.[] | "ID: \(.id)\nName: \(.name)\nSource: \(.source.name)\nType: \(.type)\n---"'

echo ""
echo "=== Access Profiles Using This Group ==="

curl -s -X GET "https://${SAILPOINT_TENANT}.api.identitynow.com/v3/access-profiles?filters=name co \"database\"" \
  -H "Authorization: Bearer ${SAILPOINT_TOKEN}" \
  -H "Accept: application/json" | jq -r '.[] | "Name: \(.name)\nID: \(.id)\nOwner: \(.owner.name)\n---"'
```

### Script 3: Monitor Sync in Real-Time

```bash
#!/bin/bash
# save as: watch_scim_sync.sh

echo "Monitoring SCIM sync... Press Ctrl+C to stop"
echo ""

while true; do
  clear
  echo "=== SCIM Sync Monitor - $(date) ==="
  echo ""
  
  # Check AWS
  echo "AWS Group Members:"
  aws identitystore list-group-memberships \
    --identity-store-id d-9a6763d7d3 \
    --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
    --region us-east-2 \
    --query 'GroupMemberships[*].MemberId.UserId' \
    --output table
  
  echo ""
  echo "Recent CloudTrail Events:"
  aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=EventSource,AttributeValue=identitystore.amazonaws.com \
    --max-results 3 \
    --region us-east-2 \
    --query 'Events[*].[EventTime,EventName,Username]' \
    --output table
  
  sleep 30
done
```

---

## 📊 Part 4: What SailPoint Admins Actually Do

Based on SailPoint IdentityNow, here's what admins typically do:

### Daily Operations:

1. **Create Access Profile**
   - UI: Admin → Access Profiles → Create
   - API: `POST /v3/access-profiles`
   - Connects Okta group entitlements to requestable access

2. **Assign Access to User**
   - UI: Manage Users → User → Access → Add Access
   - API: `POST /v3/access-requests`
   - Triggers provisioning workflow

3. **Trigger Account Aggregation**
   - UI: Admin → Sources → Okta → Aggregate Now
   - API: `POST /cc/api/source/loadAccounts/{sourceId}`
   - Refreshes SailPoint's view of Okta

4. **Monitor Provisioning**
   - UI: Admin → Activity → Account Activity
   - API: `GET /v3/account-activities`
   - See what's being provisioned

5. **Check Entitlements**
   - UI: Admin → Sources → Okta → Entitlements
   - API: `GET /v3/entitlements?filters=source.id eq "{sourceId}"`
   - See all Okta groups SailPoint knows about

---

## 🎯 Part 5: Your Action Plan

### Step 1: Gather Information (10 minutes)

```bash
# Save this as: investigate.sh
#!/bin/bash

echo "Gathering environment information..."

# Get API tokens first (manual step - document where to get them)
echo "Before running, ensure you have:"
echo "1. OKTA_API_TOKEN"
echo "2. SAILPOINT_TOKEN"
echo ""

# Check AWS state
echo "=== AWS Current State ===" > investigation_report.txt
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2 >> investigation_report.txt

# Check if you have Okta access
echo "=== Testing Okta API Access ===" >> investigation_report.txt
curl -s -X GET "https://${OKTA_DOMAIN}/api/v1/users/me" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Accept: application/json" | jq '.' >> investigation_report.txt

# Check if you have SailPoint access
echo "=== Testing SailPoint API Access ===" >> investigation_report.txt
curl -s -X GET "https://${SAILPOINT_TENANT}.api.identitynow.com/v3/sources" \
  -H "Authorization: Bearer ${SAILPOINT_TOKEN}" \
  -H "Accept: application/json" | jq '.[0]' >> investigation_report.txt

echo "Report saved to: investigation_report.txt"
```

### Step 2: Try Manual Sync (5 minutes)

```bash
# If you have Okta API access, try this:
curl -X POST "https://${OKTA_DOMAIN}/api/v1/apps/${AWS_APP_ID}/groups/${OKTA_GROUP_ID}" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Content-Type: application/json"

# Wait 5 minutes
sleep 300

# Check if it worked
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2
```

### Step 3: Document Findings

Create a file: `findings.md`

```markdown
# Investigation Findings - [Date]

## Access Level Confirmed:
- [ ] AWS CLI access: YES/NO
- [ ] Okta API access: YES/NO
- [ ] SailPoint API access: YES/NO

## Current State:
- AWS group members: X
- Okta group members: Y
- In sync: YES/NO

## What I Can Trigger:
- [ ] Okta SCIM push
- [ ] SailPoint aggregation
- [ ] Direct user add (not recommended)

## Blockers Found:
- [List any errors or missing configs]

## Next Steps:
- [What you'll try next]
```

---

## 🚀 Quick Start Commands

```bash
# 1. Set up environment variables
export OKTA_DOMAIN="breadfinancial.okta.com"
export OKTA_API_TOKEN="<get_from_okta_admin_console>"
export SAILPOINT_TENANT="breadfinancial"
export SAILPOINT_TOKEN="<get_from_sailpoint>"
export AWS_APP_ID="<find_via_okta_api>"
export OKTA_GROUP_ID="<find_via_okta_api>"

# 2. Quick health check
./check_scim_pipeline.sh

# 3. If out of sync, try manual trigger
curl -X POST "https://${OKTA_DOMAIN}/api/v1/apps/${AWS_APP_ID}/groups/${OKTA_GROUP_ID}" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Content-Type: application/json"

# 4. Monitor results
./watch_scim_sync.sh
```

---

## 📚 API Documentation References

### Okta APIs:
- Groups API: `https://developer.okta.com/docs/reference/api/groups/`
- Apps API: `https://developer.okta.com/docs/reference/api/apps/`
- SCIM Provisioning: `https://developer.okta.com/docs/reference/scim/`

### SailPoint APIs:
- IdentityNow v3 API: `https://{tenant}.api.identitynow.com/v3/docs/`
- Access Profiles: `/v3/access-profiles`
- Entitlements: `/v3/entitlements`
- Account Activities: `/v3/account-activities`

### AWS APIs:
- Identity Store: `https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html`
- CloudTrail: `https://docs.aws.amazon.com/cli/latest/reference/cloudtrail/`

---

**Bottom Line:**  
You CAN investigate and potentially trigger syncs if you have the right API access. Start with read-only commands to understand the current state, then try manual sync triggers if needed. The key is having Okta API tokens and/or SailPoint API credentials.