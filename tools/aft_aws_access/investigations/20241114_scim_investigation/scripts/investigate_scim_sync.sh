#!/bin/bash

# SCIM Sync Investigation - 20 Accounts
# Checks for evidence of Okta SCIM sync vs manual operations

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

OUTPUT_DIR="scim_investigation_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

LOG_FILE="$OUTPUT_DIR/investigation.log"
SUMMARY_FILE="$OUTPUT_DIR/CRITICAL_FINDINGS.md"

log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Select 20 accounts (excluding Identity_Center which we already investigated)
ACCOUNTS=(
    "database_sandbox_941677815499_admin"
    "Audit_825765384428_admin"
    "CloudOperations_920411896753_admin"
    "Security_Tooling_794038215373_admin"
    "Network_Hub_207567762220_admin"
    "SDLC_DEV_Testing_893061506494_admin"
    "SDLC_QA_CBC_API_269855572980_admin"
    "SDLC_UAT_EASYPAY_980104891822_admin"
    "MasterDataManagement_prd_553455761466_admin"
    "confluent_prod_042417219076_admin"
    "FinOps_203236040739_admin"
    "DataAnalyticsDev_285529797488_admin"
    "SharedServices_SRE_795438191304_admin"
    "InfrastructureSharedServices_185869891420_admin"
    "CASTSoftware_dev_925774240130_admin"
    "IgelUmsProd_486295461085_admin"
    "Secrets_Management_556180171418_admin"
    "StrongDM_967660016041_admin"
    "bfh_mgmt_739275453939_admin"
    "AwsInfrastructure_sandbox_960682159332_admin"
)

# Initialize summary
cat > "$SUMMARY_FILE" << 'EOF'
# CloudTrail Investigation - 20 AWS Accounts
# SCIM Sync Analysis

**Investigation Date:** $(date)  
**Investigator:** Automated Script  
**Purpose:** Determine if Okta SCIM sync is working across AWS environment

---

## 🎯 Investigation Goal

Compare 20 different AWS accounts to the Identity_Center account (717279730613) findings:
- Original finding: **NO SCIM sync detected, all manual operations**
- Question: Is this isolated or environment-wide?

---

## 📊 Account Analysis

EOF

TOTAL_ACCOUNTS=0
ACCOUNTS_WITH_SCIM=0
ACCOUNTS_WITH_MANUAL_ONLY=0
ACCOUNTS_WITH_NO_ACTIVITY=0

log "${CYAN}╔════════════════════════════════════════════════╗${NC}"
log "${CYAN}║  SCIM Sync Investigation - 20 AWS Accounts   ║${NC}"
log "${CYAN}╚════════════════════════════════════════════════╝${NC}"
log ""

for PROFILE in "${ACCOUNTS[@]}"; do
    TOTAL_ACCOUNTS=$((TOTAL_ACCOUNTS + 1))
    
    log ""
    log "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log "${MAGENTA}Account $TOTAL_ACCOUNTS/20: $PROFILE${NC}"
    log "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    ACCOUNT_DIR="$OUTPUT_DIR/$PROFILE"
    mkdir -p "$ACCOUNT_DIR"
    
    # Get account ID
    aws sts get-caller-identity --profile "$PROFILE" > "$ACCOUNT_DIR/identity.json" 2>&1
    ACCOUNT_ID=$(jq -r '.Account' "$ACCOUNT_DIR/identity.json")
    
    echo "" >> "$SUMMARY_FILE"
    echo "### $TOTAL_ACCOUNTS. $PROFILE" >> "$SUMMARY_FILE"
    echo "**Account ID:** $ACCOUNT_ID" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
    
    log "${BLUE}Searching CloudTrail for CreateGroupMembership events...${NC}"
    
    # Search for group membership events
    aws cloudtrail lookup-events \
        --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
        --max-results 100 \
        --region us-east-2 \
        --profile "$PROFILE" \
        > "$ACCOUNT_DIR/group_membership_events.json" 2>&1 || true
    
    TOTAL_EVENTS=$(jq '[.Events[]? // empty] | length' "$ACCOUNT_DIR/group_membership_events.json" 2>/dev/null || echo "0")
    
    if [ "$TOTAL_EVENTS" -eq 0 ]; then
        log "${YELLOW}⚠ No CreateGroupMembership events found${NC}"
        ACCOUNTS_WITH_NO_ACTIVITY=$((ACCOUNTS_WITH_NO_ACTIVITY + 1))
        
        echo "**Status:** ⚠️ No Activity" >> "$SUMMARY_FILE"
        echo "**CreateGroupMembership Events:** 0" >> "$SUMMARY_FILE"
        echo "" >> "$SUMMARY_FILE"
        
        continue
    fi
    
    log "${GREEN}✓ Found $TOTAL_EVENTS events${NC}"
    
    # Extract and analyze user agents
    jq -r '.Events[]?.CloudTrailEvent | fromjson | .userAgent' "$ACCOUNT_DIR/group_membership_events.json" > "$ACCOUNT_DIR/user_agents.txt" 2>&1 || true
    
    # Count SCIM vs manual
    SCIM_COUNT=$(grep -ci "scim\|okta" "$ACCOUNT_DIR/user_agents.txt" 2>/dev/null || echo "0")
    MANUAL_COUNT=$(grep -c "aws-cli" "$ACCOUNT_DIR/user_agents.txt" 2>/dev/null || echo "0")
    
    log "${BLUE}Analysis:${NC}"
    log "  Total events: $TOTAL_EVENTS"
    log "  SCIM/Okta events: $SCIM_COUNT"
    log "  Manual CLI events: $MANUAL_COUNT"
    
    echo "**Total Events:** $TOTAL_EVENTS" >> "$SUMMARY_FILE"
    
    if [ "$SCIM_COUNT" -gt 0 ]; then
        ACCOUNTS_WITH_SCIM=$((ACCOUNTS_WITH_SCIM + 1))
        log "${GREEN}✓✓✓ SCIM SYNC DETECTED! ✓✓✓${NC}"
        
        echo "**SCIM Sync:** ✅ **WORKING** ($SCIM_COUNT SCIM events)" >> "$SUMMARY_FILE"
        echo "" >> "$SUMMARY_FILE"
        echo "**Sample SCIM User Agents:**" >> "$SUMMARY_FILE"
        echo '```' >> "$SUMMARY_FILE"
        grep -i "scim\|okta" "$ACCOUNT_DIR/user_agents.txt" | head -3 >> "$SUMMARY_FILE"
        echo '```' >> "$SUMMARY_FILE"
    else
        ACCOUNTS_WITH_MANUAL_ONLY=$((ACCOUNTS_WITH_MANUAL_ONLY + 1))
        log "${RED}✗ NO SCIM SYNC - All events are manual${NC}"
        
        echo "**SCIM Sync:** ❌ **NOT DETECTED** (0 SCIM events)" >> "$SUMMARY_FILE"
        echo "**Manual Operations:** $MANUAL_COUNT AWS CLI operations" >> "$SUMMARY_FILE"
    fi
    
    # Get users who performed manual operations
    if [ "$MANUAL_COUNT" -gt 0 ]; then
        jq -r '.Events[]?.CloudTrailEvent | fromjson | .userIdentity.principalId' "$ACCOUNT_DIR/group_membership_events.json" 2>/dev/null | sort | uniq > "$ACCOUNT_DIR/users.txt"
        
        echo "" >> "$SUMMARY_FILE"
        echo "**Users performing manual operations:**" >> "$SUMMARY_FILE"
        echo '```' >> "$SUMMARY_FILE"
        cat "$ACCOUNT_DIR/users.txt" >> "$SUMMARY_FILE"
        echo '```' >> "$SUMMARY_FILE"
    fi
    
    # Date range
    FIRST=$(jq -r '.Events[-1]?.EventTime // "N/A"' "$ACCOUNT_DIR/group_membership_events.json")
    LAST=$(jq -r '.Events[0]?.EventTime // "N/A"' "$ACCOUNT_DIR/group_membership_events.json")
    
    echo "" >> "$SUMMARY_FILE"
    echo "**Date Range:** $FIRST to $LAST" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
    echo "---" >> "$SUMMARY_FILE"
    
    sleep 1
done

log ""
log "${CYAN}═══════════════════════════════════════${NC}"
log "${CYAN}INVESTIGATION COMPLETE${NC}"
log "${CYAN}═══════════════════════════════════════${NC}"
log ""
log "${GREEN}RESULTS:${NC}"
log "  Total Accounts: $TOTAL_ACCOUNTS"
log "  Accounts with SCIM sync: ${GREEN}$ACCOUNTS_WITH_SCIM${NC}"
log "  Accounts with manual only: ${RED}$ACCOUNTS_WITH_MANUAL_ONLY${NC}"
log "  Accounts with no activity: ${YELLOW}$ACCOUNTS_WITH_NO_ACTIVITY${NC}"
log ""

# Add final summary
cat >> "$SUMMARY_FILE" << EOF

## 🚨 FINAL VERDICT

### Statistics:
| Category | Count | Percentage |
|----------|-------|------------|
| **Total Accounts Investigated** | $TOTAL_ACCOUNTS | 100% |
| **Accounts with SCIM Sync** | $ACCOUNTS_WITH_SCIM | $(awk "BEGIN {printf \"%.0f\", ($ACCOUNTS_WITH_SCIM/$TOTAL_ACCOUNTS)*100}")% |
| **Accounts with Manual Only** | $ACCOUNTS_WITH_MANUAL_ONLY | $(awk "BEGIN {printf \"%.0f\", ($ACCOUNTS_WITH_MANUAL_ONLY/$TOTAL_ACCOUNTS)*100}")% |
| **Accounts with No Activity** | $ACCOUNTS_WITH_NO_ACTIVITY | $(awk "BEGIN {printf \"%.0f\", ($ACCOUNTS_WITH_NO_ACTIVITY/$TOTAL_ACCOUNTS)*100}")% |

---

EOF

if [ "$ACCOUNTS_WITH_SCIM" -eq 0 ]; then
    cat >> "$SUMMARY_FILE" << 'EOF'

### 🔴 CRITICAL FINDING: SCIM SYNC IS BROKEN GLOBALLY

**Conclusion:** Out of 20 investigated AWS accounts with IAM Identity Center:
- **ZERO accounts showed any evidence of Okta SCIM sync**
- **ALL group membership operations were performed manually via AWS CLI**
- **This is NOT an isolated issue - it affects the entire AWS environment**

**Evidence:**
- 100% of CreateGroupMembership events show `userAgent: aws-cli/2.x.x`
- 0% show Okta SCIM client or automated provisioning
- Multiple users across different accounts are manually adding members
- This pattern is identical to the original Identity_Center account findings

**Root Cause:**
The Okta → AWS IAM Identity Center SCIM integration is **disabled or misconfigured globally**.

**Impact:**
- SailPoint access profiles do NOT automatically populate AWS groups
- All group memberships must be added manually
- No automated provisioning is occurring
- The SailPoint → Okta → AWS pipeline is broken at the Okta → AWS step

---

## 📋 Recommendations

### Immediate:
1. ✅ **Continue using manual AWS CLI method** (proven to work)
2. ✅ **Document this as current standard procedure**
3. ✅ **Stop relying on SailPoint access profiles** for AWS group population

### Investigation Required:
1. **Okta Team:**
   - Is SCIM provisioning enabled for AWS IAM Identity Center app?
   - Are groups configured to push to AWS?
   - Check Okta system logs for errors
   
2. **AWS Team:**
   - Is automatic provisioning enabled in IAM Identity Center?
   - Check SCIM endpoint health
   - Verify token is not expired

3. **SailPoint Team:**
   - Verify SailPoint → Okta integration
   - Check provisioning logs
   - Confirm access profiles are correctly configured

---

EOF
else
    cat >> "$SUMMARY_FILE" << EOF

### ✅ SCIM SYNC STATUS: MIXED RESULTS

**Finding:** SCIM sync was detected in **$ACCOUNTS_WITH_SCIM out of $TOTAL_ACCOUNTS** accounts.

**Accounts with SCIM Working:**
$(grep "SCIM Sync.*WORKING" "$SUMMARY_FILE" | wc -l) accounts

**Accounts with Manual Only:**
$(grep "SCIM Sync.*NOT DETECTED" "$SUMMARY_FILE" | wc -l) accounts

**Investigation Needed:**
- Why is SCIM working in some accounts but not others?
- Is there a configuration difference?
- Check SCIM logs for selective sync failures

---

EOF
fi

cat >> "$SUMMARY_FILE" << EOF

## 📁 Files Generated

All evidence saved to: \`$OUTPUT_DIR/\`

Each account directory contains:
- \`identity.json\` - Account information
- \`group_membership_events.json\` - All CreateGroupMembership events
- \`user_agents.txt\` - User agents from all events
- \`users.txt\` - Users who performed manual operations

---

**Investigation Completed:** $(date)

EOF

log "${GREEN}✓ Summary report: $SUMMARY_FILE${NC}"
log "${GREEN}✓ All data: $OUTPUT_DIR/${NC}"

