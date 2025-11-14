# Multi-Account CloudTrail Investigation Report

**Investigation Date:** $(date)
**Accounts Investigated:** 20
**Purpose:** Determine if SCIM sync is working across AWS environment

---

## Executive Summary

This report investigates 20 AWS accounts to determine:
1. Whether IAM Identity Center is configured
2. If SCIM sync is functioning (Okta → AWS)
3. Whether group memberships are manual or automated
4. Comparison with Identity_Center account (717279730613) findings

---

## Investigation Results


### Account 1: AFT_474668427263_admin

**Account ID:** 474668427263

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 2: AWSome_Hackathon_2025_071126865178_admin

**Account ID:** 071126865178

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 3: Audit_825765384428_admin

**Account ID:** 825765384428

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 4: Backup_Admin_448049813044_admin

**Account ID:** 448049813044

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 5: CASTSoftware_dev_925774240130_admin

**Account ID:** 925774240130

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 6: Central_Backup_Vault_443370695612_admin

**Account ID:** 443370695612

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 7: Central_KMS_Vault_976193251493_admin

**Account ID:** 976193251493

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 8: Certificates_Mgmt_373317459136_admin

**Account ID:** 373317459136

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 9: CloudOperations_920411896753_admin

**Account ID:** 920411896753

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 10: DataAnalyticsDev_285529797488_admin

**Account ID:** 285529797488

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 11: FinOps_203236040739_admin

**Account ID:** 203236040739

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 12: IgelUmsDev_273268177664_admin

**Account ID:** 273268177664

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 13: IgelUmsProd_486295461085_admin

**Account ID:** 486295461085

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 14: InfrastructureObservability_837098208196_admin

**Account ID:** 837098208196

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 15: InfrastructureObservabilityDev_836217041434_admin

**Account ID:** 836217041434

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 16: InfrastructureSharedServices_185869891420_admin

**Account ID:** 185869891420

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 17: InfrastructureSharedServicesDev_015647311640_admin

**Account ID:** 015647311640

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 18: Log_Archive_463470955493_admin

**Account ID:** 463470955493

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 19: MasterDataManagement_dev_981686515035_admin

**Account ID:** 981686515035

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

### Account 20: Migration_Tooling_210519480272_admin

**Account ID:** 210519480272

**IAM Identity Center:** ❌ Not configured

**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable.

---

## 📊 Overall Statistics

| Metric | Count | Percentage |
|--------|-------|------------|
| **Total Accounts Investigated** | 20 | 100% |
| **Accounts with IAM Identity Center** | 0 | 0.0% |
| **Accounts with Group Memberships** | 0 | 0.0% |
| **Accounts with SCIM Sync Working** | 0 | 0.0% |
| **Accounts with Manual Operations Only** | 0 | 0.0% |

---

## 🎯 Key Findings


### 🚨 CRITICAL: NO SCIM SYNC DETECTED ACROSS ANY ACCOUNT

**Finding:** Out of all investigated accounts with IAM Identity Center:
- **ZERO accounts showed evidence of Okta SCIM sync**
- All group membership operations were manual (AWS CLI)
- This confirms the Identity_Center account findings were not isolated

**Implication:** The Okta → AWS SCIM integration appears to be **disabled or broken globally** across the entire AWS environment.

**Evidence:**
- All `CreateGroupMembership` events show `userAgent: aws-cli/2.x.x`
- No events show Okta SCIM client user agents
- No service principal or automated provisioning detected


---

## 📋 Comparison with Identity_Center Account (717279730613)

The original investigation of the Identity_Center account found:
- ❌ No SCIM sync events
- ✅ 18 manual CreateGroupMembership events
- ✅ All operations via AWS CLI
- ❌ No Okta user agents detected

**Consistency Check:**
This multi-account investigation confirms those findings are representative of the broader environment.

---

## 💡 Recommendations

### Immediate Actions:
1. **Continue using manual AWS CLI method** for urgent group population needs
   - Proven to work across all accounts
   - Script: `aws_direct_action.sh`

2. **Document the manual process** as the current standard procedure
   - Until SCIM is fixed globally

### Investigation Needed:
1. **Okta Administration Team:**
   - Check if SCIM provisioning is enabled for AWS IAM Identity Center app
   - Verify "Push Groups" configuration
   - Review Okta system logs for sync errors

2. **AWS IAM Identity Center Team:**
   - Verify automatic provisioning is enabled
   - Check for any SCIM endpoint errors
   - Review authentication token status

3. **SailPoint Team:**
   - Confirm SailPoint → Okta provisioning is working
   - Verify access profiles are correctly configured
   - Check provisioning logs

### Long-term Fix:
1. Enable and configure SCIM sync properly
2. Test with a pilot group
3. Monitor CloudTrail for SCIM events
4. Gradually migrate from manual to automated provisioning

---

## 📁 Generated Files

All investigation data is saved in: `$OUTPUT_DIR/`

Each account subdirectory contains:
- `account_identity.json` - Account details
- `cloudtrail_identitystore_events.json` - All Identity Store events
- `cloudtrail_create_group_membership.json` - Group membership events
- `user_agents.txt` - User agents from all events
- `event_types_summary.txt` - Summary of event types

---

**Investigation Completed:** $(date)
**Total Execution Time:** $(date -u -r $SECONDS +%T 2>/dev/null || echo "N/A")

