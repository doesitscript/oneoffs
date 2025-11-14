# Identity Center Investigation Research

## Overview
This folder contains screenshots and documentation from investigating how IAM Identity Center is configured and how SailPoint integrates with AWS for user/group provisioning.

## Date
November 14, 2025

## Investigation Scope
- IAM Identity Center configuration in AWS Account 717279730613
- Identity source and provisioning method discovery
- SailPoint integration confirmation

## Key Findings

### 1. Identity Source Configuration
**Screenshot**: `06_identity_source_configuration_SCIM.png`

- **Identity Source**: External identity provider (Okta)
- **Authentication Method**: SAML 2.0
- **Provisioning Method**: **SCIM** (System for Cross-domain Identity Management)
- **Identity Store ID**: `d-9a6763d7d3`
- **AWS Access Portal URL**: `https://d-9a6763d7d3.awsapps.com/start`

### 2. SCIM Automatic Provisioning Details
**Screenshot**: `07_scim_automatic_provisioning_config.png`

- **SCIM Endpoint**: `https://scim.us-east-2.amazonaws.com/Hw554936506-e755-4811-8646-adb52f76906a/scim/v2`
- **Status**: Enabled
- **Active Access Tokens**: 1 token (Token ID: `78f3b96c-ba48-44ca-88da-1e7b2ac73e7b`)
- **Token Created**: 3/7/2025
- **Token Expires**: 3/7/2026

### 3. Okta Applications Discovered
**Screenshot**: `08_okta_apps_sailpoint_and_aws_identity_center.png`

Two critical applications found in Okta:
1. **AWS IAM Identity Center** - SCIM provider for AWS
2. **SailPoint Identity Security Cloud** - Identity Governance platform

## Architecture Discovered

```
┌─────────────────────┐
│    SailPoint        │
│  Identity Security  │
│      Cloud          │
└──────────┬──────────┘
           │
           │ (Manages)
           ▼
┌─────────────────────┐      SCIM v2.0        ┌──────────────────────┐
│        Okta         │─────Provisioning─────>│  AWS IAM Identity    │
│  (Identity Provider)│      Protocol         │      Center          │
│                     │                       │   (717279730613)     │
└─────────────────────┘                       └──────────────────────┘
           │
           │ SAML 2.0
           │ (Authentication)
           ▼
      User Login
```

## How It Works

### User/Group Provisioning Flow:

1. **SailPoint** manages user access requests and approvals
2. **SailPoint** provisions users/groups to **Okta** (via Okta API)
3. **Okta** syncs users/groups to **AWS IAM Identity Center** via **SCIM API**
4. IAM Identity Center creates/updates users and group memberships
5. Users authenticate via **SAML 2.0** from Okta to AWS

### Authentication Flow:

1. User accesses AWS Access Portal: `https://d-9a6763d7d3.awsapps.com/start`
2. Redirected to Okta for SAML authentication
3. User logs in with Okta credentials
4. Okta returns SAML assertion to AWS
5. User gains access to assigned AWS accounts and permission sets

## Answer to Original Question

**Question**: "Since I can't access the console directly, how is the identity source configured and how does SailPoint populate groups?"

**Answer**: 
- **Identity Source**: External IdP (Okta) using SAML 2.0 for authentication
- **Provisioning**: SCIM protocol from Okta to AWS IAM Identity Center
- **SailPoint Role**: SailPoint manages user access in Okta, and Okta automatically syncs to AWS via SCIM

## To Populate the `App-AWS-AA-database-sandbox-941677815499-admin` Group:

1. **In SailPoint**:
   - Create/assign users to the access profile for this AWS group
   - SailPoint provisions users to the corresponding Okta group

2. **In Okta** (automatic):
   - Okta receives the group membership from SailPoint
   - Okta's SCIM client automatically provisions the group membership to AWS IAM Identity Center

3. **In AWS IAM Identity Center** (automatic):
   - SCIM endpoint receives the group membership update
   - User is added to group `App-AWS-AA-database-sandbox-941677815499-admin`
   - User can now access the database-sandbox account with admin permissions

## Screenshots

1. **05_iam_identity_center_dashboard.png** - Main IAM Identity Center dashboard showing settings summary
2. **06_identity_source_configuration_SCIM.png** - Identity source details showing SAML + SCIM configuration
3. **07_scim_automatic_provisioning_config.png** - SCIM endpoint and access token details
4. **08_okta_apps_sailpoint_and_aws_identity_center.png** - Okta apps showing both SailPoint and AWS integrations

## Next Steps

To enable users in the empty group:
1. Contact SailPoint administrators to create access profiles for AWS groups
2. Verify Okta group mapping is configured correctly
3. Assign users in SailPoint - they will automatically sync via SCIM
4. Verify group membership appears in AWS IAM Identity Center (group ID: `711bf5c0-b071-70c1-06da-35d7fbcac52d`)

## References

- AWS IAM Identity Center Instance: `ssoins-6684b61b096c0add`
- Identity Store: `d-9a6763d7d3`
- Organization ID: `o-6wrht8pxbo`
- Region: us-east-2