# CAST Pre-Deployment Checklist

## Quick Pre-Deployment Checks

### 🔴 **CRITICAL - Domain Join Blockers**
These issues will prevent the machine from joining the domain:

1. **Cross-Account Secrets Access** # This will block domain join if secrets aren't accessible
   ```bash
   aws secretsmanager list-secrets --profile SharedServices_imagemanagement_422228628991_admin --query 'SecretList[?contains(Name, `BreadDomainSecret-CORP`)]'
   ```
   - [ ] Account `422228628991` is accessible
   - [ ] Secrets matching `BreadDomainSecret-CORP*` exist
   - [ ] Cross-account permissions are configured

2. **Domain Join User Data** # Wrong user data will block domain join
   - [ ] Verify `domain_join_user_data = "brd26w080n1,dev"` is correct
   - [ ] Confirm hostname `brd26w080n1` is available
   - [ ] Environment `dev` matches your deployment

3. **Instance Profile Permissions** # Missing permissions will block domain join
   - [ ] Instance profile is attached to EC2 instance
   - [ ] Secrets access policy is attached to the role
   - [ ] SSM Core policy is attached (for remote access)

### 🟡 **Important - Deployment Issues**
These won't block domain join but will cause deployment problems:

4. **Terraform Configuration**
   - [ ] Using correct tfvars file: `cast.tfvars.MVP2`
   - [ ] `var.env` is set to "dev" (not an environment variable)
   - [ ] All hardcoded "Production" references are fixed

5. **AWS Account Access**
   - [ ] Profile `CASTSoftware_dev_925774240130_admin` is configured
   - [ ] Region `us-east-2` is correct
   - [ ] Account `925774240130` is accessible

6. **Resource Naming**
   - [ ] No naming conflicts with existing resources
   - [ ] Instance profile name: `cast-profile-dev-us-east-2`
   - [ ] IAM role name: `cast-role-dev-us-east-2`

7. **Network Configuration**
   - [ ] VPC with tag `Name = "cast*"` exists
   - [ ] Subnets are available in the VPC
   - [ ] Security group allows RDP (port 3389) and HTTPS (port 443)

### 🟢 **Nice to Have - Operational**
These are good to check but won't block deployment:

8. **Instance Specifications**
   - [ ] Instance type `m5.8xlarge` is appropriate
   - [ ] Root volume 250GB is sufficient
   - [ ] Data volume 500GB (io2) is configured correctly

9. **Monitoring & Logging**
   - [ ] CloudWatch Logs policy is attached
   - [ ] Log group naming follows pattern `/aws/cast/*`

## Quick Commands to Run

```bash
# 1. Check cross-account access (CRITICAL for domain join)
aws secretsmanager list-secrets --profile SharedServices_imagemanagement_422228628991_admin

# 2. Verify Terraform variables
terraform console
> var.env
> var.name_prefix

# 3. Check for naming conflicts
aws iam list-instance-profiles --query 'InstanceProfiles[?contains(InstanceProfileName, `cast-profile-dev`)]'

# 4. Verify VPC exists
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=cast*"

# 5. Test deployment plan
terraform plan -var-file="cast.tfvars.MVP2"
```

## Deployment Command

```bash
# Deploy with the correct tfvars file
terraform apply -var-file="cast.tfvars.MVP2"
```

## Post-Deployment Domain Join Check

After deployment, verify domain join worked:
```bash
# Connect to instance via SSM
aws ssm start-session --target <instance-id>

# Check domain membership (from within the instance)
Get-ComputerInfo | Select-Object CsDomain, CsDomainRole
```

---

**Note**: Items marked with # are critical for domain join functionality. If any of these fail, the machine won't be able to join the domain and CAST won't work properly.



