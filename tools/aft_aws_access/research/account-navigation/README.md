# Account Navigation Research

## Overview
This folder contains screenshots documenting the AWS account navigation flow through Okta SSO and AWS Console.

## Date
November 14, 2025

## Investigation Scope
- Okta AWS SSO account switcher interface
- AWS Console account navigation
- Multi-account access patterns

## Key Findings

### 1. AWS Organization Structure
- **Total AWS Accounts**: 98 accounts
- **Identity Center Account**: 717279730613
- **Organization ID**: o-6wrht8pxbo
- **AWS Access Portal**: https://d-9a6763d7d3.awsapps.com/start

### 2. Account Access Method
Users access AWS accounts through Okta SSO:
1. Navigate to Okta AWS SSO page
2. Select desired AWS account from list
3. Account expands to show available permission sets/roles
4. Click on role (e.g., "admin-v20250516") to access account
5. Alternative: Click "Access keys" for programmatic access

### 3. Example Account Structure

**Database Sandbox Account**:
- **Account Name**: database-sandbox
- **Account ID**: 941677815499
- **Email**: AwsAccount+database-sandbox@breadfinancial.com
- **Available Role**: admin-v20250516
- **IAM Identity Center Group**: App-AWS-AA-database-sandbox-941677815499-admin

### 4. Account Categories Observed

**Infrastructure Accounts**:
- Network Hub (207567762220)
- CloudOperations (920411896753)
- InfrastructureSharedServices (185869891420)
- InfrastructureObservabilityDev (836217041434)

**Security Accounts**:
- Security Tooling (794038215373)
- Secrets-Management (556180171418)
- Audit (825765384428)

**SDLC Environments** (DEV, QA, UAT, SIT):
- SDLC-DEV-* (multiple applications)
- SDLC-QA-* (multiple applications)
- SDLC-UAT-* (multiple applications)
- SDLC-SIT-* (limited applications)

**Specialized Accounts**:
- Confluent (dev, nonprod, prod)
- RPA (dev, uat, prd)
- Sectigo (dev, qa, prd)
- StrongDM (967660016041)
- SailPoint ISC (dev, prd)

**Central Services**:
- Identity Center (717279730613) - Management Account
- Log Archive (463470955493)
- Central Backup Vault (443370695612)
- Central KMS Vault (976193251493)

## Navigation Flow

### Step 1: Access Okta AWS SSO
**URL**: https://okta.breadfinancial.net/home/amazon_aws_sso/0oa15fxkqtbrxtxjQ1t8/aln1ghfn5xxV7ZPbE1d8

**Screenshot**: `03_okta_aws_account_list_full.png`
- Shows all 98 available AWS accounts
- Searchable interface
- Accounts listed alphabetically

### Step 2: Expand Account
**Screenshot**: `04_database_sandbox_account_expanded.png`
- Click on account name to expand
- Shows available permission sets
- Shows "Access keys" option for programmatic access

### Step 3: Access Console
- Click on permission set name (e.g., "admin-v20250516")
- Federated login to AWS Console
- Lands in selected account

### Step 4: In AWS Console
**Screenshot**: `01_identity_account_console_home.png`
- Shows Console Home dashboard
- Account ID visible in top-right corner
- Can use account switcher to change accounts

**Screenshot**: `02_account_menu_dropdown.png`
- Account menu shows current account details
- Displays user/role information
- Options: Account, Organization, Service Quotas, Billing, Sign out

## Account Naming Convention

All accounts follow the pattern:
```
{AccountName} {AccountID} | AwsAccount+{accountname}@breadfinancial.com
```

Examples:
- database-sandbox 941677815499 | AwsAccount+database-sandbox@breadfinancial.com
- Identity Center 717279730613 | AwsAccount+IdentityCenter@breadfinancial.com
- Security Tooling 794038215373 | AwsAccount+SecurityTooling@breadfinancial.com

## Permission Set Pattern

Most accounts use: `admin-v20250516`
- Version-dated permission sets
- Likely created/updated May 16, 2025
- Provides administrative access to single account

## IAM Identity Center Group Pattern

Groups follow the naming convention:
```
App-AWS-AA-{account-name}-{account-id}-{permission-level}
```

Examples:
- `App-AWS-AA-database-sandbox-941677815499-admin`
- `App-AWS-AA-Security-Tooling-794038215373-admin`
- `App-AWS-AA-global-reader` (special global access)
- `App-AWS-AA-global-viewer` (special global access)

## Account Access Matrix

| Account Type | Environment | Count | Example |
|--------------|-------------|-------|---------|
| SDLC Apps | DEV | ~15 | SDLC-DEV-EasyPay |
| SDLC Apps | QA | ~15 | SDLC-QA-EasyPay |
| SDLC Apps | UAT | ~15 | SDLC-UAT-EasyPay |
| SDLC Apps | SIT | ~3 | SDLC-SIT-EasyPay |
| Infrastructure | N/A | ~10 | InfrastructureSharedServices |
| Security | N/A | ~5 | Security Tooling, Audit |
| Central Services | N/A | ~8 | Identity Center, Log Archive |
| Specialized | Various | ~27 | Confluent, RPA, SailPoint |

## Screenshots

1. **01_identity_account_console_home.png** - AWS Console home page for Identity Center account
2. **02_account_menu_dropdown.png** - Account switcher dropdown showing current account details
3. **03_okta_aws_account_list_full.png** - Full list of 98 AWS accounts in Okta SSO
4. **04_database_sandbox_account_expanded.png** - Expanded view showing permission sets for database-sandbox account

## User Journey

```
Okta Dashboard
    ↓
Click "AWS IAM Identity Center" app
    ↓
AWS Access Portal (https://d-9a6763d7d3.awsapps.com/start)
    ↓
View 98 available accounts
    ↓
Click on "database-sandbox"
    ↓
Expand to see: admin-v20250516 | Access keys
    ↓
Click "admin-v20250516"
    ↓
Federated login via SAML
    ↓
AWS Console for database-sandbox account (941677815499)
```

## Notes

- All accounts accessible through single Okta SSO integration
- Permission sets are version-controlled (e.g., v20250516)
- Each account has dedicated IAM Identity Center group for access control
- Access keys option allows CLI/SDK access without console login
- Account switcher allows quick navigation between accounts
- Current user: josh.castillo@breadfinancial.com (a805120)

## Related Documentation

See also: `../identity-center-investigation/` for details on:
- How IAM Identity Center is configured
- SCIM provisioning from Okta
- SailPoint integration
- Group membership management