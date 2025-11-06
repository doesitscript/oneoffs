# Customer-Managed Key (CMK) Explanation & Access Verification

## How Customer-Managed Keys Work

### What is a Customer-Managed Key (CMK)?

A **Customer-Managed Key (CMK)** is a KMS key that **you create and manage** in AWS. It's NOT a file you download or import - it's an **AWS resource** that lives in AWS.

Think of it like this:
- **AWS-Managed Key**: AWS creates and manages it (you just use it)
- **Customer-Managed Key**: You create it in AWS, you control who can use it, you manage it

### How CMKs Work - The Key Facts

1. **CMKs are AWS Resources** (not files)
   - Created in AWS KMS service
   - Stored in AWS (not on your computer)
   - Never leave AWS (for security)
   - You don't "download" or "import" them

2. **CMKs are Account-Specific**
   - Each CMK is created in a specific AWS account
   - The key in your scenario is in account `422228628991` (SharedServices)
   - It's NOT in your CAST account (`925774240130`)

3. **You Don't "Get" the Key - You Get Permission to Use It**
   - You don't need to copy the key to your account
   - You just need **permission** to use it
   - Two types of permissions are needed:
     - **IAM Policy** (in your account): Allows your role to call `kms:Decrypt`
     - **KMS Key Policy** (in key's account): Allows your role to actually decrypt

4. **Cross-Account Access Works Like This**:
   ```
   Your EC2 Instance (CAST account)
   ↓
   Uses IAM Role (brd-ue2-dev-cast-srv-01-role)
   ↓
   IAM Policy says: "Role can call kms:Decrypt on key XYZ"
   ↓
   AWS checks KMS Key Policy (in SharedServices account)
   ↓
   Key Policy says: "Allow organization o-6wrht8pxbo to decrypt"
   ↓
   ✅ Access granted (your account is in that org)
   ```

### What Happens When You Deploy VARONIS Code

When you deploy VARONIS code in your CAST account:

1. **You create IAM resources** (role, policy, instance profile) in CAST account
2. **You do NOT create the KMS key** - it already exists in SharedServices account
3. **You reference the key by ARN** in your IAM policy
4. **The key policy (already configured) allows your organization**

**You never "get" or "import" the key** - you just reference it and use it.

---

## Access Verification

### Your EC2 Instance Role

From your test instance:
```json
{
    "UserId": "AROA5PDDR3GBA5SCPH2NO:i-0a04cb53a9e6a2348",
    "Account": "925774240130",
    "Arn": "arn:aws:sts::925774240130:assumed-role/brd-ue2-dev-cast-srv-01-role/i-0a04cb53a9e6a2348"
}
```

**Role**: `brd-ue2-dev-cast-srv-01-role`  
**Account**: `925774240130` (CAST)  
**Full ARN**: `arn:aws:iam::925774240130:role/brd-ue2-dev-cast-srv-01-role`

### KMS Key Policy Analysis

The KMS key in account `422228628991` has this policy statement:

```json
{
  "Sid": "Allow KMS Permission for Bread Org to use AMI which will be encrypted by this Key",
  "Effect": "Allow",
  "Principal": {
    "AWS": "*"
  },
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

**What this means**:
- ✅ **Principal**: `"AWS": "*"` means "any AWS principal"
- ✅ **Condition**: But only if `aws:PrincipalOrgID == "o-6wrht8pxbo"`
- ✅ **Your account**: CAST account (`925774240130`) is in organization `o-6wrht8pxbo`
- ✅ **Your role**: `brd-ue2-dev-cast-srv-01-role` is in CAST account
- ✅ **Result**: Your role CAN decrypt using this key

### Organization Verification

**CAST Account Organization**:
```json
{
    "Id": "o-6wrht8pxbo",
    "Arn": "arn:aws:organizations::739275453939:organization/o-6wrht8pxbo"
}
```

**KMS Key Policy Requires**:
- Organization ID: `o-6wrht8pxbo`

**Match**: ✅ **YES** - Your account is in the correct organization

---

## Why This Works

### The Two-Permission System

AWS requires **BOTH** permissions for cross-account KMS access:

1. **IAM Policy** (in your CAST account):
   - Must allow your role to call `kms:Decrypt`
   - Currently: ❌ **MISSING** - Your role doesn't have this permission
   - VARONIS code will add this (after fixing bugs)

2. **KMS Key Policy** (in SharedServices account):
   - Must allow your role/account/organization to decrypt
   - Currently: ✅ **PRESENT** - Key policy allows your organization

### Current Status

**Your Role** (`brd-ue2-dev-cast-srv-01-role`):
- ✅ Exists in CAST account
- ✅ Can assume role (EC2 instance can use it)
- ❌ **Missing `kms:Decrypt` permission** in IAM policy
- ❌ **Missing `secretsmanager:GetSecretValue` permission** (probably)

**KMS Key** (in SharedServices account):
- ✅ Exists
- ✅ Key policy allows your organization
- ✅ Your role WILL be able to decrypt (once IAM policy is fixed)

---

## What You Need to Do

### Option 1: Fix Your Existing CAST Role

Add KMS decrypt permission to your existing `brd-ue2-dev-cast-srv-01-role`:

```hcl
resource "aws_iam_policy" "secrets_access_policy" {
  name = "brd-ue2-dev-cast-srv-01-secrets-policy"
  
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
        Resource = "arn:aws:kms:us-east-2:422228628991:key/mrk-6fa2ef2f323e4121a715a6a05fe1cec4",
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.us-east-2.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_access" {
  role       = "brd-ue2-dev-cast-srv-01-role"
  policy_arn = aws_iam_policy.secrets_access_policy.arn
}
```

### Option 2: Deploy VARONIS Code (After Fixing Bugs)

Deploy the fixed VARONIS code, which will create a new role with the correct permissions.

---

## Summary: How CMKs Work

### ❌ What CMKs Are NOT:
- ❌ A file you download
- ❌ A file you import
- ❌ Something stored in Terraform state (it's in AWS)
- ❌ Something you copy between accounts

### ✅ What CMKs ARE:
- ✅ An AWS resource (like an EC2 instance or S3 bucket)
- ✅ Created in AWS KMS service
- ✅ Stored in AWS (never leaves AWS)
- ✅ Controlled by IAM policies and key policies
- ✅ Referenced by ARN (not imported)

### ✅ How You Use Them:
1. **Key already exists** in SharedServices account (`422228628991`)
2. **Key policy already allows** your organization
3. **You just need IAM permission** in your CAST account
4. **Reference the key by ARN** in your IAM policy
5. **That's it** - AWS handles the rest

---

## Verification: Will Your Role Work?

**Your Role**: `arn:aws:iam::925774240130:role/brd-ue2-dev-cast-srv-01-role`

**KMS Key Policy Check**:
- ✅ Organization check: `aws:PrincipalOrgID == "o-6wrht8pxbo"` → **PASS** (your account is in this org)
- ✅ Action check: `kms:Decrypt` is allowed → **PASS**
- ✅ Result: **Key policy allows your role** ✅

**What's Missing**:
- ❌ IAM policy on your role allowing `kms:Decrypt`
- ❌ IAM policy on your role allowing `secretsmanager:GetSecretValue`

**Once you add IAM permissions**: ✅ **Everything will work**

---

## The Bottom Line

**You don't "get" or "import" the customer-managed key**. 

The key already exists in the SharedServices account and is already configured to allow your organization. You just need to:

1. Add IAM permissions in your CAST account (via VARONIS code or manually)
2. Reference the key by ARN in your IAM policy
3. That's it - AWS handles the cross-account access automatically

**The key policy is like a door that's already unlocked for your organization. You just need the IAM permission to "open the door" (call kms:Decrypt).**

