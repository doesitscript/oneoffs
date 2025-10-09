# VPC CIDR Scan Results Summary

## Scan Overview
- **Regions Scanned**: us-east-2 (ue2), us-west-2 (uw2)
- **Accounts Scanned**: 
  - CASTSoftware_dev_925774240130_admin
  - Network_Hub_207567762220_admin
- **Scan Date**: $(date)

## Key Findings

### 1. CAST Software Dev Account (925774240130)

#### us-east-2 Region:
- **castsoftwaredev VPC**: `10.62.20.0/24` ✅ **INSIDE /14 RANGE**
  - Subnets: Multiple /26 and /28 subnets within 10.62.17.x and 10.62.20.x ranges
  - Status: **GOOD** - Falls within Stephen's proposed 10.60.0.0/14 range
  - Does NOT match Jared's exact /16 (10.60.0.0/16) but is within the broader /14

#### us-west-2 Region:
- **castsoftwaredev VPC**: `10.162.20.0/24` ✅ **INSIDE /14 RANGE**
  - Subnets: Multiple /26 and /28 subnets within 10.162.17.x and 10.162.20.x ranges
  - Status: **GOOD** - Falls within Stephen's proposed 10.160.0.0/14 range
  - Does NOT match Jared's exact /16 (10.160.0.0/16) but is within the broader /14

### 2. Network Hub Account (207567762220)

#### us-east-2 Region:
- **Centralized-Inbound VPC**: `10.62.9.0/24` ✅ **INSIDE /14 RANGE**
- **Inspection-Inbound VPC**: `10.62.1.0/24` ✅ **INSIDE /14 RANGE**
- **Inspection VPC**: `10.62.0.0/24` ✅ **INSIDE /14 RANGE**
- **DNS VPC**: `10.62.10.0/24` ✅ **INSIDE /14 RANGE**

#### us-west-2 Region:
- **Centralized-Inbound VPC**: `10.162.8.0/24` ✅ **INSIDE /14 RANGE**
- **Inspection-Inbound VPC**: `10.162.1.0/24` ✅ **INSIDE /14 RANGE**
- **Inspection VPC**: `10.162.0.0/24` ✅ **INSIDE /14 RANGE**
- **DNS VPC**: `10.162.10.0/24` ✅ **INSIDE /14 RANGE**

## Analysis Summary

### ✅ **GOOD NEWS - All VPCs are within expected /14 ranges**

**Stephen's /14 Proposal Coverage:**
- **10.60.0.0/14** (covers 10.60.0.0 - 10.63.255.255): ✅ All us-east-2 VPCs fall within this range
- **10.160.0.0/14** (covers 10.160.0.0 - 10.163.255.255): ✅ All us-west-2 VPCs fall within this range

**Jared's /16 Proposal Status:**
- **10.60.0.0/16** (covers 10.60.0.0 - 10.60.255.255): ❌ No VPCs use this exact range
- **10.160.0.0/16** (covers 10.160.0.0 - 10.160.255.255): ❌ No VPCs use this exact range

### 🔍 **Detailed CIDR Usage**

#### us-east-2 (10.60.0.0/14 range):
- 10.62.0.0/24 - Network Hub Inspection
- 10.62.1.0/24 - Network Hub Inspection-Inbound  
- 10.62.9.0/24 - Network Hub Centralized-Inbound
- 10.62.10.0/24 - Network Hub DNS
- 10.62.17.64/26 - CAST Software TGW subnet
- 10.62.20.0/24 - CAST Software main VPC

#### us-west-2 (10.160.0.0/14 range):
- 10.162.0.0/24 - Network Hub Inspection
- 10.162.1.0/24 - Network Hub Inspection-Inbound
- 10.162.8.0/24 - Network Hub Centralized-Inbound  
- 10.162.9.0/24 - Network Hub additional range
- 10.162.10.0/24 - Network Hub DNS
- 10.162.17.64/26 - CAST Software TGW subnet
- 10.162.20.0/24 - CAST Software main VPC

### 🚨 **No Conflicts Detected**
- ✅ No overlaps with on-premises ranges (10.91.x.x, 10.131.x.x)
- ✅ All CIDRs fall within expected /14 ranges
- ✅ No CIDRs outside expected ranges

## Firewall Rule Implications

### **Current State Analysis:**
1. **Stephen's /14 ranges are sufficient** - All current VPCs fall within these ranges
2. **Jared's /16 ranges are too narrow** - Current infrastructure uses broader ranges
3. **Subnet-level precision is possible** - Most VPCs use /24 ranges, allowing for more precise firewall rules

### **Recommended Firewall Rules:**
Instead of "all traffic" rules, you can request more precise rules:

**For us-east-2:**
- `10.62.0.0/24` - Network Hub Inspection
- `10.62.1.0/24` - Network Hub Inspection-Inbound
- `10.62.9.0/24` - Network Hub Centralized-Inbound
- `10.62.10.0/24` - Network Hub DNS
- `10.62.17.64/26` - CAST Software TGW
- `10.62.20.0/24` - CAST Software main

**For us-west-2:**
- `10.162.0.0/24` - Network Hub Inspection
- `10.162.1.0/24` - Network Hub Inspection-Inbound
- `10.162.8.0/24` - Network Hub Centralized-Inbound
- `10.162.9.0/24` - Network Hub additional
- `10.162.10.0/24` - Network Hub DNS
- `10.162.17.64/26` - CAST Software TGW
- `10.162.20.0/24` - CAST Software main

## Next Steps

1. **✅ Stephen's /14 proposal is validated** - All infrastructure fits within these ranges
2. **❌ Jared's /16 proposal needs adjustment** - Current infrastructure uses broader ranges
3. **🎯 Request precise firewall rules** - Use the specific /24 and /26 ranges listed above
4. **📋 Document exceptions** - Any future VPCs should be planned within the /14 ranges

## Control Tower VPCs
- Multiple `172.31.0.0/16` VPCs found (AWS Control Tower default)
- These are outside expected ranges but are AWS-managed infrastructure
- No action needed for these as they're AWS internal

