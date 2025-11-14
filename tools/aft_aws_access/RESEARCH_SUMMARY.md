# AWS IAM Identity Center & SailPoint Integration - Research Summary

**Date:** November 14, 2025  
**Researcher:** AI Assistant (via Playwright browser automation)  
**Account:** Bread Financial AWS Organization  
**Primary User:** josh.castillo@breadfinancial.com (a805120)

---

## Executive Summary

Successfully identified the complete identity and access management architecture for Bread Financial's AWS environment. The investigation revealed a three-tier integration: **SailPoint → Okta → AWS IAM Identity Center**, utilizing SCIM v2.0 for automatic user/group provisioning.

## 🎯 Primary Finding

**The identity provider is Okta, NOT Active Directory directly.**

The integration architecture:
```
SailPoint Identity Security Cloud
        ↓ (Governance & Provisioning)
      Okta
        ↓ (SCIM v2.0 Automatic Sync)
AWS IAM Identity Center
```

## 🔑 Key Discoveries

### 1. Identity Source Configuration
- **Provider:** External Identity Provider (Okta)
- **Authentication:** SAML 2.0
- **Provisioning Method:** SCIM v2.0 (System for Cross-domain Identity Management)
- **Identity Store ID:** d-9a6763d7d3
- **Instance ARN:** arn:aws:sso:::instance/ssoins-6684b61b096c0add

### 2. SCIM Integration Details
- **SCIM Endpoint:** https://scim.us-east-2.amazonaws.com/Hw554936506-e755-4811-8646-adb52f76906a/scim/v2
- **Status:** Enabled
- **Active Token:** 78f3b96c-ba48-44ca-88da-1e7b2ac73e7b
- **Token Expiry:** March 7, 2026

### 3. Organization Structure
- **Total AWS Accounts:** 98
- **Identity Center Account:** 717279730613
- **Organization ID:** o-6wrht8pxbo
- **Region:** us-east-2
- **Access Portal:** https://d-9a6763d7d3.awsapps.com/start

### 4. Applications in Okta
Two critical applications discovered:
1. **AWS IAM Identity Center** - SCIM provider for AWS access
2. **SailPoint Identity Security Cloud** - Identity governance platform

## 📋 Original Problem

**Group:** `App-AWS-AA-database-sandbox-941677815499-admin`  
**Status:** Exists in IAM Identity Center but has **0 members**  
**Goal:** Understand how to populate this group via SailPoint

## ✅ Solution

### How to Populate IAM Identity Center Groups:

**Step 1: SailPoint (Primary Action Required)**
- Create/configure access profile for AWS database-sandbox admin access
- Users submit access requests through SailPoint
- Approval workflow processes requests
- SailPoint provisions approved users to Okta

**Step 2: Okta (Automatic)**
- Receives provisioning from SailPoint
- Adds user to corresponding Okta group
- SCIM client automatically syncs to AWS IAM Identity Center

**Step 3: AWS IAM Identity Center (Automatic)**
- SCIM endpoint receives group membership update
- User added to `App-AWS-AA-database-sandbox-941677815499-admin`
- User gains access to database-sandbox (941677815499) with admin permissions

### ⚠️ Important: NO Manual Steps in AWS Required

Once SailPoint and Okta are properly configured:
- All provisioning is automatic via SCIM
- No manual user addition in AWS Console needed
- Changes propagate within minutes

## 🏗️ Complete Architecture Flow

### User Provisioning:
```
1. User requests access in SailPoint
        ↓
2. Manager/Security approves in SailPoint
        ↓
3. SailPoint provisions user to Okta group
        ↓
4. Okta SCIM client syncs to AWS (automatic)
        ↓
5. AWS IAM Identity Center adds user to group
        ↓
6. User can access AWS account via Okta SSO
```

### User Authentication:
```
1. User navigates to https://d-9a6763d7d3.awsapps.com/start
        ↓
2. Redirected to Okta for SAML authentication
        ↓
3. User enters Okta credentials
        ↓
4. Okta sends SAML assertion to AWS
        ↓
5. User accesses assigned AWS accounts/roles
```

## 📊 Group Naming Convention

All IAM Identity Center groups follow this pattern:
```
App-AWS-AA-{account-name}-{account-id}-{permission-level}
```

Examples:
- `App-AWS-AA-database-sandbox-941677815499-admin`
- `App-AWS-AA-Security-Tooling-794038215373-admin`
- `App-AWS-AA-global-reader` (special cross-account access)

## 🔧 Implementation Steps

To enable access for the database-sandbox admin group:

### 1. SailPoint Configuration
```
Action: Contact SailPoint administrators
Task: Create AWS access profile for database-sandbox admin
Details:
  - Profile Name: AWS Database Sandbox Admin
  - Target: Okta group (mapped to AWS group)
  - Assignment: Based on role, department, or manual
```

### 2. Okta Configuration (Verify)
```
Action: Verify with Okta administrators
Check:
  - SCIM sync to AWS is enabled
  - Group mapping exists for AWS groups
  - No sync filters blocking the group
  - Token is valid (expires 3/7/2026)
```

### 3. AWS Verification (Monitor)
```
Command: aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d

Expected: User IDs should appear after SailPoint assignment
```

## 📸 Documentation

All research evidence stored in `research/` directory:

**account-navigation/** (4 screenshots):
- AWS Console interfaces
- Account switcher views
- Okta account list (all 98 accounts)
- Expanded account with roles

**identity-center-investigation/** (4 screenshots):
- IAM Identity Center dashboard
- Identity source configuration (SAML + SCIM)
- SCIM provisioning details
- Okta applications (SailPoint + AWS)

Each folder contains detailed README files with technical specifications.

## 🎓 Key Learnings

1. **No Active Directory Sync to AWS:** Despite AD groups existing, AWS uses Okta as the identity source
2. **SCIM is Automatic:** Once configured, user/group changes sync automatically
3. **SailPoint is the Governance Layer:** Access requests, approvals, and lifecycle management
4. **Okta is the Identity Broker:** Connects SailPoint governance to AWS access
5. **IAM Identity Center Groups are Auto-Created:** Groups exist but need SCIM to populate members

## 🚀 Next Steps

**Immediate Actions:**
1. Contact SailPoint team to create AWS access profiles
2. Map access profiles to corresponding Okta groups
3. Define approval workflows for AWS access requests
4. Test end-to-end flow with pilot user

**Ongoing Monitoring:**
1. Monitor SCIM sync logs for errors
2. Verify token renewal before 3/7/2026
3. Audit group memberships regularly
4. Document access request procedures

## 📞 Key Contacts

- **SailPoint Administration:** Configure access profiles and workflows
- **Okta Administration:** Verify SCIM configuration and group mappings
- **AWS IAM Identity Center:** Account 717279730613 (Identity management)
- **Current Investigation User:** josh.castillo@breadfinancial.com

## 🔗 Related Files

- `research/README.md` - Detailed research documentation
- `research/account-navigation/README.md` - Account access flow
- `research/identity-center-investigation/README.md` - Identity source deep dive
- `SailPoint Integration with AWS IAM Groups` - Original conversation transcript
- `compare_ad_groups.py` - Python tool for group comparison

## ✨ Conclusion

The mystery is solved! The empty IAM Identity Center group exists because no users have been assigned through SailPoint. The solution is to work with SailPoint administrators to create access profiles and assign users. Once that's done, SCIM will automatically sync the memberships to AWS IAM Identity Center - no manual AWS configuration required.

**Critical Insight:** This is a governance problem, not a technical AWS problem. Focus efforts on SailPoint configuration, not AWS configuration.

---

*Research conducted using AWS Console browser automation and Okta SSO interface analysis.*