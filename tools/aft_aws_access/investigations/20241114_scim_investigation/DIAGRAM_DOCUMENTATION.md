# AWS Account Architecture Diagrams - Documentation

**Date:** November 14, 2025  
**Location:** `/Users/a805120/develop/oneoffs/tools/aft_aws_access/diagrams/`  
**Purpose:** Visual documentation of AWS account architecture and provisioning flows

---

## 📊 Diagram Index

| # | Diagram | Purpose | Key Insights |
|---|---------|---------|--------------|
| 1 | `log_archive_account.png` | Log Archive account architecture | Centralized logging for all accounts |
| 2 | `bfh_mgmt_account.png` | bfh_mgmt account with SailPoint | **ONLY working automated provisioning** |
| 3 | `database_sandbox_account.png` | database_sandbox account status | Empty groups, no automation |
| 4 | `multi_account_integration.png` | How all accounts work together | Shared Identity Store integration |
| 5 | `sailpoint_flow_comparison.png` | Working vs Broken provisioning | Direct vs SCIM comparison |
| 6 | `complete_environment_usage.png` | Complete environment lifecycle | Full organizational flow |
| 7 | `identity_center_architecture.png` | IAM Identity Center details | Shared identity architecture |
| 8 | `cloudtrail_evidence_patterns.png` | CloudTrail event analysis | Evidence-based findings |

---

## 🏢 Individual Account Diagrams

### 1. Log Archive Account (463470955493)

**File:** `log_archive_account.png`

**Architecture:**
```
User → IAM Identity Center → AWSLogArchiveViewers Group → S3 Central Logs
                                                              ↓
CloudTrail/CloudWatch/Config → S3 Central Logs → S3 Glacier Archive
                                     ↑
                                   KMS Encryption
```

**Key Components:**
- **IAM Identity Center:** SSO access with AWSLogArchiveViewers group
- **S3 Central Logs:** Primary storage for all organization CloudTrail logs
- **S3 Glacier:** Long-term archival (90+ days)
- **KMS:** Encryption keys for log security
- **CloudTrail/CloudWatch/Config:** Log sources from all accounts

**Purpose:**
- Centralized log storage for all 88 AWS accounts
- Security compliance and audit trail
- Read-only access for log viewers
- Automated lifecycle management (hot → cold storage)

**Inferred Usage:**
1. All accounts send CloudTrail logs here
2. Security team uses AWSLogArchiveViewers for investigations
3. Logs automatically archive to Glacier after retention period
4. KMS encryption ensures log integrity and security

---

### 2. bfh_mgmt Account (739275453939)

**File:** `bfh_mgmt_account.png`

**Architecture:**
```
User Request → SailPoint → AWS SDK (Go) → sailpoint-read-write IAM Role
                                              ↓
                                          IAM Identity Center (d-9a6763d7d3)
                                              ↓
                                          Groups → Users → Resources
                                              ↓
                                          CloudTrail (50 events/7 days)
```

**Key Components:**
- **sailpoint-read-write IAM Role:** Automated provisioning role
- **sailpoint-read-only IAM Role:** Monitoring/read-only access
- **IAM Identity Center:** Shared identity store (d-9a6763d7d3)
- **Groups:** Automatically managed by SailPoint
- **CloudTrail:** 50 CreateGroupMembership events in 7 days

**Critical Discovery:**
🚨 **ONLY account with working automated provisioning!**

**How It Works:**
1. User requests access in SailPoint
2. SailPoint uses AWS SDK for Go to assume `sailpoint-read-write` role
3. Role creates group memberships via IAM Identity Center API
4. Users automatically added to groups
5. CloudTrail logs all operations (evidence: 50 events in 7 days)

**User Agent Pattern:**
```
aws-sdk-go-v2/1.30.4 os/linux lang/go#1.22.7
```

**Why It Works:**
- **Direct integration:** SailPoint → AWS (no Okta middleman)
- **Dedicated IAM role:** Properly scoped permissions
- **Real-time provisioning:** Immediate via AWS API
- **Reliable:** No failures detected in 50 operations

---

### 3. database_sandbox Account (941677815499)

**File:** `database_sandbox_account.png`

**Architecture:**
```
User → IAM Identity Center (d-9a6763d7d3)
           ↓
       App-AWS-AA-database-sandbox-admin (EMPTY)
           ↓
       No SCIM Sync ❌
       No SailPoint Integration ❌
       Manual Only (not being done)
           ↓
       CloudTrail: 0 membership events
```

**Key Components:**
- **IAM Identity Center:** Same shared store as bfh_mgmt (d-9a6763d7d3)
- **Empty Group:** `App-AWS-AA-database-sandbox-941677815499-admin`
- **50+ Other Groups:** Also in the account
- **No Automation:** SCIM broken, SailPoint not configured
- **CloudTrail:** 0 CreateGroupMembership events

**The Problem:**
❌ **No provisioning configured**

**Status Indicators:**
- 🔴 No SCIM Sync detected
- 🔴 No SailPoint direct integration
- 🟡 Manual provisioning possible but not being done
- 📊 CloudTrail: 0 events (no activity)

**Why Group is Empty:**
1. Okta SCIM is broken (not syncing)
2. SailPoint direct integration not set up (unlike bfh_mgmt)
3. No one is manually adding members
4. Group created by AFT during account setup but never populated

**Potential Resources:**
- RDS databases (inferred from account name)
- EC2 instances
- VPC networking

---

## 🔗 Integration Diagrams

### 4. Multi-Account Integration

**File:** `multi_account_integration.png`

**Architecture:**
```
Admin/Users → IAM Identity Center (d-9a6763d7d3) → All Accounts
                                                      ↓
SailPoint → sailpoint-read-write → bfh_mgmt Groups → Resources
                                                      ↓
            (SCIM Broken) → database_sandbox Groups (Empty) → Resources
                                                      ↓
All Resources → CloudTrail → Log Archive → S3 Glacier
```

**Key Insights:**
- **Shared Identity Store:** d-9a6763d7d3 used by all 88 accounts
- **Two Integration Paths:**
  - ✅ Working: SailPoint direct (bfh_mgmt only)
  - ❌ Broken: Okta SCIM (all other accounts)
- **Centralized Logging:** All CloudTrail logs → Log Archive account

**Account Relationships:**
1. All accounts share same IAM Identity Center instance
2. All accounts send logs to Log Archive
3. Only bfh_mgmt has working automated provisioning
4. database_sandbox relies on manual provisioning

---

### 5. SailPoint Flow Comparison

**File:** `sailpoint_flow_comparison.png`

**Side-by-Side Comparison:**

**Working (bfh_mgmt):**
```
User → SailPoint → AWS SDK → sailpoint-read-write Role
                                ↓
                    IAM Identity Center → Group → Member Added ✅
                                ↓
                    CloudTrail: 50 events logged
```

**Broken (database_sandbox):**
```
User → SailPoint → Okta → SCIM (BROKEN) ❌ → IAM Identity Center
                                              ↓
                                          Group (EMPTY) ❌
                                              ↓
                                          CloudTrail: 0 events
```

**Key Differences:**

| Aspect | bfh_mgmt (Working) | database_sandbox (Broken) |
|--------|-------------------|---------------------------|
| **Integration** | Direct AWS SDK | Okta SCIM |
| **Components** | 2 (SailPoint → AWS) | 3 (SailPoint → Okta → AWS) |
| **User Agent** | aws-sdk-go-v2 | None (SCIM fails) |
| **Events** | 50 in 7 days | 0 |
| **Reliability** | 100% success | 0% (broken) |
| **Complexity** | Low | High |

**Why Direct Integration is Better:**
- ✅ Fewer moving parts (no Okta dependency)
- ✅ Real-time API calls
- ✅ Direct CloudTrail evidence
- ✅ More reliable (proven by 50 successful events)

---

### 6. Complete Environment Usage Flow

**File:** `complete_environment_usage.png`

**Full Organizational Flow:**
```
Developer/Admin → SailPoint Governance
                      ↓
        ┌─────────────┴─────────────┐
        ↓                           ↓
    Direct (WORKS)              Okta (BROKEN)
    AWS SDK                     SCIM ❌
        ↓                           ↓
    bfh_mgmt                    database_sandbox
    Groups (50+)                Groups (Empty)
        ↓                           ↓
    Resources                   Resources
        ↓                           ↓
        └───────────┬───────────────┘
                    ↓
            Log Archive Account
            CloudTrail → S3 → Glacier
                    ↓
            CloudWatch + Config
```

**System Components:**

**Identity Management:**
- SailPoint: Governance and access requests
- Okta: IdP (SCIM broken)
- IAM Identity Center: Shared identity (d-9a6763d7d3)

**Account Management:**
- Control Tower: AWS Organization management
- AFT (Account Factory for Terraform): Account provisioning
- Organizations: Account structure

**Shared Services:**
- IAM Identity Center: SSO and identity
- AWS SSO: User authentication

**Monitoring:**
- CloudWatch: Metrics and logs
- AWS Config: Configuration compliance
- CloudTrail: API activity (via Log Archive)

**Inferred Lifecycle:**
1. Control Tower + AFT create new accounts
2. AFT provisions groups during account setup
3. SailPoint manages access requests
4. **Working path:** SailPoint → AWS SDK → Groups (bfh_mgmt)
5. **Broken path:** SailPoint → Okta → SCIM ❌ → Empty groups (others)
6. All activity logged to Log Archive account

---

### 7. IAM Identity Center Architecture

**File:** `identity_center_architecture.png`

**Detailed Identity Center Structure:**
```
Identity Center Account (717279730613)
    ↓
IAM Identity Center Instance
    ├── Identity Store (d-9a6763d7d3)
    │   ├── Users (synced from Okta)
    │   │   ├── user_a805120
    │   │   ├── user_aa836933
    │   │   └── Other Users
    │   └── Groups (86 total)
    │       ├── App-AWS-AA-database-sandbox-admin
    │       ├── App-AWS-AA-bfh-mgmt-admin
    │       ├── global:admin
    │       └── 50+ Other Groups
    ↓
Member Accounts (88 accounts)
    ├── bfh_mgmt (739275453939)
    │   └── Permission Set: admin → AWSReservedSSO_admin Role
    ├── database_sandbox (941677815499)
    │   └── Permission Set: admin → AWSReservedSSO_admin Role
    └── Log Archive (463470955493)
        └── Permission Set: read-only → AWSReservedSSO_viewer Role
```

**Key Concepts:**

**Identity Store (d-9a6763d7d3):**
- Shared across all 88 accounts
- Contains all users (synced from Okta)
- Contains all groups (86 total)
- Source of truth for identities

**Users:**
- Synced from Okta (one-way sync works)
- Examples: a805120, aa836933
- Can be members of multiple groups

**Groups:**
- Created by AFT during account provisioning
- Naming pattern: `App-AWS-AA-{account-name}-{account-id}-{role}`
- Global groups: `global:admin`, `global:reader`
- **Problem:** Group membership not syncing (SCIM broken)

**Permission Sets:**
- Define what users can do in accounts
- Examples: admin, read-only, developer
- Create IAM roles in member accounts
- Role naming: `AWSReservedSSO_{permission-set}_{suffix}`

**Member Accounts:**
- All 88 accounts trust the Identity Center
- Permission Sets create local IAM roles
- Users assume roles via SSO

**Flow Example:**
1. User `a805120` exists in Identity Store
2. User is member of `App-AWS-AA-database-sandbox-admin` group
3. Group assigned to `admin` permission set
4. Permission set creates `AWSReservedSSO_admin` role in account
5. User can assume role → gets admin access

---

### 8. CloudTrail Evidence Patterns

**File:** `cloudtrail_evidence_patterns.png`

**Evidence Analysis Across Three Accounts:**

**bfh_mgmt (50 Events in 7 Days):**
```
CloudTrail Event: CreateGroupMembership
├── UserAgent: aws-sdk-go-v2/1.30.4
├── Principal: arn:aws:sts::739275453939:assumed-role/sailpoint-read-write
├── EventTime: 2025-11-07 to 2025-11-14
└── Evidence:
    ✅ Automated (aws-sdk user agent)
    ✅ Working (50 successful events)
    ✅ High Frequency (7+ per day)
```

**database_sandbox (0 Events):**
```
CloudTrail Event: CreateGroupMembership
├── UserAgent: None
├── Principal: None
├── EventTime: None
└── Evidence:
    ❌ No Automation
    ❌ SCIM Broken
    ❌ Group Empty
```

**Identity_Center (18 Manual Events):**
```
CloudTrail Event: CreateGroupMembership
├── UserAgent: aws-cli/2.31.3
├── Principal: arn:aws:sts::717279730613:assumed-role/.../a805120
├── EventTime: 2025-09-16 to 2025-11-14
└── Evidence:
    ⚠️ Manual CLI (human-initiated)
    ⚠️ Workaround (SCIM broken, using manual)
    ⚠️ Sporadic (no regular pattern)
```

**CloudTrail Patterns:**

| Pattern | Indicator | Meaning |
|---------|-----------|---------|
| `aws-sdk-go-v2` | Automated | SailPoint direct integration |
| `aws-cli/2.x.x` | Manual | Human using AWS CLI |
| `AWS Internal` | Manual | Human using AWS Console |
| `okta-scim-client` | SCIM | Okta sync (NOT FOUND anywhere) |

**Investigation Evidence:**

**Accounts Investigated:** 21  
**Total CloudTrail Events:** 2,100+  
**SCIM Events Found:** 0  
**Conclusion:** Okta SCIM is broken globally

**Event Frequency Comparison:**
- bfh_mgmt: 7 events/day (automated)
- Identity_Center: 0.2 events/day (manual)
- database_sandbox: 0 events/day (no activity)

---

## 🎯 Key Insights from Diagrams

### Architectural Insights:

1. **Shared Identity Store:**
   - All 88 accounts use same Identity Store (d-9a6763d7d3)
   - Enables consistent identity management
   - Single source of truth for users and groups

2. **Centralized Logging:**
   - Log Archive account receives all CloudTrail logs
   - Enables organization-wide audit trail
   - Lifecycle management (S3 → Glacier)

3. **Two Integration Patterns:**
   - Direct SailPoint integration (bfh_mgmt only)
   - Okta SCIM integration (broken everywhere)

### Provisioning Insights:

1. **Working Automation (bfh_mgmt):**
   - Uses dedicated IAM role
   - Direct AWS API calls
   - Real-time provisioning
   - Fully automated

2. **Broken Automation (All Others):**
   - Relies on Okta SCIM
   - SCIM endpoint not functioning
   - Zero automated events
   - Manual workarounds in use

3. **Manual Workarounds:**
   - AWS CLI commands
   - AWS Console operations
   - Not scalable
   - Inconsistent usage

### Security Insights:

1. **CloudTrail Evidence:**
   - Comprehensive logging in Log Archive
   - User agents reveal provisioning method
   - Principal ARNs show who/what made changes
   - Event frequency indicates automation vs manual

2. **IAM Roles:**
   - `sailpoint-read-write`: Automated provisioning
   - `sailpoint-read-only`: Monitoring only
   - `AWSReservedSSO_*`: Permission Set roles

3. **Access Patterns:**
   - SSO via Identity Center
   - Group-based access control
   - Permission Sets define privileges

---

## 📋 Resource Inventory

### From Actual AWS Data:

**Log Archive Account (463470955493):**
- IAM Identity Center: ✅ Configured
- S3 Buckets: Multiple (for logs)
- CloudTrail: ✅ Enabled
- VPCs: Present

**bfh_mgmt Account (739275453939):**
- IAM Identity Center: ✅ Configured
- IAM Roles: `sailpoint-read-write`, `sailpoint-read-only`
- Groups: 50+ via Identity Store
- CloudTrail Events: 50 in 7 days

**database_sandbox Account (941677815499):**
- IAM Identity Center: ✅ Configured
- Groups: 50+ via Identity Store (including empty `App-AWS-AA-database-sandbox-admin`)
- CloudTrail Events: 0 group memberships
- Resources: Unknown (likely RDS, EC2)

---

## 🔄 Usage Flows

### User Access Flow:
```
1. User exists in Identity Store (synced from Okta)
2. User added to Group (manually or automated)
3. Group assigned to Permission Set
4. Permission Set creates IAM role in target account
5. User assumes role via SSO → Gets access
```

### Automated Provisioning Flow (bfh_mgmt):
```
1. User requests access in SailPoint
2. SailPoint evaluates request
3. SailPoint uses AWS SDK to assume sailpoint-read-write role
4. Role calls CreateGroupMembership API
5. User added to group in Identity Store
6. User can now assume permission set role in account
7. CloudTrail logs the operation
```

### Manual Provisioning Flow (Workaround):
```
1. Admin receives access request
2. Admin uses AWS CLI or Console
3. Admin manually adds user to group
4. User can now assume permission set role
5. CloudTrail logs with "aws-cli" user agent
```

### Failed Provisioning Flow (SCIM):
```
1. User requests access in SailPoint
2. SailPoint provisions in Okta
3. Okta attempts SCIM sync to AWS
4. SCIM sync fails (broken integration)
5. User NOT added to AWS group
6. No CloudTrail events
7. Group remains empty
```

---

## 🛠️ Replication Guide

### To Replicate bfh_mgmt Setup in Another Account:

**Based on diagram evidence:**

1. **Create IAM Role:**
   - Name: `sailpoint-read-write`
   - Type: Cross-account or service role
   - Trust policy: Allow SailPoint to assume

2. **Attach Permissions:**
   - `identitystore:CreateGroupMembership`
   - `identitystore:DeleteGroupMembership`
   - `identitystore:ListGroups`
   - `identitystore:ListUsers`
   - Others as needed

3. **Configure SailPoint:**
   - Add AWS account to SailPoint
   - Configure to use IAM role (not Okta SCIM)
   - Test with single group membership

4. **Verify in CloudTrail:**
   - Look for CreateGroupMembership events
   - User agent should be `aws-sdk-go-v2`
   - Principal should be `sailpoint-read-write` role

---

## 📊 Diagram Legend

### Color Coding:
- 🟢 **Green (Solid):** Working, automated flow
- 🔴 **Red (Dashed):** Broken, failed flow
- 🟡 **Orange:** Manual workaround
- ⚫ **Black (Dashed):** Monitoring/logging

### Icon Meanings:
- 👤 User: Human user
- 👥 Users: Multiple users
- 🏢 Building: External service (SailPoint)
- 🔐 Lock: IAM Role
- 🔑 Key: KMS encryption
- 📊 Chart: CloudTrail/CloudWatch
- 🗄️ Database: Identity Store/Resources
- 🪣 Bucket: S3 storage
- ❄️ Snowflake: S3 Glacier
- ⚠️ Warning: Security finding/issue

---

## 📖 References

**Investigation Files:**
- `PICKUP_SUMMARY.md` - Complete investigation summary
- `EXPLAINED_FOR_USER.md` - Detailed explanations
- `FINAL_20_ACCOUNT_INVESTIGATION_REPORT.md` - Technical report
- `ACCOUNT_COMPARISON_TABLE.md` - 21-account comparison

**Evidence Files:**
- `raw_data/bfh_mgmt_739275453939_admin/` - CloudTrail events
- `raw_data/database_sandbox_941677815499_admin/` - Empty account data
- `account_diagrams_data/` - Raw AWS resource data

**CloudTrail Evidence:**
- 50 events from bfh_mgmt (automated provisioning)
- 18 events from Identity_Center (manual CLI)
- 0 events from database_sandbox (no activity)
- 0 SCIM events across all 21 accounts

---

**Created:** November 14, 2025  
**Diagrams Location:** `/Users/a805120/develop/oneoffs/tools/aft_aws_access/diagrams/`  
**Last Updated:** November 14, 2025