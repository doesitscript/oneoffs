# AWS CIDR Usage Verification Summary

## Scan Overview
- **Scan Date**: Thu Sep 25 05:22:50 CDT 2025
- **Network Hub Profile**: Network_Hub_207567762220_admin
- **Focused Regions**: us-east-2 us-west-2
- **Total VPCs Scanned**: 498
- **IPAM Allocations Found**: 0

## Key Findings

### IPAM vs Deployed CIDRs
- **CIDRs with IPAM allocations**: 0
0
- **CIDRs deployed without IPAM**: 498

### Range Compliance
- **CIDRs within expected /14 ranges**: 498
- **CIDRs outside expected ranges**: 0
0

### On-Premises Conflicts
- **CIDRs overlapping with on-premises**: 498

## Detailed Results
See `aws_cidr_verification_detailed.csv` for complete results.

## Recommendations
- **Action Required**: 498 CIDRs are deployed without IPAM allocations
- Consider creating IPAM allocations for these CIDRs to maintain proper tracking
- **Critical**: 498 CIDRs overlap with on-premises ranges
- These must be resolved immediately to prevent network conflicts
