# VPC CIDR Scan Results - Clean Summary

## Scan Results Table

| Account | Region | VPC Name/ID | CIDR(s) | Inside /14? | Matches Jared's /16? | Notes |
|---------|--------|-------------|---------|-------------|---------------------|-------|
| 925774240130 | us-east-2 | castsoftwaredev | 10.62.20.0/24 | YES | NO | Within Stephen's /14 range |
| 925774240130 | us-west-2 | castsoftwaredev | 10.162.20.0/24 | YES | NO | Within Stephen's /14 range |
| 207567762220 | us-east-2 | Centralized-Inbound | 10.62.9.0/24 | YES | NO | Within Stephen's /14 range |
| 207567762220 | us-east-2 | Inspection-Inbound | 10.62.1.0/24 | YES | NO | Within Stephen's /14 range |
| 207567762220 | us-east-2 | Inspection | 10.62.0.0/24 | YES | NO | Within Stephen's /14 range |
| 207567762220 | us-east-2 | DNS | 10.62.10.0/24 | YES | NO | Within Stephen's /14 range |
| 207567762220 | us-west-2 | Centralized-Inbound | 10.162.8.0/24 | YES | NO | Within Stephen's /14 range |
| 207567762220 | us-west-2 | Inspection-Inbound | 10.162.1.0/24 | YES | NO | Within Stephen's /14 range |
| 207567762220 | us-west-2 | Inspection | 10.162.0.0/24 | YES | NO | Within Stephen's /14 range |
| 207567762220 | us-west-2 | DNS | 10.162.10.0/24 | YES | NO | Within Stephen's /14 range |

## Key Findings

### ✅ **All VPCs are within expected /14 ranges**
- **Stephen's proposal (10.60.0.0/14, 10.160.0.0/14)**: ✅ **VALIDATED**
- **Jared's proposal (10.60.0.0/16, 10.160.0.0/16)**: ❌ **TOO NARROW**

### 🎯 **Precise Firewall Rules Possible**
Instead of "all traffic", you can request specific CIDR blocks:

**us-east-2 (10.60.0.0/14 range):**
- 10.62.0.0/24 - Network Hub Inspection
- 10.62.1.0/24 - Network Hub Inspection-Inbound
- 10.62.9.0/24 - Network Hub Centralized-Inbound
- 10.62.10.0/24 - Network Hub DNS
- 10.62.20.0/24 - CAST Software main

**us-west-2 (10.160.0.0/14 range):**
- 10.162.0.0/24 - Network Hub Inspection
- 10.162.1.0/24 - Network Hub Inspection-Inbound
- 10.162.8.0/24 - Network Hub Centralized-Inbound
- 10.162.10.0/24 - Network Hub DNS
- 10.162.20.0/24 - CAST Software main

### 🚨 **No Conflicts**
- No overlaps with on-premises ranges (10.91.x.x, 10.131.x.x)
- All CIDRs are properly contained within expected ranges

