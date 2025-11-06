Short answer: that error means the instance's role can talk to Secrets Manager, but it isn't allowed to use the KMS key that encrypts the secret. You need both permissions:

1. secretsmanager:GetSecretValue on the secret
2. kms:Decrypt on the KMS key that secret uses (and the key policy must allow your role)

## Your Configuration Details

- **Instance Account**: `925774240130` (CAST Software Dev)
- **Secret Account**: `422228628991` (customer-image-mgmt)
- **Region**: `us-east-2` (matches your `ue2` region code)
- **Instance Role**: `brd-ue2-dev-cast-srv-01-role`
- **Full Role ARN**: `arn:aws:iam::925774240130:role/brd-ue2-dev-cast-srv-01-role`
- **Secret ARN Pattern**: `arn:aws:secretsmanager:us-east-2:422228628991:secret:BreadDomainSecret-CORPDEV-*`

## Phase 1 — Confirm Who You Are and Which Key the Secret Uses

Run these commands **on the CAST instance**:

```powershell
# who am I (which role)?
aws sts get-caller-identity
# Expected output should show: arn:aws:iam::925774240130:role/brd-ue2-dev-cast-srv-01-role

# region (us-east-2 for your configuration)
$currentRegion = "us-east-2"
# Or dynamically: $currentRegion = (Invoke-RestMethod -UseBasicParsing http://169.254.169.254/latest/dynamic/instance-identity/document).region

# find the secret's KMS key
$secretArn = "arn:aws:secretsmanager:us-east-2:422228628991:secret:BreadDomainSecret-CORPDEV"
$secretMeta = aws secretsmanager describe-secret --secret-id $secretArn --region $currentRegion
$secretMeta
# note the KmsKeyId field (could be a key ARN)
```

## Phase 2 — Check the Key and Policy

```powershell
# Extract the KMS key ARN from the secret metadata
$secretObj = $secretMeta | ConvertFrom-Json
$keyArn = $secretObj.KmsKeyId
Write-Host "KMS Key ARN: $keyArn"

# Check if you can describe the key (this will fail if key policy doesn't allow you)
aws kms describe-key --key-id $keyArn --region $currentRegion

# Get the key policy (this will fail if key policy doesn't allow you)
aws kms get-key-policy --key-id $keyArn --policy-name default --region $currentRegion
```

If kms describe/get-key-policy fails or the policy doesn't mention your instance role ARN (`arn:aws:iam::925774240130:role/brd-ue2-dev-cast-srv-01-role`), that's the blocker.

## What Needs to Be Allowed (Minimum)

* Your instance profile role (`brd-ue2-dev-cast-srv-01-role`) must have IAM permission:
  * ✅ `secretsmanager:GetSecretValue` on the specific secret (already configured in your `iam.tf`)
  * ❌ `kms:Decrypt` on the specific key ARN (missing - this is what you need to add)
* The KMS key policy must allow your role (or your account) to use Decrypt. With customer-managed keys, IAM permission alone isn't enough if the key policy doesn't trust your principal.

## Terraform Fix for Your Configuration

You need to update your existing `secrets_access_policy` in `iam.tf` to include KMS decrypt permissions. Here's the updated policy that matches your existing structure:

```hcl
# Update your existing aws_iam_policy.secrets_access_policy in iam.tf
resource "aws_iam_policy" "secrets_access_policy" {
  name        = "${local.resource_name}-secrets-policy"
  description = "Policy for cross-account secrets access to customer-image-mgmt with KMS decrypt"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "GetSecretValue"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "arn:aws:secretsmanager:*:422228628991:secret:BreadDomainSecret-CORP*"
      },
      {
        Sid    = "KMSDecryptForSecret"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource = "*"  # You'll need to narrow this to the specific key ARN once you discover it
        # After Phase 1, replace with: Resource = "<actual-kms-key-arn>"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${local.resource_name}-secrets-policy"
  })
}
```

**Note**: After running Phase 1 and discovering the actual KMS key ARN, replace `Resource = "*"` with the specific key ARN for better security. The wildcard works but is less secure.

## KMS Key Policy Snippet (For Platform Team)

The KMS key in account `422228628991` needs to allow your instance role to decrypt. Add this statement to the key policy:

```json
{
  "Sid": "AllowCASTInstanceRoleDecrypt",
  "Effect": "Allow",
  "Principal": { 
    "AWS": "arn:aws:iam::925774240130:role/brd-ue2-dev-cast-srv-01-role" 
  },
  "Action": [ 
    "kms:Decrypt", 
    "kms:DescribeKey" 
  ],
  "Resource": "*",
  "Condition": {
    "StringEquals": { 
      "kms:ViaService": "secretsmanager.us-east-2.amazonaws.com" 
    }
  }
}
```

**Important**: This key policy is in account `422228628991` (customer-image-mgmt), not your CAST account. You'll need to coordinate with whoever manages that account/key to add this policy statement.

## Quick Triage Checklist

* ✅ **Cross-account access**: You're in account `925774240130`, secret is in `422228628991`. This is cross-account, so you need:
  1. ✅ IAM policy on your role (already have `secretsmanager:GetSecretValue`, need to add `kms:Decrypt`)
  2. ❌ KMS key policy must trust your role (needs to be added by key owner)
  3. ⚠️ Secret resource policy may need to allow your role (check if needed)
* **VPC endpoint policy**: Check if there's a VPC endpoint policy for KMS/Secrets that denies Decrypt/GetSecretValue. If yes, adjust it.
* ✅ **Region**: Your region is `us-east-2`, which matches the secret region.
* **Customer-managed KMS key**: Most likely yes. The platform team managing account `422228628991` can either:
  - Update the key policy (preferred), OR
  - Create a grant using this command (alternative approach):

```bash
# Run this from account 422228628991 (or have platform team run it)
aws kms create-grant \
  --key-id "$keyArn" \
  --grantee-principal arn:aws:iam::925774240130:role/brd-ue2-dev-cast-srv-01-role \
  --operations Decrypt DescribeKey \
  --region us-east-2
```

## Once Fixed, Re-Test

After updating both:
1. Your IAM policy in `iam.tf` (add KMS decrypt)
2. The KMS key policy in account `422228628991` (add your role ARN)

Test on the instance:

```powershell
$currentRegion = "us-east-2"
$secretArn = "arn:aws:secretsmanager:us-east-2:422228628991:secret:BreadDomainSecret-CORPDEV"
aws secretsmanager get-secret-value --secret-id $secretArn --region $currentRegion
```

## Action Items Summary

1. **Run Phase 1 & 2** on the instance to get the KMS key ARN
2. **Update `iam.tf`**: Add `kms:Decrypt` and `kms:DescribeKey` to your `secrets_access_policy`
3. **Contact platform team**: Have them add your role ARN to the KMS key policy in account `422228628991`
4. **Run `terraform apply`** after updating `iam.tf`
5. **Re-test** using the command above

If you paste back the describe-secret output (just the KmsKeyId) and confirm the role ARN from `sts get-caller-identity`, I can tell you exactly which side needs the change.
