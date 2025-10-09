# SSO Permissions Research Results for CAST EC2 Access

## Executive Summary

This research was conducted to determine whether users `a-a836660` and `a-a837172` have the necessary SSO permissions to start SSM sessions to the target EC2 instances in the CAST Software development account (925774240130).

## Key Findings

### 1. User Status in Identity Center

**User a-a836660 (Corey Schnedl):**
- ✅ **EXISTS** in Identity Center
- **User ID:** `e18ba510-1001-70f0-3861-d4cfe87e1540`
- **Email:** `Corey.Schnedl+aa-a836660@breadfinancial.com`
- **Display Name:** `Schnedl, Corey`
- **Username:** `aa-a836660`

**User a-a837172:**
- ❌ **NOT FOUND** in Identity Center
- This user does not exist in the current Identity Center instance

### 2. Account Assignments and Permission Sets

**CAST Account (925774240130) has two group assignments:**

1. **Global Admin Group:**
   - **Group:** `App-AWS-global-admin` (ID: `d12bf5d0-4011-7009-eae4-99d6da1e4a6d`)
   - **Description:** "global admin access"
   - **Permission Set:** `admin-v20250516`
   - **Permissions:** `AdministratorAccess` (includes all SSM permissions)

2. **CAST-Specific Admin Group:**
   - **Group:** `App-AWS-AA-CASTSoftware-dev-925774240130-admin` (ID: `61bb05b0-8031-703d-b9e4-b8c1c28cff23`)
   - **Description:** "admin access to a single account"
   - **Permission Set:** `admin-v20250516`
   - **Permissions:** `AdministratorAccess` (includes all SSM permissions)

**Critical Finding:** User `a-a836660` is **NOT** a member of either group that has access to the CAST account.

### 3. Session Manager Configuration

**✅ Session Manager is properly configured:**

- **Available Session Documents:**
  - `AWS-StartPortForwardingSession` ✅ (Required for port forwarding)
  - `AWS-StartInteractiveCommand` ✅
  - `AWS-StartSSHSession` ✅
  - Multiple other session documents available

- **KMS Configuration:**
  - **SSM KMS Key:** `arn:aws:kms:us-east-2:925774240130:key/66081cdc-f1c8-49d8-a5a4-7c1a2d43be27`
  - **Alias:** `alias/aws/ssm`
  - **Key Policy:** Allows access for all principals in account authorized to use SSM
  - **Status:** ✅ Properly configured for SSO role access

### 4. EC2 Instance Readiness

**✅ All EC2 instances are ready for SSM:**

| Instance ID | Name | Private IP | SSM Status | Agent Version |
|-------------|------|------------|------------|---------------|
| `i-0ea5a899c05d1a183` | `ec2-ecs-cast-01` | `10.62.17.103` | ✅ Online | `3.3.3050.0` |
| `i-00a3cb5faf95c6561` | `ec2-ecs-cast-02` | `10.62.20.5` | ✅ Online | `3.3.3050.0` |
| `i-0f885d5d5b39d44bd` | `i-04fb9d4bef17b91b3` | `10.62.20.59` | ✅ Online | `3.3.3050.0` |

**Instance IAM Configuration:**
- **Role:** `bf-global-devonly-AmazonSSMManagedInstanceCore`
- **Policy:** `AmazonSSMManagedInstanceCore` ✅
- **Status:** All instances properly configured for SSM access

## Recommendations

### Immediate Actions Required

1. **Add User a-a836660 to Appropriate Group:**
   - Add user `a-a836660` to either:
     - `App-AWS-AA-CASTSoftware-dev-925774240130-admin` (recommended for least privilege)
     - `App-AWS-global-admin` (if broader access is needed)

2. **Investigate User a-a837172:**
   - Verify if this user should exist in Identity Center
   - If needed, create the user account
   - Add to appropriate group once created

### Implementation Steps

1. **Contact Sailpoint Administrator:**
   - Request addition of user `a-a836660` to the CAST Software admin group
   - Verify the business role/entitlement that maps to this access
   - Confirm expected sync cadence for Identity Center group membership

2. **Verify Access After Changes:**
   - Test SSM port forwarding session once user is added to group
   - Confirm user can assume the SSO role in CAST account
   - Validate port forwarding works to target instances

### Technical Details

**SSO Role ARN Pattern:**
```
arn:aws:sts::925774240130:assumed-role/AWSReservedSSO_admin-v20250516_2ad36fe030b175bc/{username}
```

**Required Permissions (already included in AdministratorAccess):**
- `ssm:StartSession`
- `ssm:DescribeSessions`
- `ssm:TerminateSession`
- `ssm:ResumeSession`
- `kms:Decrypt` (for SSM KMS key)
- `kms:GenerateDataKey` (for SSM KMS key)

## Conclusion

The infrastructure is **fully ready** for SSM port forwarding. The only missing piece is the user group membership in Identity Center. Once user `a-a836660` is added to the appropriate group, they will have full access to start SSM sessions and perform port forwarding to the CAST EC2 instances.

**Status:** ✅ Infrastructure Ready, ❌ User Access Missing
