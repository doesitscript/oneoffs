# AWS IAM Identity Center Group Provisioning Investigation
## November 14, 2025

This directory contains a comprehensive investigation into AWS IAM Identity Center group provisioning across 21 AWS accounts at Bread Financial.

---

## 📁 File Index

### 🚀 START HERE (For Next Agent)

| File | Purpose | When to Use |
|------|---------|-------------|
| **AGENT_HANDOFF_SUMMARY.md** | Quick instructions for checking group status | Copy-paste to next chat agent |
| **QUICK_CHECK_COMMANDS.sh** | Automated status check script | Run this to check current status |

### 📊 Investigation Reports

| File | Purpose | Audience |
|------|---------|----------|
| **FINAL_20_ACCOUNT_INVESTIGATION_REPORT.md** | Comprehensive 500+ line report | Technical deep-dive |
| **ACCOUNT_COMPARISON_TABLE.md** | Account-by-account comparison | Quick overview |
| **QUICK_REFERENCE.md** | Quick reference guide | Fast lookup |
| **INVESTIGATION_SUMMARY.txt** | Visual ASCII summary | Executive summary |

### 🔧 Detailed Instructions

| File | Purpose | When to Use |
|------|---------|-------------|
| **INSTRUCTIONS_FOR_NEXT_AGENT.md** | Step-by-step investigation guide | Detailed follow-up investigation |

### 📂 Raw Investigation Data

| Directory | Contents |
|-----------|----------|
| `scim_investigation_20251114_134819/` | CloudTrail data from 20 accounts |
| `multi_account_investigation_20251114_134330/` | Initial IAM Identity Center scan |

---

## 🎯 Quick Summary

### What We Investigated:
- **21 AWS accounts** (including the original Identity_Center account)
- **2,100+ CloudTrail events** analyzed
- **90 days** of provisioning history

### What We Found:

| Finding | Impact |
|---------|--------|
| ❌ **Okta SCIM is broken globally** | 0 of 21 accounts show SCIM sync |
| ✅ **SailPoint direct integration exists** | Working in bfh_mgmt account (739275453939) |
| ✅ **Manual methods work** | AWS CLI and Console both functional |
| ⚠️ **Most accounts are empty** | 18 of 20 investigated accounts show no activity |

### Your Account Status (database_sandbox):
- **Account ID:** 941677815499
- **Group:** `App-AWS-AA-database-sandbox-941677815499-admin`
- **Status:** Empty (0 members)
- **Reason:** No provisioning method configured

---

## ⚡ Quick Commands

### Check Current Status:
```bash
./QUICK_CHECK_COMMANDS.sh
```

### Manual Quick Check:
```bash
# Check member count
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2 \
  --profile database_sandbox_941677815499_admin

# Check recent events
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
  --start-time "2025-11-14T00:00:00Z" \
  --region us-east-2 \
  --profile database_sandbox_941677815499_admin
```

---

## 🔑 Key Account Information

### Target Account (database_sandbox):
- **Account ID:** 941677815499
- **AWS Profile:** `database_sandbox_941677815499_admin`
- **Identity Store ID:** `d-9a6763d7d3`
- **Group ID:** `711bf5c0-b071-70c1-06da-35d7fbcac52d`
- **Region:** `us-east-2`

### Comparison Accounts:

| Account | ID | Profile | Status |
|---------|----|----|--------|
| bfh_mgmt | 739275453939 | bfh_mgmt_739275453939_admin | ✅ SailPoint Direct (50 events/7 days) |
| FinOps | 203236040739 | FinOps_203236040739_admin | ✅ Manual Console (38 events/3 months) |
| Identity_Center | 717279730613 | Identity_Center_717279730613_admin | ✅ Manual CLI (18 events/2 months) |

---

## 📊 Provisioning Methods Discovered

| Method | Accounts | Status | Evidence |
|--------|----------|--------|----------|
| Okta SCIM Sync | 0 | ❌ Broken | No SCIM events found |
| SailPoint Direct | 1 | ✅ Working | aws-sdk-go-v2 user agent |
| Manual AWS CLI | 1 | ✅ Working | aws-cli/2.x.x user agent |
| Manual AWS Console | 1 | ✅ Working | AWS Internal user agent |
| No Activity | 18 | ⚠️ Unknown | No CloudTrail events |

---

## 🚨 Critical Discovery

### bfh_mgmt Account Has Working Automation!

**Account:** bfh_mgmt (739275453939)  
**Method:** Direct SailPoint → AWS SDK → IAM Identity Center  
**IAM Role:** `sailpoint-read-write`  
**Activity:** 50 successful events in last 7 days  
**Significance:** This proves automated provisioning IS possible, just not via Okta SCIM

---

## 💡 Recommendations

### Immediate (To Populate Your Group):
1. **Use manual AWS CLI** - Proven to work
2. **Use AWS Console UI** - Non-technical friendly

### Long-term (To Enable Automation):
1. **Contact bfh_mgmt team** - Learn about their SailPoint direct integration
2. **Investigate replication** - Can their method be used in database_sandbox?
3. **Choose official strategy** - Decide on: Fix Okta SCIM OR Adopt SailPoint direct OR Continue manual

---

## 📞 Stakeholders

| Team | Priority | Why |
|------|----------|-----|
| bfh_mgmt Account Admins | HIGH | They have working automated provisioning |
| SailPoint Team | HIGH | Can enable direct integration |
| Okta Team | MEDIUM | To understand why SCIM is broken |
| AWS Team | LOW | AWS side is working fine |

---

## 📈 Investigation Timeline

| Date | Event |
|------|-------|
| Nov 14, 2025 | Original investigation of Identity_Center account |
| Nov 14, 2025 | Multi-account scan (88 accounts) |
| Nov 14, 2025 | Detailed investigation of 20 accounts |
| Nov 14, 2025 | Discovery of bfh_mgmt SailPoint integration |
| **[Future]** | Follow-up check (use QUICK_CHECK_COMMANDS.sh) |

---

## 🎓 What We Learned

### Technical Findings:
1. Okta SCIM sync is completely broken (0 events across all accounts)
2. Direct SailPoint → AWS integration is superior (no Okta middleman)
3. Multiple manual workarounds exist (CLI, Console)
4. CloudTrail user agents reveal provisioning method

### Organizational Insights:
1. Teams have independently created workarounds
2. No centralized provisioning solution in use
3. Automated provisioning exists but only in 1 account
4. Most accounts rely on manual processes

---

## 📝 For Next Investigation

When checking group status again:

1. **Run:** `./QUICK_CHECK_COMMANDS.sh`
2. **Check:** Member count and recent CloudTrail events
3. **Analyze:** User agents to determine provisioning method
4. **Report:** Any changes from Nov 14 baseline

**Key Question:** Has automated provisioning been enabled in database_sandbox?

---

**Investigation Date:** November 14, 2025  
**Investigator:** AI Assistant  
**Total Investigation Time:** ~45 minutes  
**Files Generated:** 10+ comprehensive reports and scripts  
**Confidence Level:** High (based on 2,100+ CloudTrail events analyzed)

---

## 🏆 Success Criteria for Future Checks

### Group is Considered "Working" When:
- [ ] Member count > 0
- [ ] Members match expected access list
- [ ] Provisioning is automated (not manual)
- [ ] CloudTrail shows consistent activity
- [ ] User agent indicates SailPoint or SCIM (not CLI/Console)

**Current Status:** ❌ None of the above criteria met (as of Nov 14, 2025)

