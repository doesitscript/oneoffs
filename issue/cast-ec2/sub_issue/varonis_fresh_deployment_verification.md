# VARONIS Code Fresh Deployment Verification
## Can You Adopt This Code in CAST Account?

**Date**: $(date)
**Purpose**: Evaluate if VARONIS code can be deployed fresh in CAST account (925774240130) and successfully access secrets for domain join

---

## Executive Summary

**⚠️ PARTIALLY - The code has bugs that will prevent it from working as-is**

When you deploy VARONIS code fresh in your CAST account, it will:
- ✅ Create the IAM role successfully
- ✅ Create the IAM policy with Secrets Manager permissions
- ❌ **FAIL** with Terraform syntax error (extra closing brace)
- ❌ **MAY FAIL** with KMS access due to alias cross-account resolution issue
- ❌ Use incorrect JSON capitalization (`condition` vs `Condition`)

**After fixing these 3 bugs, it WILL work** because:
- ✅ KMS key policy already allows your organization
- ✅ Both accounts are in the same AWS organization
- ✅ The IAM policy structure is correct (just needs syntax fixes)

---

## Code Analysis: VARONIS `iam.tf`

### What the Code Does

When deployed in CAST account, this code will create:

1. **IAM Role**: `varonis-role-Production-{region}` (e.g., `varonis-role-Production-us-east-2`)
2. **IAM Policy**: `varonis-secrets-policy-Production-{region}` with permissions for:
   - Secrets Manager: `GetSecretValue` and `DescribeSecret` on secrets in account `422228628991`
   - KMS: `Decrypt` on the KMS key encrypting those secrets

3. **Instance Profile**: Attached to EC2 instances for domain join

### Bugs Found in VARONIS Code

#### Bug 1: Syntax Error - Extra Closing Brace ❌

**Location**: Line 88 in `iam.tf`

```hcl
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt"
        ],
        Resource = "arn:aws:kms:${data.aws_region.current.name}:422228628991:alias/image-key",
        condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      }
      }  # ❌ EXTRA CLOSING BRACE - This will cause Terraform validation to fail
```

**Impact**: Terraform will fail to parse the file. You cannot deploy this code without fixing this.

**Fix**: Remove the extra closing brace on line 88.

#### Bug 2: KMS Alias Cross-Account Resolution ⚠️

**Location**: Line 82 in `iam.tf`

```hcl
Resource = "arn:aws:kms:${data.aws_region.current.name}:422228628991:alias/image-key"
```

**Issue**: KMS aliases may not resolve correctly in cross-account IAM policies. When you're in account `925774240130` (CAST) and reference an alias in account `422228628991` (SharedServices), AWS may not resolve the alias correctly.

**Impact**: 
- The IAM policy might be created successfully
- But when the EC2 instance tries to decrypt, it may fail with "Access to KMS is not allowed"
- The alias might resolve correctly in some cases, but it's unreliable

**Fix**: Use the actual key ARN instead of alias:
```hcl
Resource = "arn:aws:kms:${data.aws_region.current.name}:422228628991:key/mrk-6fa2ef2f323e4121a715a6a05fe1cec4"
```

#### Bug 3: Incorrect JSON Capitalization ⚠️

**Location**: Line 83 in `iam.tf`

```hcl
condition = {  # ❌ lowercase 'c'
```

**Issue**: JSON policy documents should use `Condition` (capital C), not `condition`. Terraform's `jsonencode()` may handle this, but it's not following AWS IAM policy best practices.

**Impact**: Might work, but inconsistent with AWS documentation and could cause issues.

**Fix**: Use capital `C`:
```hcl
Condition = {  # ✅ capital 'C'
```

---

## Verification: Will It Work After Fixes?

### ✅ KMS Key Policy Analysis

The KMS key in account `422228628991` has this policy:

```json
{
  "Effect": "Allow",
  "Principal": { "AWS": "*" },
  "Action": [
    "kms:Decrypt",
    "kms:ReEncrypt*",
    "kms:GenerateDataKey*",
    "kms:CreateGrant",
    "kms:DescribeKey"
  ],
  "Condition": {
    "StringEquals": {
      "aws:PrincipalOrgID": "o-6wrht8pxbo"
    }
  }
}
```

**This means**:
- ✅ Any principal (role/user) in organization `o-6wrht8pxbo` can decrypt
- ✅ CAST account (`925774240130`) is in this organization
- ✅ When you deploy VARONIS code, the role `varonis-role-Production-{region}` will be in CAST account
- ✅ That role will be able to decrypt the secret (after fixing the IAM policy bugs)

### ✅ IAM Policy Analysis

The VARONIS IAM policy (after fixing bugs) will grant:
1. `secretsmanager:GetSecretValue` on secrets in account `422228628991` ✅
2. `kms:Decrypt` on the KMS key (once alias is fixed to key ARN) ✅

**Both permissions are required**:
- IAM policy allows the action ✅
- KMS key policy allows the principal ✅

---

## What Happens When You Deploy Fresh

### Scenario 1: Deploy As-Is (With Bugs)

```bash
cd /path/to/varonis
terraform init
terraform plan
# ❌ ERROR: Extra closing brace on line 88 - Terraform validation fails
```

**Result**: Cannot deploy - Terraform syntax error

### Scenario 2: Deploy After Fixing Syntax Error Only

```bash
# Fix: Remove extra brace on line 88
terraform plan
# ✅ Success - Terraform validates
terraform apply
# ✅ Resources created:
#    - IAM Role: varonis-role-Production-us-east-2
#    - IAM Policy: varonis-secrets-policy-Production-us-east-2
#    - Instance Profile: varonis-profile-Production-us-east-2
```

**Then on EC2 instance**:
```powershell
aws secretsmanager get-secret-value --secret-id BreadDomainSecret-CORPDEV --region us-east-2
# ⚠️ MAY FAIL: "Access to KMS is not allowed"
# Reason: KMS alias may not resolve in cross-account IAM policy
```

**Result**: Resources created, but secret access may fail due to alias resolution

### Scenario 3: Deploy After Fixing All Bugs

```bash
# Fix 1: Remove extra brace
# Fix 2: Replace alias with key ARN
# Fix 3: Fix Condition capitalization
terraform plan
# ✅ Success
terraform apply
# ✅ All resources created
```

**Then on EC2 instance**:
```powershell
aws secretsmanager get-secret-value --secret-id BreadDomainSecret-CORPDEV --region us-east-2
# ✅ SUCCESS: Secret retrieved and decrypted
```

**Result**: Everything works - domain join can proceed

---

## Required Fixes for Fresh Deployment

### Fix 1: Remove Syntax Error (REQUIRED)

**File**: `iam.tf` line 88

**Before**:
```hcl
      }
      }  # ❌ Remove this extra brace
    ]
```

**After**:
```hcl
      }
    ]
```

### Fix 2: Replace Alias with Key ARN (REQUIRED)

**File**: `iam.tf` line 82

**Before**:
```hcl
Resource = "arn:aws:kms:${data.aws_region.current.name}:422228628991:alias/image-key",
```

**After**:
```hcl
Resource = "arn:aws:kms:${data.aws_region.current.name}:422228628991:key/mrk-6fa2ef2f323e4121a715a6a05fe1cec4",
```

### Fix 3: Fix Condition Capitalization (RECOMMENDED)

**File**: `iam.tf` line 83

**Before**:
```hcl
condition = {
```

**After**:
```hcl
Condition = {
```

### Fix 4: Add kms:DescribeKey (RECOMMENDED)

**File**: `iam.tf` line 80

**Before**:
```hcl
Action = [
  "kms:Decrypt"
],
```

**After**:
```hcl
Action = [
  "kms:Decrypt",
  "kms:DescribeKey"
],
```

---

## Complete Fixed Policy Block

Here's the corrected `secrets_access_policy` resource:

```hcl
resource "aws_iam_policy" "secrets_access_policy" {
  name        = "${local.name_prefix}-secrets-policy-Production-${data.aws_region.current.name}"
  description = "Policy for cross-account secrets access to customer-image-mgmt"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "arn:aws:secretsmanager:*:422228628991:secret:BreadDomainSecret-CORP*"
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource = "arn:aws:kms:${data.aws_region.current.name}:422228628991:key/mrk-6fa2ef2f323e4121a715a6a05fe1cec4",
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-secrets-policy"
  })
}
```

---

## Deployment Verification Steps

After fixing the code and deploying:

### Step 1: Verify IAM Role Created

```bash
export AWS_PROFILE=CASTSoftware_dev_925774240130_admin
aws iam get-role --role-name varonis-role-Production-us-east-2
```

### Step 2: Verify IAM Policy Has Correct Permissions

```bash
POLICY_ARN=$(aws iam list-policies --query 'Policies[?PolicyName==`varonis-secrets-policy-Production-us-east-2`].Arn' --output text)
aws iam get-policy-version --policy-arn $POLICY_ARN --version-id $(aws iam get-policy --policy-arn $POLICY_ARN --query 'Policy.DefaultVersionId' --output text) --query 'PolicyVersion.Document' | jq '.Statement[] | select(.Action[]? | contains("kms"))'
```

Expected: Should show `kms:Decrypt` and `kms:DescribeKey` actions with the key ARN (not alias).

### Step 3: Test from EC2 Instance

```powershell
# On EC2 instance with varonis-role-Production-us-east-2 attached
aws sts get-caller-identity
# Should show: arn:aws:iam::925774240130:role/varonis-role-Production-us-east-2

aws secretsmanager get-secret-value \
  --secret-id BreadDomainSecret-CORPDEV \
  --region us-east-2
# Should succeed and return secret value
```

---

## Answers to Your Questions

### Q1: Is your teammate using customer-managed keys?
**A: YES** ✅
- The secret is encrypted with a customer-managed key (CMK)
- Key ID: `mrk-6fa2ef2f323e4121a715a6a05fe1cec4`
- Key Manager: `CUSTOMER`

### Q2: Can you adopt the code without customer-managed keys?
**A: NO** ❌
- The secret in account `422228628991` is encrypted with a CMK
- You MUST have access to this key to decrypt the secret
- The domain join script needs the secret to work
- You cannot use the code without KMS access

### Q3: Will you be able to domain join your EC2 instance?
**A: YES, after fixing the bugs** ✅

**Why it will work:**
1. ✅ KMS key policy allows your organization (`o-6wrht8pxbo`)
2. ✅ CAST account is in this organization
3. ✅ VARONIS IAM policy (after fixes) will grant `kms:Decrypt`
4. ✅ Both sides of authorization will be satisfied

**What needs to happen:**
1. Fix the 3 bugs in VARONIS code
2. Deploy the fixed code in CAST account
3. EC2 instance will be able to access secret
4. Domain join script will work

---

## Summary

**Can you adopt VARONIS code?**: **YES, but with fixes required**

**Required Actions**:
1. ❌ Fix syntax error (extra closing brace)
2. ❌ Replace KMS alias with key ARN
3. ⚠️ Fix Condition capitalization
4. ✅ Deploy in CAST account
5. ✅ Test secret access

**Estimated Time**: 15-30 minutes to fix and deploy

**Risk Level**: Low - No changes needed to shared resources (KMS key, secret)

**Will domain join work?**: **YES** - After fixing the code, everything will work because the KMS key policy already allows your organization.

