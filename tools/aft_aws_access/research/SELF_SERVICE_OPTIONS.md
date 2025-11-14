# Self-Service Options for Populating IAM Identity Center Groups

**Date:** November 14, 2025  
**Target Group:** `App-AWS-AA-database-sandbox-941677815499-admin`  
**Current Status:** Group exists but has 0 members  
**Research Question:** Can you fix this yourself without SailPoint admin help?

---

## 🎯 Executive Summary

**Short Answer:** It depends on your access level in Okta and/or SailPoint.

**Three Potential Paths:**
1. **Okta Admin Access** - Fastest if you have it (15 minutes)
2. **SailPoint Admin Access** - Proper governance method (1-2 hours)
3. **AWS Direct Manipulation** - ⚠️ NOT RECOMMENDED (creates conflicts)

---

## 🔍 What You Need to Check First

### Step 1: Verify Your Okta Access Level

**How to Check:**
1. Log into Okta: https://breadfinancial.okta.com (or your Okta URL)
2. Navigate to **Admin Console** (if you have admin rights, you'll see this option)
3. Check your role:
   - **Super Admin** - Can do everything
   - **Group Administrator** - Can manage specific groups
   - **Application Administrator** - Can manage apps and group assignments
   - **User** - No admin rights

**What to Look For:**
- Can you access **Directory → Groups**?
- Can you search for `App-AWS-AA-database-sandbox-941677815499-admin`?
- Can you click into the group and see a "Manage People" or "Add Users" button?

**If YES** → You can proceed with **Option 1** below ✅  
**If NO** → Check SailPoint access (Step 2)

---

### Step 2: Verify Your SailPoint Access Level

**How to Check:**
1. Log into SailPoint Identity Security Cloud
   - URL should be in your Okta apps as "SailPoint Identity Security Cloud"
   - Or company-specific URL like `https://breadfinancial.identitynow.com`
2. Check for admin navigation options:
   - **Admin** menu in top navigation
   - **Access Profiles** section
   - **Entitlements** management
   - **Provisioning Policies**

**What to Look For:**
- Can you create new **Access Profiles**?
- Can you view/edit **Entitlements**?
- Can you see **Okta** as a connected source?
- Can you manually assign access to users?

**If YES to creating Access Profiles** → You can proceed with **Option 2** below ✅  
**If NO, but can request access** → You can only request for yourself (Step 3)

---

### Step 3: Check Your AWS IAM Identity Center Access

**How to Check:**
1. Log into AWS account `717279730613` (IAM Identity Center management account)
2. Navigate to **IAM Identity Center**
3. Go to **Groups**
4. Search for group ID: `711bf5c0-b071-70c1-06da-35d7fbcac52d`

**What to Look For:**
- Can you see the group members section?
- Is there an "Add users" button enabled?
- Can you actually add users to the group?

**⚠️ WARNING:** Even if you CAN add users here, you SHOULD NOT (see Option 3 risks)

---

## ✅ Option 1: Self-Service via Okta (If You Have Okta Admin Access)

### Prerequisites
✓ Okta Group Administrator or Super Admin role  
✓ Access to Okta Admin Console  
✓ Permissions to manage the specific group

### Steps to Populate the Group

#### A. Find the Okta Group

```bash
# The Okta group name should match the AWS group name
Group Name: App-AWS-AA-database-sandbox-941677815499-admin
```

1. Log into **Okta Admin Console**
2. Navigate to **Directory → Groups**
3. Search for: `App-AWS-AA-database-sandbox-941677815499-admin`
4. Click on the group to open it

#### B. Verify SCIM Configuration

Before adding users, verify the group is synced to AWS:

1. In the group details, look for **Applications** tab
2. Verify **AWS IAM Identity Center** is listed as an assigned application
3. Check that the group has **Push Status: Active** or similar indicator

#### C. Add Users to the Group

1. Click **Manage People** or **Add Users** button
2. Search for the user(s) you want to add
3. Select users and click **Add**
4. Save changes

#### D. Verify SCIM Sync

**Automatic sync usually happens within 5-15 minutes**

Verify in AWS:
```bash
# Using AWS CLI
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2
```

Or in AWS Console:
1. Go to IAM Identity Center (account 717279730613)
2. Navigate to Groups
3. Find the group and check members

### ⚠️ Important Considerations

**Pros:**
- ✅ Fast (15 minutes)
- ✅ Uses existing SCIM integration
- ✅ Changes automatically sync to AWS
- ✅ No AWS configuration needed

**Cons:**
- ⚠️ **Bypasses SailPoint governance** - No approval workflow
- ⚠️ **Audit/Compliance Risk** - Access granted without formal request
- ⚠️ **No Automatic Deprovisioning** - When user leaves, may not be removed
- ⚠️ **SOX/Compliance Issues** - May violate access control policies

**When to Use:**
- Emergency access needed immediately
- You plan to create proper SailPoint profile later
- Your organization allows manual Okta group management
- You document the manual change

**When NOT to Use:**
- Regulated environment (SOX, PCI, HIPAA, etc.)
- Company policy requires SailPoint for all access
- You're in a highly audited department (Finance, Security, etc.)

---

## ✅ Option 2: Proper Self-Service via SailPoint (If You Have SailPoint Admin Access)

### Prerequisites
✓ SailPoint Administrator role or Access Profile management rights  
✓ Access to SailPoint Identity Security Cloud  
✓ Permissions to create Access Profiles and Entitlements

### Steps to Create and Assign Access

#### A. Create an Access Profile (One-Time Setup)

1. **Log into SailPoint**
   - Navigate to SailPoint Identity Security Cloud

2. **Create Access Profile**
   - Go to **Admin → Access Profiles**
   - Click **Create Access Profile** or **New Profile**
   
3. **Configure Profile Details**
   ```
   Profile Name: AWS Database Sandbox - Admin Access
   Description: Administrative access to AWS database-sandbox account (941677815499)
   Source: Okta
   Owner: [Your Name or Team]
   ```

4. **Add Entitlements**
   - Click **Add Entitlements**
   - Source: **Okta**
   - Type: **Group**
   - Search: `App-AWS-AA-database-sandbox-941677815499-admin`
   - Select the group and add it

5. **Configure Access Rules (Optional)**
   ```
   Requestable: Yes
   Auto-grant: [Based on role/department if desired]
   Approval Required: [Yes - recommended]
   Approvers: [Manager and/or Security team]
   ```

6. **Save Access Profile**

#### B. Assign Access to Users

**Option B1: Manual Assignment (Immediate)**
1. Go to **Manage → Users**
2. Search for the user
3. Click on user → **Access** tab
4. Click **Add Access**
5. Search for your new access profile: "AWS Database Sandbox - Admin Access"
6. Add and save

**Option B2: User Self-Service Request**
1. Instruct user to log into SailPoint
2. User goes to **Request Access** or **Access Request Center**
3. User searches for "AWS Database Sandbox"
4. User requests the access profile
5. Approval workflow triggers (if configured)
6. You approve as admin
7. SailPoint provisions to Okta
8. Okta syncs to AWS via SCIM

#### C. Verify Provisioning

**In SailPoint:**
1. Check user's access → Should show the access profile
2. Check provisioning status → Should show "Provisioned" or "Complete"

**In Okta:**
1. Navigate to user in Okta Admin Console
2. Check **Groups** tab
3. Verify `App-AWS-AA-database-sandbox-941677815499-admin` appears

**In AWS:**
```bash
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2
```

### ⏱️ Expected Timeline

- **Access Profile Creation:** 15-30 minutes (one-time)
- **User Assignment:** 5 minutes
- **SailPoint → Okta Provisioning:** 5-15 minutes
- **Okta → AWS SCIM Sync:** 5-15 minutes
- **Total Time:** 30 minutes - 1 hour

### ✅ Benefits of This Approach

**Pros:**
- ✅ **Proper Governance** - Full audit trail
- ✅ **Approval Workflow** - Controlled access
- ✅ **Automatic Lifecycle** - Access removed when user leaves
- ✅ **Compliance Friendly** - Meets audit requirements
- ✅ **Reusable** - Other users can request the same access
- ✅ **Self-Documenting** - Access profile explains what access grants

**Cons:**
- ⏳ Longer setup time (first time only)
- 📋 Requires understanding of SailPoint

**When to Use:**
- ✅ **ALWAYS, if possible** - This is the "right way"
- Especially in regulated environments
- When you need ongoing access for multiple users
- When proper audit trails are required

---

## ⚠️ Option 3: Direct AWS Manipulation (NOT RECOMMENDED)

### Prerequisites
✓ AWS IAM Identity Center admin access in account 717279730613  
✓ Understanding of SCIM conflicts

### How It Would Work

1. **Navigate to IAM Identity Center**
   - Account: 717279730613
   - Service: IAM Identity Center
   - Section: Groups

2. **Find the Group**
   - Group ID: `711bf5c0-b071-70c1-06da-35d7fbcac52d`
   - Name: `App-AWS-AA-database-sandbox-941677815499-admin`

3. **Add Users Manually**
   - Click "Add users to group"
   - Search for user
   - Add user

### 🛑 Why You Should NOT Do This

**Critical Issues:**

1. **SCIM Conflict**
   ```
   Manual Change in AWS ← vs → Automated SCIM from Okta
   = Sync conflicts and errors
   ```

2. **Okta Override Risk**
   - Okta SCIM sync might remove manually added users
   - Or SCIM sync might fail and stop working entirely

3. **Broken Audit Trail**
   - No record in SailPoint of who approved access
   - Compliance nightmare during audits
   - SOX violations possible

4. **Deprovisioning Failure**
   - When user leaves company, won't be auto-removed
   - Security risk: ex-employees retain access

5. **Group Drift**
   - AWS groups become "source of truth" instead of Okta
   - Future SCIM syncs may fail
   - Hard to troubleshoot later

**The Only Time This Might Be Acceptable:**
- 🚨 Emergency access needed in production incident
- AND you document the emergency change
- AND you create proper SailPoint request afterward
- AND you have approval from Security team

---

## 📋 Decision Matrix: Which Option Should You Use?

| Scenario | Recommended Option | Why |
|----------|-------------------|-----|
| **You have SailPoint admin access** | **Option 2** | Proper governance, audit trail, sustainable |
| **You have Okta admin + Non-regulated env** | **Option 1** | Fast, but document it and create SailPoint profile later |
| **You have Okta admin + Regulated env** | **Option 2** | Must use proper governance |
| **Emergency production incident** | **Option 1 or 3** | Speed matters, but document and remediate |
| **You have only AWS access** | **❌ Don't do it yourself** | Contact SailPoint admins |
| **You're not sure of your access** | **Start with checks above** | Determine what you can actually do |

---

## 🔧 Troubleshooting: If SCIM Sync Doesn't Work

### Check 1: SCIM Token Validity

```bash
# In AWS IAM Identity Center
# Navigate to: Settings → Identity Source → Automatic Provisioning

Expected:
- Status: Enabled
- Token: Active (not expired)
- Expiry: 3/7/2026
```

If token is expired or about to expire:
1. Generate new token in AWS
2. Update token in Okta SCIM configuration
3. Test sync

### Check 2: Okta SCIM Configuration

1. **In Okta Admin Console:**
   - Applications → AWS IAM Identity Center
   - Provisioning tab
   - Integration settings

2. **Verify:**
   ```
   ✓ Provisioning to App: Enabled
   ✓ Create Users: Enabled
   ✓ Update User Attributes: Enabled
   ✓ Deactivate Users: Enabled
   ✓ Sync Password: [Based on your config]
   ```

3. **Check Group Push:**
   - Push Groups tab
   - Find your group
   - Status should be "Active" not "Error"

### Check 3: Manual SCIM Sync Trigger

If you have Okta admin access:

1. Go to the AWS IAM Identity Center app in Okta
2. Navigate to **Push Groups** tab
3. Find the group: `App-AWS-AA-database-sandbox-941677815499-admin`
4. Click **Push Now** or **Re-push Group**
5. Monitor sync status

### Check 4: AWS IAM Identity Center Logs

```bash
# Check CloudTrail for SCIM events
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=ResourceType,AttributeValue=AWS::SSODirectory::User \
  --max-results 20 \
  --region us-east-2
```

Look for:
- `CreateUser` events from SCIM
- `AddMemberToGroup` events
- Any `ErrorCode` fields

---

## 📞 When to Escalate

**Contact SailPoint Administrators if:**
- ❌ You don't have SailPoint admin access
- ❌ You need to create multiple access profiles
- ❌ You need to set up approval workflows
- ❌ You're in a regulated environment and unsure about compliance

**Contact Okta Administrators if:**
- ❌ SCIM sync is broken
- ❌ Token needs renewal
- ❌ Groups aren't syncing to AWS
- ❌ You get SCIM errors in logs

**Contact AWS Administrators if:**
- ❌ IAM Identity Center is misconfigured
- ❌ SCIM endpoint is unreachable
- ❌ Permission sets aren't assigned properly

---

## 🎓 Key Takeaways

### What You CAN Do Yourself (with right access):

1. ✅ **With Okta Admin:** Manually add users to groups (with caveats)
2. ✅ **With SailPoint Admin:** Create access profiles and assign access properly
3. ✅ **With Both:** Full self-service capability

### What You CANNOT/SHOULD NOT Do:

1. ❌ Manually add users in AWS IAM Identity Center (breaks SCIM)
2. ❌ Bypass governance in regulated environments
3. ❌ Skip documentation of manual changes

### The Recommended Path:

```
1. Check your access levels (Okta + SailPoint)
         ↓
2. If you have SailPoint admin → Use Option 2 (proper way)
         ↓
3. If you only have Okta admin → Use Option 1 (with caution)
         ↓
4. If you have neither → Contact SailPoint admins
         ↓
5. Document everything you do
```

---

## 📚 Additional Resources

### Related Documentation
- `RESEARCH_SUMMARY.md` - Complete architecture overview
- `research/identity-center-investigation/README.md` - SCIM configuration details
- `research/account-navigation/README.md` - AWS account structure

### Key Technical Details
- **Identity Store ID:** `d-9a6763d7d3`
- **Group ID:** `711bf5c0-b071-70c1-06da-35d7fbcac52d`
- **SCIM Endpoint:** `https://scim.us-east-2.amazonaws.com/Hw554936506-e755-4811-8646-adb52f76906a/scim/v2`
- **SCIM Token Expiry:** March 7, 2026
- **IAM Identity Center Account:** 717279730613
- **Region:** us-east-2

### Useful Commands

```bash
# List group memberships
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2

# List all groups
aws identitystore list-groups \
  --identity-store-id d-9a6763d7d3 \
  --region us-east-2

# Get group details
aws identitystore describe-group \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2
```

---

**Last Updated:** November 14, 2025  
**Maintainer:** Research Team  
**Status:** Active Investigation