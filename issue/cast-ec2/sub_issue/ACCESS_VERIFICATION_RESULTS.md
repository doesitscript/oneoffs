# Access Verification Results
## Testing Your EC2 Instance Role Access

**Your Role**: `brd-ue2-dev-cast-srv-01-role`  
**Role ARN**: `arn:aws:iam::925774240130:role/brd-ue2-dev-cast-srv-01-role`  
**Account**: `925774240130` (CAST)  
**Organization**: `o-6wrht8pxbo`

---

## ✅ What I Verified

### 1. KMS Key Policy Allows Your Organization

**KMS Key**: `mrk-6fa2ef2f323e4121a715a6a05fe1cec4`  
**Location**: Account `422228628991` (SharedServices)  
**Key State**: Enabled ✅  
**Key Manager**: CUSTOMER ✅

**Key Policy Statement**:
```json
{
  "Effect": "Allow",
  "Principal": { "AWS": "*" },
  "Action": [
    "kms:Decrypt",
    "kms:DescribeKey"
  ],
  "Condition": {
    "StringEquals": {
      "aws:PrincipalOrgID": "o-6wrht8pxbo"
    }
  }
}
```

**Your Organization**: `o-6wrht8pxbo` ✅  
**Match**: ✅ **YES** - Key policy allows your organization

**Result**: ✅ **KMS key policy allows your role to decrypt**

### 2. Your Current IAM Policy

**What your role HAS**:
- ✅ `secretsmanager:GetSecretValue` on `BreadDomainSecret-CORP*`
- ✅ `secretsmanager:DescribeSecret` on `BreadDomainSecret-CORP*`

**What your role is MISSING**:
- ❌ `kms:Decrypt` on the KMS key
- ❌ `kms:DescribeKey` on the KMS key

**This is why you're getting the error!**

---

## Why You're Getting "Access to KMS is not allowed"

### The Flow

1. **EC2 instance** calls `secretsmanager:GetSecretValue`
2. ✅ **IAM policy allows** this action (you have this permission)
3. **Secrets Manager** tries to decrypt the secret using KMS
4. **AWS checks** if your role can call `kms:Decrypt`
5. ❌ **IAM policy missing** `kms:Decrypt` permission
6. ❌ **Error**: "Access to KMS is not allowed"

### The Two-Permission Requirement

AWS requires **BOTH** permissions for Secrets Manager with CMK:

1. **Secrets Manager permission** (you have this ✅)
   - `secretsmanager:GetSecretValue`

2. **KMS permission** (you're missing this ❌)
   - `kms:Decrypt`

Both must be present in your IAM policy.

---

## ✅ Access Verification: Will It Work?

### KMS Key Policy Check
- ✅ Organization: `o-6wrht8pxbo` matches → **PASS**
- ✅ Action: `kms:Decrypt` is allowed → **PASS**
- ✅ Result: **Key policy allows your role** ✅

### IAM Policy Check
- ✅ Secrets Manager: `GetSecretValue` allowed → **PASS**
- ❌ KMS: `kms:Decrypt` **MISSING** → **FAIL**

### Final Answer

**Once you add `kms:Decrypt` to your IAM policy**: ✅ **YES, it will work**

The KMS key policy already allows your organization, so once you add the IAM permission, everything will work.

---

## What You Need to Add

Add this to your IAM policy for `brd-ue2-dev-cast-srv-01-role`:

```json
{
  "Effect": "Allow",
  "Action": [
    "kms:Decrypt",
    "kms:DescribeKey"
  ],
  "Resource": "arn:aws:kms:us-east-2:422228628991:key/mrk-6fa2ef2f323e4121a715a6a05fe1cec4",
  "Condition": {
    "StringEquals": {
      "kms:ViaService": "secretsmanager.us-east-2.amazonaws.com"
    }
  }
}
```

**After adding this**: Your EC2 instance will be able to access the secret successfully.

---

## Summary

**Q: How do customer-managed keys work?**  
A: They're AWS resources (not files). The key already exists in SharedServices account. You don't "get" or "import" it - you just reference it by ARN and get permission to use it.

**Q: Do I have access via my organization?**  
A: ✅ **YES** - The KMS key policy allows your organization (`o-6wrht8pxbo`), and your CAST account is in that organization.

**Q: Will my role work?**  
A: ✅ **YES, after adding IAM permission** - You just need to add `kms:Decrypt` to your IAM policy. The key policy already allows your organization.

**The key policy is configured correctly. You just need to add the IAM permission.**

