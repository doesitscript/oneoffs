# CAST Infrastructure Assessment Report
**Date**: 2025-01-26  
**Instance ID**: `i-0565d268ae24eff7a`  
**Account**: 925774240130 (CASTSoftware_dev)  
**Region**: us-east-2

## Executive Summary

The CAST infrastructure is **deployed and running**, but **NOT configured for domain join**. The instance is currently in a WORKGROUP configuration and needs user data to be set for domain join to occur.

### Current Status: ⚠️ **READY FOR DOMAIN JOIN** (not yet joined)

---

## 1. Infrastructure State Assessment

### ✅ Instance Status
- **Instance ID**: `i-0565d268ae24eff7a`
- **State**: Running
- **Private IP**: `10.62.17.105`
- **Computer Name**: `EC2AMAZ-D3QSRGA.WORKGROUP` ⚠️ (Not domain-joined)
- **Instance Type**: `m5.8xlarge` (32 vCPUs, 128 GB RAM)
- **AMI**: `ami-08acfbd98127249e6` (from account 422228628991 - Bread Financial)
- **VPC**: `vpc-030d39057ed8fa1b5` (castsoftwaredev)
- **Subnet**: `subnet-017c107f70413bbb9`

### ✅ IAM Configuration

#### Instance Profile Attachment
- **Status**: ✅ **ATTACHED**
- **Instance Profile**: `cast-profile-dev-us-east-2`
- **ARN**: `arn:aws:iam::925774240130:instance-profile/cast-profile-dev-us-east-2`
- **IAM Role**: `cast-role-dev-us-east-2`

#### IAM Policies Attached
1. ✅ **AmazonSSMManagedInstanceCore** - Enables SSM Session Manager access
2. ✅ **cast-secrets-policy-dev-us-east-2** - Cross-account secrets access
3. ✅ **cast-cloudwatch-policy-dev-us-east-2** - CloudWatch Logs access

#### Secrets Access Policy Details
```json
{
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ],
    "Resource": "arn:aws:secretsmanager:*:422228628991:secret:BreadDomainSecret-CORP*"
  }]
}
```

**Status**: ✅ Policy correctly configured for cross-account access.

### ✅ Cross-Account Secrets Access

#### Secrets Available in Account 422228628991 (SharedServices-imagemanagement)
- ✅ `BreadDomainSecret-CORP` (ARN: `arn:aws:secretsmanager:us-east-2:422228628991:secret:BreadDomainSecret-CORP-BAd6K3`)
- ✅ `BreadDomainSecret-CORPQA`
- ✅ `BreadDomainSecret-CORPDEV` (For DEV environment)

#### Resource Policy on Secrets
The secrets have a resource policy that allows:
- **Principal**: `*` (any principal)
- **Condition**: `aws:PrincipalOrgID = "o-6wrht8pxbo"` (Bread Financial Organization)
- **Action**: `secretsmanager:GetSecretValue`

**Status**: ✅ Cross-account access **IS PERMITTED** via organization-level policy.

### ✅ Security Group Configuration

**Security Group ID**: `sg-01fd31242a2e605a3`  
**Name**: `cast-sg-dev`

#### Ingress Rules
| Protocol | Port | Source | Description |
|----------|------|--------|-------------|
| TCP | 3389 | 10.0.0.0/8 | RDP |
| TCP | 443 | 10.0.0.0/8 | HTTPS |

#### Egress Rules
- ✅ All traffic allowed (0.0.0.0/0) - Required for domain join and AWS service access

**Status**: ✅ Security group properly configured for RDP and HTTPS access.

### ✅ Network Configuration

- **VPC**: `vpc-030d39057ed8fa1b5` - CAST VPC
- **CIDR Blocks**: 
  - `10.62.20.0/24`
  - `10.62.17.64/26` (instance subnet)
- **DNS Support**: ✅ Enabled
- **DNS Hostnames**: ✅ Enabled
- **Subnet**: `subnet-017c107f70413bbb9` (us-east-2c)

**Status**: ✅ Network configuration is correct.

---

## 2. Domain Join Configuration

### ❌ **CRITICAL ISSUE: Domain Join Not Configured**

#### Current User Data
- **Status**: ❌ **EMPTY** (`null` in Terraform state)
- **Current Value**: `domain_join_user_data = ""` (in `cast.tfvars.MVP2`)

#### Required User Data Format
Based on the Terraform configuration and documentation, the domain join requires:
```
"brd26w080n1,dev"
```
Where:
- `brd26w080n1` = Hostname for the Windows instance
- `dev` = Environment (determines which secret to use: `BreadDomainSecret-CORPDEV`)

#### How Domain Join Works
The AMI (`ami-08acfbd98127249e6`) from account `422228628991` is a **custom Bread Financial AMI** that contains:
- Pre-installed domain join script that reads user data
- Script format: `hostname,environment`
- Script retrieves credentials from Secrets Manager: `BreadDomainSecret-CORP{ENVIRONMENT}`
- Uses PowerShell `Add-Computer` to join the domain

**Action Required**: Update `cast.tfvars.MVP2`:
```hcl
domain_join_user_data = "brd26w080n1,dev"
```

Then run `terraform apply` with the updated tfvars file.

---

## 3. Pre-Domain Join Checklist

### ✅ Items That Are Correct

1. ✅ **Instance Profile Attached**: `cast-profile-dev-us-east-2` is attached to the instance
2. ✅ **Secrets Access Policy**: Policy allows access to `BreadDomainSecret-CORP*` patterns
3. ✅ **SSM Core Policy**: Enables remote access via Session Manager
4. ✅ **Cross-Account Secrets**: Secrets exist and resource policy allows org-wide access
5. ✅ **Security Group**: Allows RDP (3389) and HTTPS (443) from 10.0.0.0/8
6. ✅ **Network Configuration**: VPC, subnet, and DNS properly configured
7. ✅ **Instance State**: Instance is running and healthy

### ⚠️ Items That Need Attention

1. ⚠️ **Domain Join User Data**: Currently empty, needs to be set to `"brd26w080n1,dev"`
2. ⚠️ **Hostname Verification**: Confirm `brd26w080n1` is available in Active Directory
3. ⚠️ **Network Connectivity**: Verify VPC routing to on-premises domain controllers (VPC route tables, Transit Gateway, Direct Connect)

### 🔍 Additional Checks Needed

1. **Domain Controller Connectivity**:
   - Verify VPC route tables route to on-premises network
   - Test connectivity to domain controllers (ports 88, 389, 445, 636)
   - Verify DNS resolution for `corp.alldata.net`

2. **Domain Join Permissions**:
   - Verify service account in Secrets Manager has domain join rights
   - Confirm hostname `brd26w080n1` is not already in use

---

## 4. Post-Domain Join Access Methods

### Method 1: AWS Systems Manager Session Manager (Recommended)

**Advantages**:
- ✅ No VPN required
- ✅ No security group rules needed (uses SSM endpoints)
- ✅ Secure, encrypted tunnel
- ✅ No exposed ports

**How to Connect**:
```bash
# Connect via SSM Session Manager (PowerShell)
aws ssm start-session \
  --target i-0565d268ae24eff7a \
  --profile CASTSoftware_dev_925774240130_admin \
  --region us-east-2 \
  --document-name AWS-StartInteractiveCommand \
  --parameters command="powershell.exe"
```

**After Domain Join**:
- Log in with domain credentials: `CORP\username`
- Or use local admin: `.\Administrator` (if still available)

### Method 2: RDP via VPN + Port Forwarding

**Prerequisites**:
- VPN connection to corporate network
- Source IP must be in `10.0.0.0/8` range

**How to Connect**:
```bash
# Option 1: Direct RDP (if VPN provides route to VPC)
mstsc /v:10.62.17.105

# Option 2: AWS Systems Manager Port Forwarding
aws ssm start-session \
  --target i-0565d268ae24eff7a \
  --profile CASTSoftware_dev_925774240130_admin \
  --region us-east-2 \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["3389"],"localPortNumber":["13389"]}'

# Then connect via:
mstsc /v:localhost:13389
```

**Credentials After Domain Join**:
- Domain user: `CORP\username` (use your AD credentials)
- Domain admin: `CORP\DomainAdmin` (if you have access)

### Method 3: SSH (If Configured)

**Status**: ⚠️ SSH not currently configured in user data

If SSH is configured (via user data script), you can connect:
```bash
# Get SSH private key from Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id cast-ssh-key-dev \
  --profile CASTSoftware_dev_925774240130_admin \
  --region us-east-2 \
  --query SecretString --output text > ~/.ssh/cast-dev-key.pem

chmod 600 ~/.ssh/cast-dev-key.pem

# Connect via SSM Port Forwarding for SSH
aws ssm start-session \
  --target i-0565d268ae24eff7a \
  --profile CASTSoftware_dev_925774240130_admin \
  --region us-east-2 \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["22"],"localPortNumber":["2222"]}'

# Then SSH
ssh -i ~/.ssh/cast-dev-key.pem Administrator@localhost -p 2222
```

---

## 5. Admin User Access

### Current State (Before Domain Join)

**Local Administrator Account**:
- **Username**: `Administrator`
- **Password**: Generated by AWS (can be retrieved via `aws ec2 get-password-data`)
- **SSH Key**: Available in Secrets Manager (`cast-ssh-key-dev`)
- **Status**: ✅ Available for initial access

### After Domain Join

**Domain Admin Access**:
- **Domain Users**: `CORP\username` (your AD credentials)
- **Domain Admins**: `CORP\DomainAdmin` (if you have domain admin rights)
- **Local Admin**: May still be available as `.\Administrator` or `EC2AMAZ-D3QSRGA\Administrator`

**Note**: The local Administrator account may be disabled or renamed per domain policy after domain join.

---

## 6. Testing After Domain Join

### Test 1: Verify Domain Membership

```powershell
# Connect via SSM Session Manager
aws ssm start-session --target i-0565d268ae24eff7a \
  --profile CASTSoftware_dev_925774240130_admin \
  --region us-east-2

# Then run in PowerShell:
Get-ComputerInfo | Select-Object CsDomain, CsDomainRole, CsName
```

**Expected Output**:
```
CsDomain      : CORP.ALLDATA.NET
CsDomainRole  : Member
CsName        : brd26w080n1
```

### Test 2: Verify Domain Connectivity

```powershell
# Test DNS resolution
Resolve-DnsName corp.alldata.net

# Test domain controller connectivity
Test-NetConnection -ComputerName <domain-controller> -Port 389
Test-NetConnection -ComputerName <domain-controller> -Port 445
```

### Test 3: Verify Domain Authentication

```powershell
# Test domain user login
$credential = Get-Credential -UserName "CORP\username" -Message "Enter domain password"
Test-ComputerSecureChannel -Credential $credential
```

### Test 4: Verify Secrets Manager Access

```powershell
# Verify instance can access domain secrets
aws secretsmanager get-secret-value \
  --secret-id BreadDomainSecret-CORPDEV \
  --region us-east-2 \
  --query SecretString --output text
```

**Expected**: Should return domain join credentials.

### Test 5: Verify CAST Application Prerequisites

```powershell
# Check Windows features
Get-WindowsFeature | Where-Object {$_.InstallState -eq "Installed"}

# Check network connectivity to CAST resources
Test-NetConnection castsoftware.com -Port 443
```

---

## 7. Suggested Terraform Changes

### Change 1: Update Domain Join User Data

**File**: `cast.tfvars.MVP2`

**Current**:
```hcl
domain_join_user_data = ""
# domain_join_user_data = "brd26w080n1,dev"
```

**Change To**:
```hcl
domain_join_user_data = "brd26w080n1,dev"
```

**Rationale**: This enables the domain join script in the AMI to execute and join the instance to the domain.

### Change 2: Verify Hostname Availability

**Action**: Before applying, verify in Active Directory that hostname `brd26w080n1` is:
- Not already in use
- Available for computer account creation
- Follows naming conventions

**Command to Check** (from a domain-joined machine):
```powershell
Get-ADComputer -Filter "Name -eq 'brd26w080n1'"
```

---

## 8. Deployment Steps

### Step 1: Update Terraform Configuration

```bash
cd /Users/a805120/develop/organization_repositories/aws_bfh_infrastructure/components/terraform/cast

# Edit cast.tfvars.MVP2
# Change: domain_join_user_data = "brd26w080n1,dev"
```

### Step 2: Plan the Changes

```bash
terraform plan -var-file="cast.tfvars.MVP2"
```

**Expected Changes**:
- User data will be updated on the instance
- Instance will restart (if user data requires reboot)

### Step 3: Apply Changes

```bash
terraform apply -var-file="cast.tfvars.MVP2"
```

**Note**: This will update the instance's user data. The domain join script will execute on the next boot.

### Step 4: Monitor Domain Join

```bash
# Connect via SSM to monitor domain join process
aws ssm start-session --target i-0565d268ae24eff7a \
  --profile CASTSoftware_dev_925774240130_admin \
  --region us-east-2

# Check user data execution logs
Get-Content C:\Program Files\Amazon\EC2Launch\log\agent.log -Tail 50

# Check domain join status
Get-ComputerInfo | Select-Object CsDomain, CsDomainRole
```

### Step 5: Verify Domain Join Success

```bash
# Connect and verify
aws ssm start-session --target i-0565d268ae24eff7a \
  --profile CASTSoftware_dev_925774240130_admin \
  --region us-east-2

# In PowerShell:
Get-ComputerInfo | Select-Object CsDomain, CsDomainRole, CsName
```

**Expected**: `CsDomain = "CORP.ALLDATA.NET"`

---

## 9. Troubleshooting

### Issue: Domain Join Fails

**Check**:
1. Verify user data was set correctly: `Get-EC2InstanceAttribute --instance-id i-0565d268ae24eff7a --attribute userData`
2. Check instance logs: `C:\Program Files\Amazon\EC2Launch\log\agent.log`
3. Verify secrets access: Test from instance via AWS CLI
4. Verify network connectivity to domain controllers
5. Check DNS resolution for `corp.alldata.net`

### Issue: Cannot Access Secrets

**Check**:
1. Verify IAM role has secrets policy attached
2. Verify instance profile is attached to instance
3. Test cross-account access from instance:
   ```powershell
   aws secretsmanager get-secret-value --secret-id BreadDomainSecret-CORPDEV --region us-east-2
   ```

### Issue: Cannot Connect via RDP

**Check**:
1. Verify security group allows RDP (3389) from your IP
2. Verify instance is in running state
3. Use SSM Session Manager as alternative access method
4. Check Windows Firewall rules on instance

### Issue: Cannot Connect via SSM

**Check**:
1. Verify `AmazonSSMManagedInstanceCore` policy is attached
2. Verify instance profile is attached to instance
3. Verify SSM agent is running: `Get-Service AmazonSSMAgent`
4. Check SSM agent logs: `C:\ProgramData\Amazon\SSM\Logs\amazon-ssm-agent.log`

---

## 10. Summary

### ✅ Infrastructure Status: GOOD

All infrastructure components are correctly configured:
- Instance is running
- Instance profile is attached
- IAM policies are correct
- Cross-account secrets access is configured
- Security groups are properly configured
- Network configuration is correct

### ⚠️ Domain Join Status: NOT CONFIGURED

**Action Required**: Update `domain_join_user_data` in `cast.tfvars.MVP2`:
```hcl
domain_join_user_data = "brd26w080n1,dev"
```

Then apply the Terraform changes to enable domain join.

### 🔐 Access Methods Available

1. **SSM Session Manager** (Recommended) - No VPN required
2. **RDP via VPN** - Direct connection when on corporate network
3. **RDP via SSM Port Forwarding** - Tunnel RDP through SSM

### 👤 Admin Access

- **Before Domain Join**: Local `Administrator` account
- **After Domain Join**: Domain users (`CORP\username`) and domain admins

---

## Appendix: AWS CLI Commands Reference

### Check Instance Status
```bash
aws ec2 describe-instances \
  --instance-ids i-0565d268ae24eff7a \
  --profile CASTSoftware_dev_925774240130_admin \
  --region us-east-2 \
  --query 'Reservations[0].Instances[0].[InstanceId,State.Name,IamInstanceProfile.Arn,PrivateIpAddress]'
```

### Connect via SSM
```bash
aws ssm start-session \
  --target i-0565d268ae24eff7a \
  --profile CASTSoftware_dev_925774240130_admin \
  --region us-east-2
```

### Check Domain Join Status (via SSM)
```bash
aws ssm send-command \
  --instance-ids i-0565d268ae24eff7a \
  --profile CASTSoftware_dev_925774240130_admin \
  --region us-east-2 \
  --document-name "AWS-RunPowerShellScript" \
  --parameters 'commands=["Get-ComputerInfo | Select-Object CsDomain, CsDomainRole"]'
```

### Get SSH Private Key
```bash
aws secretsmanager get-secret-value \
  --secret-id cast-ssh-key-dev \
  --profile CASTSoftware_dev_925774240130_admin \
  --region us-east-2 \
  --query SecretString --output text > ~/.ssh/cast-dev-key.pem
```

---

**Report Generated**: 2025-01-26  
**Next Steps**: Update `cast.tfvars.MVP2` and apply Terraform changes to enable domain join.
