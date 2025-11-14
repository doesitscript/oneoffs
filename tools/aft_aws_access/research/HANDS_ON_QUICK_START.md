# Hands-On Quick Start Guide

**Goal:** Investigate and potentially trigger the sync to populate the empty AWS group  
**Target Group:** `App-AWS-AA-database-sandbox-941677815499-admin`  
**Current Status:** 0 members  
**Time Required:** 15-30 minutes

---

## 🚀 TL;DR - Three Commands to Get Started

```bash
# 1. Run the investigation script (safe, read-only)
./investigate_sync.sh

# 2. If you have Okta API access, set up credentials
export OKTA_DOMAIN="breadfinancial.okta.com"
export OKTA_API_TOKEN="your_token_here"

# 3. Trigger manual sync
./trigger_okta_sync.sh
```

---

## 📋 What You'll Need

### Required (Already Have):
- ✅ AWS CLI configured
- ✅ Access to AWS account 717279730613
- ✅ Ability to run bash scripts

### Optional (For Manual Triggering):
- 🔑 Okta API token (get from Okta Admin Console)
- 🔑 SailPoint API credentials (if you want SailPoint control)

---

## 🎯 Quick Decision Tree

```
Can you access Okta Admin Console?
├─ YES → Get API token → Use trigger_okta_sync.sh
│         (15 minutes, works if you're Okta admin)
│
└─ NO  → Can you access SailPoint admin?
           ├─ YES → Use SailPoint API approach
           │         (See HANDS_ON_INVESTIGATION.md)
           │
           └─ NO  → Contact admins
                     (Provide them the investigation results)
```

---

## 🔍 Step 1: Investigate Current State (5 minutes)

### Run the Investigation Script

```bash
chmod +x investigate_sync.sh
./investigate_sync.sh
```

**What it does (100% safe, read-only):**
- ✅ Checks AWS group current state
- ✅ Lists CloudTrail SCIM events
- ✅ Tests SCIM endpoint connectivity
- ✅ Verifies your access levels
- ✅ Generates detailed report

**Output:**
- Console summary of findings
- Detailed report file: `investigation_results_[timestamp].txt`

**What to look for:**
```
Current Member Count: 0          ← Confirms group is empty
SCIM Status: ✅ Endpoint healthy  ← SCIM is working
Last SCIM event: [date]          ← When last sync happened
```

---

## 🔧 Step 2: Get API Access (10 minutes)

### Option A: Okta API Token

**If you have Okta Admin access:**

1. **Log into Okta Admin Console**
   - URL: https://breadfinancial.okta.com/admin (or your Okta domain)

2. **Navigate to API Tokens**
   - Security → API → Tokens
   - Click "Create Token"
   - Name: "SCIM Investigation"
   - Copy the token (you only see it once!)

3. **Set Environment Variables**
   ```bash
   export OKTA_DOMAIN="breadfinancial.okta.com"
   export OKTA_API_TOKEN="00abcd...xyz"
   ```

4. **Test Access**
   ```bash
   curl -X GET "https://${OKTA_DOMAIN}/api/v1/users/me" \
     -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
     -H "Accept: application/json" | jq '.'
   ```

   **Success:** You'll see your user profile  
   **Failure:** Check token and domain

### Option B: SailPoint API Credentials

**If you have SailPoint Admin access:**

1. **Log into SailPoint Identity Security Cloud**
   - Find it in your Okta apps or direct URL

2. **Create Personal Access Token**
   - Admin → API Management → Personal Access Tokens
   - Create New Token
   - Save Client ID and Secret

3. **Set Environment Variables**
   ```bash
   export SAILPOINT_TENANT="breadfinancial"
   export SAILPOINT_CLIENT_ID="your_client_id"
   export SAILPOINT_CLIENT_SECRET="your_secret"
   ```

---

## ⚡ Step 3: Trigger Manual Sync (5-10 minutes)

### Using Okta (Fastest Method)

```bash
chmod +x trigger_okta_sync.sh
./trigger_okta_sync.sh
```

**What it does:**
1. Finds the AWS IAM Identity Center app in Okta
2. Finds the target group in Okta
3. Checks current member count
4. Triggers immediate SCIM sync to AWS
5. Waits and verifies the sync completed

**Expected Output:**
```
[1/6] Checking Prerequisites...
  ✓ Okta domain: breadfinancial.okta.com
  ✓ API token configured

[2/6] Testing Okta API Access...
  ✓ Authenticated as: josh.castillo@breadfinancial.com

[3/6] Finding AWS IAM Identity Center App...
  ✓ Found: AWS IAM Identity Center
  ✓ App ID: 0oa...

[4/6] Finding Okta Group...
  ✓ Found: App-AWS-AA-database-sandbox-941677815499-admin
  ✓ Group ID: 00g...
  ✓ Members in Okta: 3

[5/6] Checking AWS State Before Sync...
  ✓ Current AWS group members: 0

[6/6] Triggering SCIM Sync...
Proceed with sync? (y/N): y

  ✓ Sync triggered successfully (HTTP 200)

Waiting for SCIM sync to complete...
Checking... (1/6) - waiting 30 seconds
Checking... (2/6) - waiting 30 seconds

✓ Success! Group membership changed!
  Before: 0 members
  After:  3 members
```

---

## 🔬 Advanced: Manual API Commands

### If Scripts Don't Work, Try These Direct Commands

**1. Check Okta Group Members**
```bash
# Find the group
curl -s -X GET "https://${OKTA_DOMAIN}/api/v1/groups?q=App-AWS-AA-database-sandbox" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" | jq '.[0].id'

export OKTA_GROUP_ID="00g..."  # Use the ID from above

# List members
curl -s -X GET "https://${OKTA_DOMAIN}/api/v1/groups/${OKTA_GROUP_ID}/users" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" | jq '.[] | .profile.email'
```

**2. Find AWS App in Okta**
```bash
curl -s -X GET "https://${OKTA_DOMAIN}/api/v1/apps?q=AWS" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" | jq '.[] | {id, label}'

export AWS_APP_ID="0oa..."  # Use the IAM Identity Center app ID
```

**3. Trigger Sync**
```bash
curl -X PUT "https://${OKTA_DOMAIN}/api/v1/apps/${AWS_APP_ID}/groups/${OKTA_GROUP_ID}" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Content-Type: application/json"
```

**4. Verify in AWS**
```bash
# Wait 2-5 minutes, then check
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2
```

---

## 🎓 What Each Component Does

### SailPoint → Okta → AWS Pipeline

```
┌─────────────────┐
│   SailPoint     │  = Governance (who should have access)
│  (If you have   │    - Access requests
│   admin access) │    - Approval workflows
└────────┬────────┘    - Lifecycle management
         │
         ↓ Provisions users to groups
         │
┌─────────────────┐
│     Okta        │  = Identity Provider + SCIM Client
│  (If you have   │    - Stores groups and users
│   admin access) │    - Syncs to AWS via SCIM
└────────┬────────┘    - You can trigger sync here!
         │
         ↓ SCIM v2.0 sync
         │
┌─────────────────┐
│   AWS IAM       │  = Receives users/groups automatically
│ Identity Center │    - Don't modify directly!
│ (Read-only for  │    - Let SCIM manage it
│  investigation) │    
└─────────────────┘
```

### Where You Can Intervene

| Layer | Your Access? | What You Can Do | Risk Level |
|-------|-------------|-----------------|------------|
| **SailPoint** | Check admin | Create access profiles, assign users | 🟢 Safe (proper governance) |
| **Okta** | Check admin | Add users to group, trigger sync | 🟡 Caution (bypasses governance) |
| **AWS IAM IC** | ✅ Yes | View only - DON'T modify | 🔴 High (breaks SCIM) |

---

## 🐛 Troubleshooting

### Problem: "Okta API authentication failed"

**Solution:**
```bash
# Verify token is correct
echo $OKTA_API_TOKEN

# Test with a simple call
curl -X GET "https://${OKTA_DOMAIN}/api/v1/users/me" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}"
```

### Problem: "Group not found in Okta"

**Solution:**
```bash
# Search for partial name
curl -s -X GET "https://${OKTA_DOMAIN}/api/v1/groups?q=database-sandbox" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" | jq '.[] | .profile.name'

# Group might have slightly different name in Okta
```

### Problem: "Sync triggered but AWS still empty"

**Possible causes:**
1. **Okta group is empty** → Add users to Okta group first
2. **Sync takes longer** → Wait 10-15 minutes
3. **SCIM token expired** → Check token expiry (expires 3/7/2026)
4. **Group push not configured** → Check Okta Push Groups settings

**Check sync status in Okta:**
1. Admin Console → Applications → AWS IAM Identity Center
2. Provisioning → Push Groups
3. Find your group and check status

### Problem: "No Okta or SailPoint access"

**Solution:**
You'll need to contact administrators:

```markdown
To: SailPoint Team / Identity Team
Subject: Request to populate AWS IAM Identity Center group

Hi,

I need access to the database-sandbox AWS account for [business reason].

Details:
- AWS Account: database-sandbox (941677815499)
- Required Access Level: Admin
- AWS Group Name: App-AWS-AA-database-sandbox-941677815499-admin
- My Email: josh.castillo@breadfinancial.com

The group exists in IAM Identity Center but has no members. Could you:
1. Create a SailPoint Access Profile for this AWS group (if not exists)
2. Assign me (and [other users]) to this access profile

Thank you!
```

---

## 📊 Monitoring the Sync

### Real-Time Monitoring Script

```bash
# Watch for changes every 30 seconds
watch -n 30 'aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2 \
  --query "length(GroupMemberships)"'
```

### Check CloudTrail for SCIM Events

```bash
# See recent SCIM activity
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=identitystore.amazonaws.com \
  --max-results 10 \
  --region us-east-2 \
  --query 'Events[*].[EventTime,EventName,Username]' \
  --output table
```

---

## ✅ Success Criteria

### You Know It Worked When:

**1. AWS Group Has Members**
```bash
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2

# Output shows users!
```

**2. You Can Access the Account**
- Navigate to: https://d-9a6763d7d3.awsapps.com/start
- Log in with Okta
- You see "database-sandbox" in your account list
- Click to access with "admin" role

**3. CloudTrail Shows SCIM Events**
```bash
# Recent events should show CreateGroupMembership
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
  --max-results 5 \
  --region us-east-2
```

---

## 📚 Next Steps After Success

### 1. Document What You Did
- Save investigation results
- Note which method worked
- Document any issues encountered

### 2. Create Proper Governance (If You Used Okta Direct)
- Work with SailPoint team to create Access Profile
- Migrate manual assignments to governed process
- Set up approval workflows

### 3. Share Knowledge
- Update team documentation
- Create runbook for future access requests
- Train others on the process

---

## 🔗 Related Documentation

| Document | Purpose |
|----------|---------|
| `HANDS_ON_INVESTIGATION.md` | Deep dive into all APIs and commands |
| `SELF_SERVICE_OPTIONS.md` | Detailed analysis of each approach |
| `QUICK_CHECK_GUIDE.md` | Fast assessment of your capabilities |
| `RESEARCH_SUMMARY.md` | Complete architecture overview |

---

## 📞 Getting Help

### If Scripts Fail:
1. Check the generated `investigation_results_*.txt` file
2. Look for error messages in console output
3. Verify API tokens are valid
4. Check your access levels

### If You're Stuck:
1. Run `./investigate_sync.sh` to gather diagnostics
2. Review the output for specific errors
3. Check the troubleshooting section above
4. Contact administrators with the investigation report

### For Architecture Questions:
- See: `research/identity-center-investigation/README.md`
- See: `RESEARCH_SUMMARY.md`

---

## 🎯 Summary

**What you learned:**
- ✅ How to investigate SCIM sync status
- ✅ How to manually trigger Okta → AWS sync
- ✅ Safe vs unsafe ways to populate groups
- ✅ When to use automation vs contact admins

**Key takeaway:**
You CAN trigger the sync yourself if you have Okta API access. The scripts provided are safe, non-destructive, and follow the existing integration architecture.

**Bottom line:**
```bash
# Investigation: Always safe
./investigate_sync.sh

# Manual sync: Safe if you have Okta admin access
./trigger_okta_sync.sh

# Direct AWS changes: Never do this (breaks SCIM)
```

Good luck! 🚀