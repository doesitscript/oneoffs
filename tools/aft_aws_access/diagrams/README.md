# AWS Account Architecture Diagrams

**Date:** November 14, 2025  
**Investigation:** AWS IAM Identity Center Group Provisioning

---

## 📊 Generated Diagrams (8 Total)

### Individual Account Diagrams:

1. **log_archive_account.png** - Log Archive Account (463470955493)
   - Centralized logging for all 88 accounts
   - S3 → Glacier lifecycle management
   - Read-only access model

2. **bfh_mgmt_account.png** - bfh_mgmt Account (739275453939)
   - 🎯 **ONLY account with working automated provisioning**
   - SailPoint direct integration
   - sailpoint-read-write IAM role
   - 50 automated events in 7 days

3. **database_sandbox_account.png** - database_sandbox Account (941677815499)
   - Empty groups (no provisioning)
   - SCIM broken, no automation
   - 0 CloudTrail events

### Integration & Flow Diagrams:

4. **multi_account_integration.png** - Multi-Account Integration
   - How all accounts work together
   - Shared Identity Store (d-9a6763d7d3)
   - Logging flow to Log Archive

5. **sailpoint_flow_comparison.png** - Working vs Broken Provisioning
   - Side-by-side comparison
   - Direct SailPoint (WORKS) vs Okta SCIM (BROKEN)

6. **complete_environment_usage.png** - Complete Environment
   - Full organizational flow
   - Control Tower + AFT
   - End-to-end lifecycle

7. **identity_center_architecture.png** - IAM Identity Center Details
   - Shared identity architecture
   - 88 accounts, 86 groups
   - Permission Set model

8. **cloudtrail_evidence_patterns.png** - CloudTrail Evidence
   - Event pattern analysis
   - 3 account comparison
   - Evidence-based findings

---

## 🔑 Key Findings Illustrated:

### ✅ Working (bfh_mgmt):
- User Agent: `aws-sdk-go-v2/1.30.4`
- Principal: `sailpoint-read-write` role
- Events: 50 in 7 days
- Status: Automated, working perfectly

### ❌ Broken (database_sandbox + 19 others):
- User Agent: None
- Principal: None
- Events: 0
- Status: SCIM broken, no automation

### ⚠️ Manual Workaround (Identity_Center):
- User Agent: `aws-cli/2.31.3`
- Principal: Human users
- Events: 18 in 2 months
- Status: Manual, sporadic

---

## 📖 Documentation

**Complete explanation:** `../investigations/20241114_scim_investigation/DIAGRAM_DOCUMENTATION.md`

**Includes:**
- Detailed architecture descriptions
- Resource inventories
- Usage flows
- Replication guides
- Evidence analysis

---

## 🎯 Quick Visual Guide

**Want to understand:**
- Log Archive? → `log_archive_account.png`
- Working automation? → `bfh_mgmt_account.png`
- Your empty group? → `database_sandbox_account.png`
- How to fix it? → `sailpoint_flow_comparison.png`
- Everything together? → `complete_environment_usage.png`

---

**All diagrams auto-generated from actual AWS data using CloudTrail evidence and resource inspection.**
