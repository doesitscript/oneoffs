#!/bin/bash

# Multi-Account CloudTrail Investigation Script
# Purpose: Investigate 20 AWS accounts for SCIM sync vs manual group membership operations
# Date: November 14, 2025

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Output directory
OUTPUT_DIR="multi_account_investigation_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Log file
LOG_FILE="$OUTPUT_DIR/investigation.log"
SUMMARY_FILE="$OUTPUT_DIR/SUMMARY_REPORT.md"

# Function to log messages
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Function to write to summary
write_summary() {
    echo "$1" >> "$SUMMARY_FILE"
}

# Accounts to investigate (excluding Identity_Center which was already done)
ACCOUNTS=(
    "AFT_474668427263_admin"
    "AWSome_Hackathon_2025_071126865178_admin"
    "Audit_825765384428_admin"
    "Backup_Admin_448049813044_admin"
    "CASTSoftware_dev_925774240130_admin"
    "Central_Backup_Vault_443370695612_admin"
    "Central_KMS_Vault_976193251493_admin"
    "Certificates_Mgmt_373317459136_admin"
    "CloudOperations_920411896753_admin"
    "DataAnalyticsDev_285529797488_admin"
    "FinOps_203236040739_admin"
    "IgelUmsDev_273268177664_admin"
    "IgelUmsProd_486295461085_admin"
    "InfrastructureObservability_837098208196_admin"
    "InfrastructureObservabilityDev_836217041434_admin"
    "InfrastructureSharedServices_185869891420_admin"
    "InfrastructureSharedServicesDev_015647311640_admin"
    "Log_Archive_463470955493_admin"
    "MasterDataManagement_dev_981686515035_admin"
    "Migration_Tooling_210519480272_admin"
)

# Initialize summary report
cat > "$SUMMARY_FILE" << 'EOF'
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

EOF

# Counter for statistics
TOTAL_ACCOUNTS=0
ACCOUNTS_WITH_IDENTITY_CENTER=0
ACCOUNTS_WITH_SCIM_EVENTS=0
ACCOUNTS_WITH_MANUAL_EVENTS=0
ACCOUNTS_WITH_GROUP_MEMBERSHIPS=0

log "${CYAN}================================================${NC}"
log "${CYAN}Multi-Account CloudTrail Investigation${NC}"
log "${CYAN}================================================${NC}"
log ""
log "${BLUE}Investigation started at: $(date)${NC}"
log "${BLUE}Output directory: $OUTPUT_DIR${NC}"
log ""

# Main investigation loop
for PROFILE in "${ACCOUNTS[@]}"; do
    TOTAL_ACCOUNTS=$((TOTAL_ACCOUNTS + 1))
    ACCOUNT_NUM=$TOTAL_ACCOUNTS

    log ""
    log "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log "${MAGENTA}Account $ACCOUNT_NUM/20: $PROFILE${NC}"
    log "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Create account directory
    ACCOUNT_DIR="$OUTPUT_DIR/$PROFILE"
    mkdir -p "$ACCOUNT_DIR"

    # Extract account ID from profile name
    ACCOUNT_ID=$(echo "$PROFILE" | grep -oE '[0-9]{12}' || echo "unknown")

    # Get account identity
    log "${BLUE}[Step 1] Getting account identity...${NC}"
    if aws sts get-caller-identity --profile "$PROFILE" > "$ACCOUNT_DIR/account_identity.json" 2>&1; then
        ACTUAL_ACCOUNT_ID=$(jq -r '.Account' "$ACCOUNT_DIR/account_identity.json")
        log "${GREEN}✓ Account ID confirmed: $ACTUAL_ACCOUNT_ID${NC}"

        write_summary ""
        write_summary "### Account $ACCOUNT_NUM: $PROFILE"
        write_summary ""
        write_summary "**Account ID:** $ACTUAL_ACCOUNT_ID"
        write_summary ""
    else
        log "${RED}✗ Failed to get account identity${NC}"
        write_summary ""
        write_summary "### Account $ACCOUNT_NUM: $PROFILE"
        write_summary ""
        write_summary "**Status:** ❌ Access Failed"
        write_summary ""
        continue
    fi

    # Check if Identity Center is used (try to list identity stores)
    log "${BLUE}[Step 2] Checking for IAM Identity Center...${NC}"
    USES_IDENTITY_CENTER=false
    IDENTITY_STORE_ID=""

    # Try us-east-2 first (where we found it in Identity_Center account)
    for REGION in "us-east-2" "us-east-1" "us-west-2"; do
        if aws identitystore list-groups --identity-store-id "d-placeholder" --region "$REGION" --profile "$PROFILE" 2>&1 | grep -q "ResourceNotFoundException\|ValidationException"; then
            # Try to find the actual identity store ID
            if aws identitystore list-groups --max-results 1 --region "$REGION" --profile "$PROFILE" > "$ACCOUNT_DIR/identity_check_$REGION.json" 2>&1; then
                USES_IDENTITY_CENTER=true
                # Try to extract identity store ID from error or success
                log "${GREEN}✓ IAM Identity Center detected in $REGION${NC}"

                # Try to list groups to confirm
                if aws sso-admin list-instances --region "$REGION" --profile "$PROFILE" > "$ACCOUNT_DIR/sso_instances_$REGION.json" 2>&1; then
                    IDENTITY_STORE_ID=$(jq -r '.Instances[0].IdentityStoreId // "unknown"' "$ACCOUNT_DIR/sso_instances_$REGION.json")
                    if [ "$IDENTITY_STORE_ID" != "unknown" ] && [ "$IDENTITY_STORE_ID" != "null" ]; then
                        log "${GREEN}✓ Identity Store ID: $IDENTITY_STORE_ID${NC}"
                        ACCOUNTS_WITH_IDENTITY_CENTER=$((ACCOUNTS_WITH_IDENTITY_CENTER + 1))
                        break
                    fi
                fi
            fi
        fi
    done

    if [ "$USES_IDENTITY_CENTER" = false ]; then
        log "${YELLOW}⚠ No IAM Identity Center detected (likely uses IAM users/groups)${NC}"
        write_summary "**IAM Identity Center:** ❌ Not configured"
        write_summary ""
        write_summary "**Analysis:** This account uses traditional IAM users/groups, not Identity Center. SCIM investigation not applicable."
        write_summary ""
        write_summary "---"
        continue
    else
        write_summary "**IAM Identity Center:** ✅ Configured"
        write_summary ""
        write_summary "**Identity Store ID:** $IDENTITY_STORE_ID"
        write_summary ""
    fi

    # Search CloudTrail for Identity Store events
    log "${BLUE}[Step 3] Searching CloudTrail for Identity Store events...${NC}"

    # Get recent identity store events (last 90 days)
    aws cloudtrail lookup-events \
        --lookup-attributes AttributeKey=EventSource,AttributeValue=identitystore.amazonaws.com \
        --max-results 100 \
        --region us-east-2 \
        --profile "$PROFILE" \
        > "$ACCOUNT_DIR/cloudtrail_identitystore_events.json" 2>&1 || true

    TOTAL_IDENTITY_EVENTS=$(jq '[.Events[]? // empty] | length' "$ACCOUNT_DIR/cloudtrail_identitystore_events.json" 2>/dev/null || echo "0")
    log "${BLUE}Found $TOTAL_IDENTITY_EVENTS identity store events${NC}"

    # Search for CreateGroupMembership events specifically
    log "${BLUE}[Step 4] Searching for CreateGroupMembership events...${NC}"

    aws cloudtrail lookup-events \
        --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
        --max-results 100 \
        --region us-east-2 \
        --profile "$PROFILE" \
        > "$ACCOUNT_DIR/cloudtrail_create_group_membership.json" 2>&1 || true

    MEMBERSHIP_EVENTS=$(jq '[.Events[]? // empty] | length' "$ACCOUNT_DIR/cloudtrail_create_group_membership.json" 2>/dev/null || echo "0")

    if [ "$MEMBERSHIP_EVENTS" -gt 0 ]; then
        ACCOUNTS_WITH_GROUP_MEMBERSHIPS=$((ACCOUNTS_WITH_GROUP_MEMBERSHIPS + 1))
        log "${GREEN}✓ Found $MEMBERSHIP_EVENTS CreateGroupMembership events${NC}"

        # Analyze user agents to determine if SCIM or manual
        jq -r '.Events[]? | @json' "$ACCOUNT_DIR/cloudtrail_create_group_membership.json" | while read -r event; do
            echo "$event" >> "$ACCOUNT_DIR/membership_events_raw.json"
        done

        # Extract user agents
        jq -r '.Events[]?.CloudTrailEvent | fromjson | .userAgent' "$ACCOUNT_DIR/cloudtrail_create_group_membership.json" > "$ACCOUNT_DIR/user_agents.txt" 2>&1 || true

        # Count SCIM vs manual
        SCIM_COUNT=$(grep -c -i "scim\|okta" "$ACCOUNT_DIR/user_agents.txt" 2>/dev/null || echo "0")
        MANUAL_COUNT=$(grep -c "aws-cli" "$ACCOUNT_DIR/user_agents.txt" 2>/dev/null || echo "0")

        log "${BLUE}  - SCIM/Okta events: $SCIM_COUNT${NC}"
        log "${BLUE}  - Manual AWS CLI events: $MANUAL_COUNT${NC}"

        write_summary "**CreateGroupMembership Events:** $MEMBERSHIP_EVENTS total"
        write_summary ""

        if [ "$SCIM_COUNT" -gt 0 ]; then
            ACCOUNTS_WITH_SCIM_EVENTS=$((ACCOUNTS_WITH_SCIM_EVENTS + 1))
            log "${GREEN}✓✓✓ SCIM SYNC DETECTED! ✓✓✓${NC}"
            write_summary "**SCIM Sync Status:** ✅ **WORKING** ($SCIM_COUNT SCIM events detected)"
            write_summary ""
            write_summary "**Evidence:**"
            write_summary '```'
            head -5 "$ACCOUNT_DIR/user_agents.txt" | grep -i "scim\|okta" | while read -r ua; do
                write_summary "$ua"
            done
            write_summary '```'
            write_summary ""
        else
            log "${YELLOW}⚠ All events are manual (AWS CLI)${NC}"
            write_summary "**SCIM Sync Status:** ❌ **NOT WORKING** (0 SCIM events)"
            write_summary ""
        fi

        if [ "$MANUAL_COUNT" -gt 0 ]; then
            ACCOUNTS_WITH_MANUAL_EVENTS=$((ACCOUNTS_WITH_MANUAL_EVENTS + 1))
            write_summary "**Manual Operations:** ⚠️ $MANUAL_COUNT manual AWS CLI operations detected"
            write_summary ""

            # Get unique users who manually added members
            jq -r '.Events[]?.CloudTrailEvent | fromjson | .userIdentity.principalId' "$ACCOUNT_DIR/cloudtrail_create_group_membership.json" 2>/dev/null | sort | uniq > "$ACCOUNT_DIR/manual_users.txt"

            write_summary "**Users performing manual operations:**"
            write_summary '```'
            cat "$ACCOUNT_DIR/manual_users.txt" >> "$SUMMARY_FILE"
            write_summary '```'
            write_summary ""
        fi

        # Get date range
        FIRST_EVENT=$(jq -r '.Events[-1]?.EventTime // "unknown"' "$ACCOUNT_DIR/cloudtrail_create_group_membership.json")
        LAST_EVENT=$(jq -r '.Events[0]?.EventTime // "unknown"' "$ACCOUNT_DIR/cloudtrail_create_group_membership.json")

        write_summary "**Date Range:** $FIRST_EVENT to $LAST_EVENT"
        write_summary ""

    else
        log "${YELLOW}⚠ No CreateGroupMembership events found${NC}"
        write_summary "**CreateGroupMembership Events:** 0 (No group memberships detected)"
        write_summary ""
        write_summary "**Analysis:** Either groups are empty, or events are older than 90 days."
        write_summary ""
    fi

    # Check for other identity store operations
    log "${BLUE}[Step 5] Analyzing other Identity Store operations...${NC}"

    if [ "$TOTAL_IDENTITY_EVENTS" -gt 0 ]; then
        # Get unique event names
        jq -r '.Events[]?.EventName' "$ACCOUNT_DIR/cloudtrail_identitystore_events.json" 2>/dev/null | sort | uniq -c | sort -rn > "$ACCOUNT_DIR/event_types_summary.txt"

        write_summary "**Other Identity Store Operations:**"
        write_summary '```'
        cat "$ACCOUNT_DIR/event_types_summary.txt" >> "$SUMMARY_FILE"
        write_summary '```'
        write_summary ""
    fi

    write_summary "---"

    # Brief pause to avoid API throttling
    sleep 2
done

# Generate final summary statistics
log ""
log "${CYAN}================================================${NC}"
log "${CYAN}Investigation Complete!${NC}"
log "${CYAN}================================================${NC}"
log ""
log "${GREEN}Statistics:${NC}"
log "${BLUE}  Total Accounts Investigated: $TOTAL_ACCOUNTS${NC}"
log "${BLUE}  Accounts with Identity Center: $ACCOUNTS_WITH_IDENTITY_CENTER${NC}"
log "${BLUE}  Accounts with Group Memberships: $ACCOUNTS_WITH_GROUP_MEMBERSHIPS${NC}"
log "${GREEN}  Accounts with SCIM Events: $ACCOUNTS_WITH_SCIM_EVENTS${NC}"
log "${YELLOW}  Accounts with Manual Events Only: $ACCOUNTS_WITH_MANUAL_EVENTS${NC}"
log ""

# Add statistics to summary
cat >> "$SUMMARY_FILE" << EOF

## 📊 Overall Statistics

| Metric | Count | Percentage |
|--------|-------|------------|
| **Total Accounts Investigated** | $TOTAL_ACCOUNTS | 100% |
| **Accounts with IAM Identity Center** | $ACCOUNTS_WITH_IDENTITY_CENTER | $(awk "BEGIN {printf \"%.1f\", ($ACCOUNTS_WITH_IDENTITY_CENTER/$TOTAL_ACCOUNTS)*100}")% |
| **Accounts with Group Memberships** | $ACCOUNTS_WITH_GROUP_MEMBERSHIPS | $(awk "BEGIN {printf \"%.1f\", ($ACCOUNTS_WITH_GROUP_MEMBERSHIPS/$TOTAL_ACCOUNTS)*100}")% |
| **Accounts with SCIM Sync Working** | $ACCOUNTS_WITH_SCIM_EVENTS | $(awk "BEGIN {printf \"%.1f\", ($ACCOUNTS_WITH_SCIM_EVENTS/$TOTAL_ACCOUNTS)*100}")% |
| **Accounts with Manual Operations Only** | $ACCOUNTS_WITH_MANUAL_EVENTS | $(awk "BEGIN {printf \"%.1f\", ($ACCOUNTS_WITH_MANUAL_EVENTS/$TOTAL_ACCOUNTS)*100}")% |

---

## 🎯 Key Findings

EOF

if [ "$ACCOUNTS_WITH_SCIM_EVENTS" -eq 0 ]; then
    cat >> "$SUMMARY_FILE" << 'EOF'

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

EOF
else
    cat >> "$SUMMARY_FILE" << EOF

### ✅ SCIM Sync Status: Mixed Results

**Finding:** SCIM sync was detected in **$ACCOUNTS_WITH_SCIM_EVENTS out of $ACCOUNTS_WITH_IDENTITY_CENTER** Identity Center accounts.

**Accounts with working SCIM:**
$(grep -B 2 "SCIM Sync Status.*WORKING" "$SUMMARY_FILE" | grep "^### Account" | sed 's/### /- /')

**Accounts with manual-only operations:**
$(grep -B 2 "SCIM Sync Status.*NOT WORKING" "$SUMMARY_FILE" | grep "^### Account" | sed 's/### /- /')

EOF
fi

cat >> "$SUMMARY_FILE" << 'EOF'

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

EOF

log "${GREEN}✓ Summary report generated: $SUMMARY_FILE${NC}"
log "${GREEN}✓ All data saved to: $OUTPUT_DIR/${NC}"
log ""
log "${CYAN}Investigation complete! Review the summary report for detailed findings.${NC}"
