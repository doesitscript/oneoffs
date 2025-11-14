# AWS Access Research Documentation

## Overview
This directory contains research documentation and screenshots from investigating AWS account access, IAM Identity Center configuration, and SailPoint integration at Bread Financial.

## Research Date
November 14, 2025

## Research Folders

### 1. [account-navigation](./account-navigation/)
Documentation of the AWS account navigation flow through Okta SSO.

**Key Findings**:
- 98 AWS accounts accessible via Okta SSO
- Account structure and naming conventions
- Navigation flow from Okta to AWS Console
- Permission set patterns (e.g., `admin-v20250516`)

**Screenshots**: 4 files
- AWS Console home page
- Account switcher interface
- Full Okta account list
- Expanded account view with roles

### 2. [identity-center-investigation](./identity-center-investigation/)
Deep dive into IAM Identity Center configuration and SailPoint integration.

**Key Findings**:
- **Identity Source**: External IdP (Okta)
- **Authentication**: SAML 2.0
- **Provisioning**: SCIM v2.0
- **Architecture**: SailPoint → Okta → AWS IAM Identity Center

**Screenshots**: 4 files
- IAM Identity Center dashboard
- Identity source configuration
- SCIM provisioning details
- Okta applications (SailPoint + AWS)

## Critical Discovery

### The Complete Integration Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    SailPoint                            │
│           Identity Security Cloud                       │
│         (Identity Governance Platform)                  │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ Manages access requests,
                     │ approvals, and provisioning
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                       Okta                              │
│              (Identity Provider)                        │
│                                                         │
│  • Receives user/group provisioning from SailPoint      │
│  • Manages user identities                             │
│  • Provides SAML authentication to AWS                 │
│  • Syncs users/groups to AWS via SCIM                  │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ SCIM v2.0 Protocol
                     │ (Automatic Provisioning)
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              AWS IAM Identity Center                    │
│                 (Account: 717279730613)                 │
│                                                         │
│  • SCIM Endpoint: https://scim.us-east-2.amazonaws...  │
│  • Identity Store ID: d-9a6763d7d3                     │
│  • Manages 98 AWS accounts                             │
│  • Controls access via groups and permission sets      │
└─────────────────────────────────────────────────────────┘
```

## How Group Population Works

### Problem Statement
The group `App-AWS-AA-database-sandbox-941677815499-admin` exists in IAM Identity Center but has **zero members**.

### Solution Flow

**Step 1: In SailPoint**
- Create access profile/entitlement for AWS database-sandbox admin access
- Users request access through SailPoint
- Access request goes through approval workflow
- Upon approval, SailPoint provisions user to Okta

**Step 2: In Okta (Automatic)**
- Okta receives provisioning request from SailPoint
- Okta adds user to corresponding group
- Okta's SCIM client automatically syncs group membership to AWS

**Step 3: In AWS IAM Identity Center (Automatic)**
- SCIM endpoint receives group membership update
- User is added to `App-AWS-AA-database-sandbox-941677815499-admin`
- User can now access database-sandbox account with admin permissions

### No Manual Steps Required in AWS
Once SailPoint and Okta are configured:
1. All provisioning happens automatically via SCIM
2. No need to manually add users in AWS Console
3. Changes in SailPoint propagate automatically to AWS

## Technical Details

### IAM Identity Center Configuration
- **Instance ARN**: `arn:aws:sso:::instance/ssoins-6684b61b096c0add`
- **Identity Store ID**: `d-9a6763d7d3`
- **Region**: us-east-2
- **Organization ID**: `o-6wrht8pxbo`
- **AWS Access Portal**: https://d-9a6763d7d3.awsapps.com/start

### SCIM Configuration
- **Endpoint**: `https://scim.us-east-2.amazonaws.com/Hw554936506-e755-4811-8646-adb52f76906a/scim/v2`
- **Status**: Enabled
- **Protocol**: SCIM v2.0
- **Active Tokens**: 1 (expires 3/7/2026)

### Authentication
- **Method**: SAML 2.0
- **IdP**: Okta (okta.breadfinancial.net)
- **Issuer URL**: `https://identitycenter.amazonaws.com/ssoins-6684b61b096c0add`

## Account Statistics

- **Total AWS Accounts**: 98
- **Identity Center Account**: 717279730613
- **Example Target Account**: database-sandbox (941677815499)
- **Group Naming Pattern**: `App-AWS-AA-{account-name}-{account-id}-{permission}`

## Answer to Original Questions

### Q: How is the identity source configured?
**A**: External Identity Provider (Okta) with SAML 2.0 authentication and SCIM v2.0 provisioning.

### Q: How does SailPoint populate IAM Identity Center groups?
**A**: 
1. SailPoint manages access governance and approvals
2. SailPoint provisions users to Okta groups
3. Okta automatically syncs to AWS IAM Identity Center via SCIM
4. IAM Identity Center updates group memberships automatically

### Q: Why is the database-sandbox admin group empty?
**A**: Because no users have been assigned the corresponding access in SailPoint. Once users are assigned in SailPoint, they will automatically appear in the AWS group via SCIM sync.

## Next Steps

To populate the `App-AWS-AA-database-sandbox-941677815499-admin` group:

1. **SailPoint Configuration** (Primary Action Required):
   - Verify SailPoint has AWS access profiles configured
   - Create/update access profile for database-sandbox admin access
   - Assign users through SailPoint request/approval process

2. **Okta Verification** (Should be automatic):
   - Verify Okta receives provisioning from SailPoint
   - Verify Okta group mapping exists for AWS groups
   - Confirm SCIM sync is functioning

3. **AWS Verification** (Automatic):
   - Monitor group membership via CLI or Console
   - Verify users appear in group after SailPoint assignment
   - Test user access to database-sandbox account

## Files and Folders

```
research/
├── README.md (this file)
├── account-navigation/
│   ├── README.md
│   ├── 01_identity_account_console_home.png
│   ├── 02_account_menu_dropdown.png
│   ├── 03_okta_aws_account_list_full.png
│   └── 04_database_sandbox_account_expanded.png
└── identity-center-investigation/
    ├── README.md
    ├── 05_iam_identity_center_dashboard.png
    ├── 06_identity_source_configuration_SCIM.png
    ├── 07_scim_automatic_provisioning_config.png
    └── 08_okta_apps_sailpoint_and_aws_identity_center.png
```

## Related Files

- `../SailPoint Integration with AWS IAM Groups` - Full conversation transcript
- `../compare_ad_groups.py` - Python script for comparing AD/YAML groups

## Key Contacts

- **AWS Account Management**: Identity Center (717279730613)
- **SailPoint Administration**: Contact SailPoint admins for access profile setup
- **Okta Administration**: Verify SCIM sync configuration
- **Current User**: josh.castillo@breadfinancial.com (a805120)

## Conclusion

The mystery is solved! The identity provider is **Okta**, using **SCIM** to automatically provision users and groups to AWS IAM Identity Center. **SailPoint** manages the governance layer on top of Okta. To populate the empty group, work with SailPoint administrators to create access profiles and assign users - the rest happens automatically through the SCIM integration.