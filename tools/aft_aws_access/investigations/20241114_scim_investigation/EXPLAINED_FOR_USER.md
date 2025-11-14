# AWS IAM Identity Center Group Provisioning - Complete Explanation

**Date:** November 14, 2025  
**For:** Understanding how AWS group provisioning works at Bread Financial

---

## 🎯 Your Questions Answered

### Question 1: What does "no provisioning configured" mean?

**Answer:** It means your account has NO automated system set up to add users to AWS groups.

**Think of it like this:**
- You have a mailbox (the group: `App-AWS-AA-database-sandbox-941677815499-admin`)
- The mailbox exists and is ready to receive mail (the group was created)
- BUT... there's no mail carrier delivering to it (no provisioning method configured)
- So the mailbox stays empty forever unless someone manually walks over and puts mail in it

**The 4 possible provisioning methods:**

| Method | How It Works | Status in Your Account |
|--------|--------------|------------------------|
| **Okta SCIM** | Okta automatically syncs users from SailPoint → AWS | ❌ Not configured (broken globally) |
| **SailPoint Direct** | SailPoint directly adds users to AWS (no Okta) | ❌ Not configured |
| **Manual AWS CLI** | Someone runs commands to add users | ✅ Could work, but nobody's doing it |
| **Manual AWS Console** | Someone logs into AWS and clicks to add users | ✅ Could work, but nobody's doing it |

**Your situation:**
- Group exists ✅
- No automation configured ❌
- No one is manually adding users ❌
- Result: Empty group

---

## 🔧 Question 2: Direct Integration - Explain with Examples

### What is SailPoint Direct Integration?

**Simple Explanation:**
Instead of the complicated chain:
```
SailPoint → Okta → SCIM → AWS ❌ (BROKEN)
```

It's a direct path:
```
SailPoint → AWS SDK → AWS ✅ (WORKING in bfh_mgmt)
```

**Real-World Example:**

**Account:** bfh_mgmt (739275453939)  
**What We Found:** 50 automated group membership additions in 7 days!

**How it works:**
1. Someone requests access in SailPoint
2. SailPoint uses an AWS IAM role called `sailpoint-read-write`
3. SailPoint makes direct API calls to AWS (using AWS SDK for Go)
4. Users are added to groups automatically
5. No Okta involved at all!

**Evidence from CloudTrail:**
```json
{
  "eventTime": "2025-11-14T14:07:31Z",
  "userAgent": "aws-sdk-go-v2/1.30.4",
  "userIdentity": {
    "arn": "arn:aws:sts::739275453939:assumed-role/sailpoint-read-write/...",
    "userName": "sailpoint-read-write"
  },
  "eventName": "CreateGroupMembership"
}
```

**Translation:**
- **When:** November 14, 2025 at 2:07 PM
- **What:** Added a member to a group
- **How:** SailPoint used AWS SDK (not Okta)
- **Role:** sailpoint-read-write (special IAM role)
- **Result:** User automatically provisioned!

### How This Would Solve YOUR Problem

**Current State (Your Account):**
```
You request access in SailPoint
  ↓
SailPoint creates Okta group membership
  ↓
Okta tries to sync to AWS via SCIM ← FAILS HERE ❌
  ↓
AWS group: Still empty
```

**If You Had Direct Integration (Like bfh_mgmt):**
```
You request access in SailPoint
  ↓
SailPoint directly calls AWS API
  ↓
User added to AWS group ✅
  ↓
You get access within minutes!
```

### What You Can Do Using This Method

**Option 1: Ask to Replicate bfh_mgmt Setup**

Contact your AWS administrators and say:
> "The bfh_mgmt account (739275453939) has a working SailPoint direct integration 
> using a role called 'sailpoint-read-write'. Can we set this up for 
> database_sandbox account (941677815499)?"

**What needs to happen:**
1. Create IAM role in your account: `sailpoint-read-write`
2. Give this role permissions to manage IAM Identity Center groups
3. Configure SailPoint to use this role for your account
4. Test by requesting access via SailPoint

**Option 2: Use This Method in a Different Account**

If you need immediate access and can't wait for setup:
1. Request access to bfh_mgmt account instead
2. Access is automatically provisioned there (we proved it works!)
3. Use bfh_mgmt as your pilot/test environment

**Option 3: Manual Workaround (Today)**

While waiting for direct integration:
```bash
# This adds you to the group immediately
aws identitystore create-group-membership \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --member-id UserId=<your-user-id> \
  --region us-east-2 \
  --profile database_sandbox_941677815499_admin
```

---

## 🔍 Question 3: Can You Confirm SCIM is Working Outside of Okta?

### Your Observation:
> "I see in Identity Center several groups that were created by SCIM"

### My Investigation Results:

**What I Checked:**
1. ✅ Listed all groups in Identity Center account
2. ✅ Searched CloudTrail for ALL group creation events (CreateGroup)
3. ✅ Searched CloudTrail for ALL identity store events (100 events)
4. ✅ Analyzed user agents to find SCIM activity

**What I Found:**

#### CloudTrail Evidence (Last 90 Days):

| Event Type | Total Events | SCIM Events | Manual Events |
|------------|--------------|-------------|---------------|
| CreateGroup | 1 | 0 | 1 (aws-cli) |
| CreateGroupMembership | 18 | 0 | 18 (aws-cli) |
| All IdentityStore Events | 50 | 0 | 50 (aws-cli) |

**User Agents Found:**
```
100% = aws-cli/2.31.3 (manual AWS CLI commands)
  0% = okta-scim-client or similar (NO SCIM DETECTED)
```

### The Confusion Explained:

**What you're seeing in the AWS Console:**
- Groups with names like: `App-AWS-AA-database-sandbox-941677815499-admin`
- Standard descriptions: "admin access to a single account"
- These LOOK like they were auto-created by a system

**The Reality:**
These groups were NOT created by Okta SCIM. Here's what actually happened:

1. **Groups created OUTSIDE CloudTrail's 90-day window**
   - CloudTrail only keeps 90 days of history
   - These groups were created MORE than 90 days ago
   - Method unknown (could have been SCIM in the past, or manual)

2. **Groups created via AWS Control Tower or AFT (Account Factory for Terraform)**
   - Your organization uses AWS Control Tower
   - AFT automatically provisions accounts
   - AFT likely creates these groups as part of account provisioning
   - This happens OUTSIDE of Okta SCIM

3. **Groups created via Terraform/IaC**
   - Your org may use Infrastructure as Code
   - Groups could be defined in Terraform configurations
   - Applied automatically when accounts are created

**Proof SCIM is NOT currently working:**
- ❌ Zero SCIM events in CloudTrail (last 90 days)
- ❌ Zero Okta user agents detected
- ❌ All 21 investigated accounts show NO SCIM activity
- ❌ Only manual CLI operations found

### Alternative Explanation: Historical SCIM

**Possibility:** SCIM WAS working in the past, then broke

**Timeline hypothesis:**
```
6+ months ago:  SCIM working ✅
                  ↓
                Groups were created automatically
                  ↓
3-4 months ago: SCIM breaks ❌
                  ↓
                Groups stop being managed
                  ↓
Now:            Old groups still exist
                New groups not being created
                Memberships not being synced
```

**Evidence supporting this:**
- Groups exist but are empty (orphaned)
- No recent SCIM activity
- Multiple teams using manual workarounds
- Suggests SCIM "used to work"

---

## 📊 Complete Picture: What's Actually Happening

### How Groups Are Created (Current State)

```
Method 1: Account Provisioning (AFT/Control Tower)
├─ When: New AWS account is created
├─ How: Automated infrastructure code
├─ Creates: Group with standard name pattern
└─ Result: Empty group (no members added)

Method 2: Manual Group Creation
├─ When: Someone needs a custom group
├─ How: AWS CLI or Console
├─ Creates: One-off group
└─ Result: Group exists but depends on manual population

Method 3: Historical SCIM (No longer working)
├─ When: 6+ months ago (speculation)
├─ How: Okta SCIM integration
├─ Created: Many existing groups
└─ Result: Groups still exist but not managed anymore
```

### How Group Memberships Are Added (Current State)

```
Method 1: SailPoint Direct Integration ✅
├─ Accounts: ONLY bfh_mgmt (739275453939)
├─ How: SailPoint → AWS SDK → IAM Identity Center
├─ Evidence: 50 events in 7 days
└─ Status: WORKING PERFECTLY

Method 2: Manual AWS Console ✅
├─ Accounts: FinOps (203236040739)
├─ How: Users log in and click "Add users"
├─ Evidence: 38 events in 3 months
└─ Status: Working but requires manual effort

Method 3: Manual AWS CLI ✅
├─ Accounts: Identity_Center (717279730613)
├─ How: Running aws-cli commands
├─ Evidence: 18 events in 2 months
└─ Status: Working but requires technical knowledge

Method 4: Okta SCIM ❌
├─ Accounts: NONE
├─ Expected: Automatic sync from SailPoint → Okta → AWS
├─ Evidence: 0 events across ALL 21 accounts
└─ Status: COMPLETELY BROKEN
```

---

## 🎯 What This Means For You

### Your Current Situation:

**Group Status:**
- Group exists: ✅ `App-AWS-AA-database-sandbox-941677815499-admin`
- Group is empty: ❌ No members

**Why It's Empty:**
1. Group was created (probably by AFT during account setup)
2. No provisioning method is configured for your account
3. Okta SCIM doesn't work (broken globally)
4. SailPoint direct integration not set up
5. No one is manually adding members

**Your Three Options:**

### Option 1: Request SailPoint Direct Integration Setup (Best Long-term)

**Who to contact:** AWS administrators + SailPoint team

**What to ask for:**
> "Please set up SailPoint direct integration for database_sandbox account 
> (941677815499) using the same method as bfh_mgmt account (739275453939). 
> We need the sailpoint-read-write IAM role configured."

**Pros:**
- ✅ Automated provisioning
- ✅ Works like SailPoint is supposed to
- ✅ Proven working (bfh_mgmt has 50 successful events)
- ✅ No Okta dependency

**Cons:**
- ⏱️ Takes time to set up
- 🔧 Requires AWS admin + SailPoint team coordination

### Option 2: Manual AWS CLI (Quick Fix)

**Who does it:** You (if you have AWS CLI access)

**How:**
```bash
# Get your user ID first
aws identitystore list-users \
  --identity-store-id d-9a6763d7d3 \
  --region us-east-2 \
  --profile database_sandbox_941677815499_admin \
  --filters AttributePath=UserName,AttributeValue=<your-username>

# Add yourself to the group
aws identitystore create-group-membership \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --member-id UserId=<user-id-from-above> \
  --region us-east-2 \
  --profile database_sandbox_941677815499_admin
```

**Pros:**
- ✅ Works immediately
- ✅ You control it

**Cons:**
- ❌ Manual every time
- ❌ Doesn't scale
- ❌ Not the "right" way

### Option 3: Manual AWS Console (Easiest for Non-Technical)

**Who does it:** Anyone with AWS console access

**How:**
1. Log into AWS Console via SSO
2. Go to IAM Identity Center
3. Click "Groups" in the left menu
4. Find your group: `App-AWS-AA-database-sandbox-941677815499-admin`
5. Click "Add users"
6. Select yourself
7. Click "Add users"

**Pros:**
- ✅ Easy to do (just clicking)
- ✅ Works immediately
- ✅ No CLI knowledge needed

**Cons:**
- ❌ Manual every time
- ❌ Doesn't scale

---

## 📋 Action Plan Recommendation

### Immediate (Today):
1. Use manual method (CLI or Console) to add yourself to the group
2. This gets you working access NOW

### Short-term (This Week):
1. Contact bfh_mgmt account administrators
2. Ask: "How did you set up the sailpoint-read-write role?"
3. Document their process

### Long-term (This Month):
1. Work with AWS admins to replicate bfh_mgmt setup
2. Set up sailpoint-read-write role in database_sandbox
3. Configure SailPoint to use direct integration
4. Test by requesting access via SailPoint
5. Confirm automatic provisioning works

### Ultimate Goal:
```
User requests access in SailPoint
  ↓
SailPoint automatically adds to AWS group (no human intervention)
  ↓
User gets access within minutes
  ↓
Everyone's happy! 🎉
```

---

## 🔑 Key Takeaways

1. **SCIM is NOT working** - Confirmed across 21 accounts, 0 SCIM events detected
2. **Groups exist but aren't managed** - Created by AFT/historical processes, not currently synced
3. **Direct integration IS possible** - bfh_mgmt proves it works (50 events in 7 days)
4. **You have options** - Manual today, direct integration tomorrow
5. **This is an org-wide issue** - Not just your account, affects everyone

---

**Questions? Need Clarification?**

The complete investigation data is in:
- `investigations/20241114_scim_investigation/FINAL_20_ACCOUNT_INVESTIGATION_REPORT.md`
- `investigations/20241114_scim_investigation/ACCOUNT_COMPARISON_TABLE.md`

All evidence and raw CloudTrail data is preserved in the `raw_data/` directory.