# Instructions for Checking AWS IAM Identity Center Group Membership

## 🎯 Task Overview
Check if the AWS IAM Identity Center group `App-AWS-AA-database-sandbox-941677815499-admin` has received any new members since the investigation on November 14, 2025.

---

## 📋 Required Information

### AWS Account Details:
- **Account Name:** database_sandbox
- **Account ID:** 941677815499
- **AWS Profile:** `database_sandbox_941677815499_admin`
- **Region:** `us-east-2`

### IAM Identity Center Details:
- **Identity Store ID:** `d-9a6763d7d3`
- **Group ID:** `711bf5c0-b071-70c1-06da-35d7fbcac52d`
- **Group Display Name:** `App-AWS-AA-database-sandbox-941677815499-admin`

---

## ✅ Step-by-Step Instructions

### Step 1: Verify AWS Access
First, confirm you can access the account:

```bash
aws sts get-caller-identity \
  --profile database_sandbox_941677815499_admin
```

**Expected Output:**
```json
{
    "UserId": "...",
    "Account": "941677815499",
    "Arn": "..."
}
```

---

### Step 2: Check Current Group Members

```bash
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2 \
  --profile database_sandbox_941677815499_admin
```

**What to Look For:**
- If output shows `"GroupMemberships": []` → Group is still empty
- If output shows members → Group has been populated!

**Save the output to a file:**
```bash
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2 \
  --profile database_sandbox_941677815499_admin \
  > current_group_members_$(date +%Y%m%d_%H%M%S).json
```

---

### Step 3: Get Member Details (If Group Has Members)

If Step 2 shows members, get their details:

```bash
# For each member ID found, run:
aws identitystore describe-user \
  --identity-store-id d-9a6763d7d3 \
  --user-id <USER_ID_FROM_STEP_2> \
  --region us-east-2 \
  --profile database_sandbox_941677815499_admin
```

---

### Step 4: Check CloudTrail for Recent Activity

Look for any new CreateGroupMembership events since November 14, 2025:

```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
  --start-time "2025-11-14T00:00:00Z" \
  --max-results 50 \
  --region us-east-2 \
  --profile database_sandbox_941677815499_admin \
  > cloudtrail_recent_events_$(date +%Y%m%d_%H%M%S).json
```

**Analyze the events:**
```bash
# Check if any events exist
jq '.Events | length' cloudtrail_recent_events_*.json

# If events exist, check the user agents to determine provisioning method
jq -r '.Events[].CloudTrailEvent | fromjson | .userAgent' cloudtrail_recent_events_*.json | sort | uniq -c
```

**Possible User Agents:**
- `aws-cli/2.x.x` → Manual AWS CLI operation
- `AWS Internal` → Manual AWS Console operation
- `aws-sdk-go-v2/1.30.4` → SailPoint direct integration (like bfh_mgmt)
- `okta-scim-client` → Okta SCIM sync (unlikely, was broken)

---

### Step 5: Compare with Other Accounts (Optional)

Check if provisioning is working in other accounts:

**Check bfh_mgmt (known working SailPoint integration):**
```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
  --start-time "2025-11-14T00:00:00Z" \
  --max-results 20 \
  --region us-east-2 \
  --profile bfh_mgmt_739275453939_admin
```

**Check FinOps (known working Console operations):**
```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
  --start-time "2025-11-14T00:00:00Z" \
  --max-results 20 \
  --region us-east-2 \
  --profile FinOps_203236040739_admin
```

---

## 📊 Report Your Findings

### If Group is Still Empty:
```
Status: ❌ STILL EMPTY
- No members in group
- No CloudTrail events since Nov 14, 2025
- Recommendation: Use manual AWS CLI method OR contact bfh_mgmt team
```

### If Group Has Members (Manual Method):
```
Status: ✅ POPULATED (Manual)
- Member count: [X]
- Method detected: [AWS CLI / AWS Console]
- User agent: [specific user agent]
- Users who added members: [list principal IDs]
- Date of last addition: [timestamp]
```

### If Group Has Members (Automated Method):
```
Status: ✅ POPULATED (Automated)
- Member count: [X]
- Method detected: [SailPoint Direct / Okta SCIM]
- User agent: [specific user agent]
- Role used: [IAM role name if applicable]
- Frequency: [how many events in last 7 days]
- THIS IS SIGNIFICANT: Report if automated provisioning is now working!
```

---

## 🔍 Additional Investigation (If Automated Provisioning Detected)

If you find evidence of automated provisioning (SailPoint or Okta SCIM), investigate further:

### Check for sailpoint-read-write role:
```bash
aws iam get-role \
  --role-name sailpoint-read-write \
  --profile database_sandbox_941677815499_admin
```

### Check for SCIM configuration:
```bash
aws sso-admin list-instances \
  --region us-east-2 \
  --profile database_sandbox_941677815499_admin
```

### Look for all Identity Store events:
```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=identitystore.amazonaws.com \
  --start-time "2025-11-14T00:00:00Z" \
  --max-results 100 \
  --region us-east-2 \
  --profile database_sandbox_941677815499_admin
```

---

## 🚨 What to Report

### Critical Information:
1. **Group Status:** Empty or Populated?
2. **Member Count:** How many members?
3. **Provisioning Method:** Manual CLI, Console, SailPoint Direct, or Okta SCIM?
4. **User Agent:** What user agent is shown in CloudTrail?
5. **Timestamp:** When were members added?
6. **Who Added Them:** User IDs or role names from CloudTrail

### Comparison with Previous Investigation (Nov 14, 2025):
- **Previous Status:** Empty (0 members)
- **Previous CloudTrail Events:** 0
- **Current Status:** [Your findings]
- **Change Detected:** Yes/No

---

## 📁 Files to Generate

Save all outputs with timestamps:
```
group_status_check_YYYYMMDD_HHMMSS/
├── current_members.json              (Step 2 output)
├── member_details.json               (Step 3 output)
├── recent_cloudtrail_events.json     (Step 4 output)
├── user_agents_summary.txt           (Analysis of user agents)
└── STATUS_REPORT.md                  (Your findings summary)
```

---

## 🎯 Quick Check Command (One-Liner)

For a quick status check, run:
```bash
echo "=== Group Members ===" && \
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2 \
  --profile database_sandbox_941677815499_admin | jq '.GroupMemberships | length' && \
echo "=== Recent Events ===" && \
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
  --start-time "2025-11-14T00:00:00Z" \
  --max-results 10 \
  --region us-east-2 \
  --profile database_sandbox_941677815499_admin | jq '.Events | length'
```

**Interpretation:**
- First number = current member count
- Second number = new CloudTrail events since Nov 14

If both are 0 → Nothing has changed  
If first is >0 → Group has members!  
If second is >0 → New activity detected

---

## 📞 If You Need Help

Previous investigation files are located at:
- `FINAL_20_ACCOUNT_INVESTIGATION_REPORT.md`
- `ACCOUNT_COMPARISON_TABLE.md`
- `QUICK_REFERENCE.md`
- `scim_investigation_20251114_134819/`

Key contacts if automated provisioning is detected:
- **bfh_mgmt account team** (they have working SailPoint direct integration)
- **SailPoint team** (for direct integration questions)
- **Okta team** (if SCIM sync is now working)

---

**Investigation Date:** November 14, 2025  
**Last Known Status:** Group was empty, no provisioning method configured  
**Expected Status:** Likely still empty unless manual method was used or bfh_mgmt integration was replicated

---

## ⚡ Quick Start

Just want to check if anything changed? Run this:

```bash
cd /Users/a805120/develop/aws-access

# Check current members
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2 \
  --profile database_sandbox_941677815499_admin

# If empty, report: "No change - group is still empty"
# If has members, continue with detailed investigation above
```

Good luck! 🚀