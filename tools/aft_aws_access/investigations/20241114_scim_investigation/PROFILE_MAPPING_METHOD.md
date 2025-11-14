# AWS Profile Mapping Methodology

**Date:** November 14, 2025  
**Purpose:** How we mapped AWS profiles to accounts and used correct credentials

---

## 🎯 Profile Naming Convention Discovery

All AWS profiles in `~/.aws/config` follow a consistent naming pattern:

```
{AccountName}_{AccountID}_admin
```

**Examples:**
- `database_sandbox_941677815499_admin` → Account ID: 941677815499
- `bfh_mgmt_739275453939_admin` → Account ID: 739275453939
- `Identity_Center_717279730613_admin` → Account ID: 717279730613

## 🔍 Mapping Process

### Step 1: Extract Account ID from Profile Name
```bash
# Profile name contains the 12-digit account ID
PROFILE="database_sandbox_941677815499_admin"
ACCOUNT_ID=$(echo "$PROFILE" | grep -oE '[0-9]{12}')  # Returns: 941677815499
```

### Step 2: Verify with AWS STS
```bash
# Confirm the profile actually accesses the expected account
aws sts get-caller-identity --profile $PROFILE --query 'Account' --output text
# Returns: 941677815499 ✓ Matches!
```

### Step 3: Use Profile in All Commands
```bash
# All AWS CLI commands use the --profile flag
aws identitystore list-groups \
  --identity-store-id d-9a6763d7d3 \
  --region us-east-2 \
  --profile database_sandbox_941677815499_admin  # ← Correct profile
```

## ✅ Verification Strategy

**Before each investigation, we verified:**

1. **Profile exists in config:** `cat ~/.aws/config | grep "{ProfileName}"`
2. **Profile has valid credentials:** `aws sts get-caller-identity --profile {ProfileName}`
3. **Account ID matches:** Extracted account ID from profile name matches actual account ID

## 📊 Identity Store ID Discovery

**Key Finding:** All accounts share the **same Identity Store ID**: `d-9a6763d7d3`

This is because:
- All accounts are managed by a single AWS IAM Identity Center instance
- The Identity Center lives in the `Identity_Center_717279730613` account
- All other accounts delegate authentication to this shared Identity Store

**Verification:**
```bash
# Any account with Identity Center returns the same Identity Store ID
aws sso-admin list-instances --region us-east-2 --profile {AnyProfile}
# Always returns: d-9a6763d7d3
```

## 🎯 Region Consistency

**All operations used:** `us-east-2`

**Why:** 
- IAM Identity Center instance is in us-east-2
- CloudTrail lookup-events defaults to the region where events occurred
- Consistency across all 21 accounts investigated

## 📝 Example Investigation Pattern

```bash
# For each account:
PROFILE="Account_Name_123456789012_admin"
ACCOUNT_ID="123456789012"
IDENTITY_STORE="d-9a6763d7d3"
REGION="us-east-2"

# Verify access
aws sts get-caller-identity --profile $PROFILE

# Investigate CloudTrail
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
  --region $REGION \
  --profile $PROFILE

# Check Identity Center groups
aws identitystore list-groups \
  --identity-store-id $IDENTITY_STORE \
  --region $REGION \
  --profile $PROFILE
```

## 🔑 Key Takeaways for Future AI Agents

1. **Profile name contains account ID** - Extract with regex `[0-9]{12}`
2. **Always verify with STS** - Confirm profile accesses expected account
3. **Use consistent region** - us-east-2 for all Identity Center operations
4. **Identity Store is shared** - d-9a6763d7d3 across all accounts
5. **Always use --profile flag** - Never rely on default credentials

---

**Bottom Line:** Profile naming convention made it easy to map profiles to accounts. Account ID extraction + STS verification ensured we always used the correct credentials.