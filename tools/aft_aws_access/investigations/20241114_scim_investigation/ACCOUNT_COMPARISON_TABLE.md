# AWS Account Group Provisioning Method Comparison

| # | Account Name | Account ID | Events | Method | User Agent | Status |
|---|--------------|------------|--------|--------|------------|--------|
| **Original** | **Identity_Center** | **717279730613** | **18** | **Manual AWS CLI** | **aws-cli/2.x.x** | **✅ Working** |
| 1 | database_sandbox | 941677815499 | 0 | None | N/A | ❌ Empty |
| 2 | Audit | 825765384428 | 0 | None | N/A | ⚠️ No Activity |
| 3 | CloudOperations | 920411896753 | 0 | None | N/A | ⚠️ No Activity |
| 4 | Security_Tooling | 794038215373 | 0 | None | N/A | ⚠️ No Activity |
| 5 | Network_Hub | 207567762220 | 0 | None | N/A | ⚠️ No Activity |
| 6 | SDLC_DEV_Testing | 893061506494 | 0 | None | N/A | ⚠️ No Activity |
| 7 | SDLC_QA_CBC_API | 269855572980 | 0 | None | N/A | ⚠️ No Activity |
| 8 | SDLC_UAT_EASYPAY | 980104891822 | 0 | None | N/A | ⚠️ No Activity |
| 9 | MasterDataManagement_prd | 553455761466 | 0 | None | N/A | ⚠️ No Activity |
| 10 | confluent_prod | 042417219076 | 0 | None | N/A | ⚠️ No Activity |
| **11** | **FinOps** | **203236040739** | **38** | **AWS Console** | **AWS Internal** | **✅ Working** |
| 12 | DataAnalyticsDev | 285529797488 | 0 | None | N/A | ⚠️ No Activity |
| 13 | SharedServices_SRE | 795438191304 | 0 | None | N/A | ⚠️ No Activity |
| 14 | InfrastructureSharedServices | 185869891420 | 0 | None | N/A | ⚠️ No Activity |
| 15 | CASTSoftware_dev | 925774240130 | 0 | None | N/A | ⚠️ No Activity |
| 16 | IgelUmsProd | 486295461085 | 0 | None | N/A | ⚠️ No Activity |
| 17 | Secrets_Management | 556180171418 | 0 | None | N/A | ⚠️ No Activity |
| 18 | StrongDM | 967660016041 | 0 | None | N/A | ⚠️ No Activity |
| **19** | **bfh_mgmt** | **739275453939** | **50** | **SailPoint Direct** | **aws-sdk-go-v2** | **✅ Working** |
| 20 | AwsInfrastructure_sandbox | 960682159332 | 0 | None | N/A | ⚠️ No Activity |

---

## Provisioning Method Summary

| Method | Accounts | Events | Status | Evidence |
|--------|----------|--------|--------|----------|
| **Okta SCIM Sync** | 0 | 0 | ❌ Broken | No SCIM user agents found |
| **SailPoint Direct Integration** | 1 (bfh_mgmt) | 50 | ✅ Working | Role: sailpoint-read-write |
| **Manual AWS CLI** | 1 (Identity_Center) | 18 | ✅ Working | User agent: aws-cli/2.x.x |
| **Manual AWS Console** | 1 (FinOps) | 38 | ✅ Working | User agent: AWS Internal |
| **No Activity (90 days)** | 18 | 0 | ⚠️ Unknown | No CloudTrail events |

---

## Key Findings

### ✅ Working Methods:
1. **SailPoint Direct Integration** (bfh_mgmt) - 50 events in 7 days
2. **Manual AWS Console** (FinOps) - 38 events in 3 months  
3. **Manual AWS CLI** (Identity_Center) - 18 events in 2 months

### ❌ Broken Methods:
1. **Okta SCIM** - 0 events across all 21 accounts

### ⚠️ Your Account (database_sandbox):
- **Status:** Empty
- **Reason:** No provisioning method configured
- **Solution:** Use manual AWS CLI OR investigate bfh_mgmt SailPoint integration

---

**Investigation Date:** November 14, 2025  
**Total Accounts Scanned:** 88  
**Accounts with Identity Center:** 86  
**Accounts Investigated in Detail:** 21
