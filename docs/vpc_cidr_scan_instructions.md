# VPC CIDR Scanner Instructions

## Overview
This document provides instructions for scanning AWS VPC CIDR allocations in the specified regions (us-east-2 and us-west-2) to verify which CIDRs are actually provisioned and compare them against expected ranges.

## Scripts Available

### 1. `scan_vpc_cidrs.sh` - Basic Scanner
- Scans VPCs in us-east-2 and us-west-2 regions
- Compares CIDRs against expected /14 and /16 ranges
- Checks for overlaps with on-prem ranges
- Outputs results in table format

### 2. `scan_vpc_cidrs_advanced.sh` - Advanced Scanner
- Includes all features of the basic scanner
- Additionally provides subnet information for each VPC
- More detailed CIDR analysis
- Better error handling

## Prerequisites

### AWS CLI Configuration
Before running the scripts, ensure AWS CLI is configured with appropriate credentials:

```bash
# Option 1: AWS Configure
aws configure

# Option 2: AWS SSO
aws configure sso

# Option 3: Environment Variables
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-east-2

# Option 4: IAM Role (if running on EC2)
# No additional configuration needed
```

### Required Permissions
The AWS credentials must have the following permissions:
- `ec2:DescribeVpcs`
- `ec2:DescribeSubnets` (for advanced scanner)
- `sts:GetCallerIdentity`

## Expected CIDR Ranges

### /14 Ranges (Stephen's proposal)
- `10.60.0.0/14` (covers 10.60.0.0 - 10.63.255.255)
- `10.160.0.0/14` (covers 10.160.0.0 - 10.163.255.255)

### /16 Ranges (Jared's proposal)
- `10.60.0.0/16` (covers 10.60.0.0 - 10.60.255.255)
- `10.160.0.0/16` (covers 10.160.0.0 - 10.160.255.255)

### On-Premises Ranges (to avoid conflicts)
- `10.91.0.0/16` (covers 10.91.0.0 - 10.91.255.255)
- `10.131.0.0/16` (covers 10.131.0.0 - 10.131.255.255)

## Usage

### Basic Scanner
```bash
./scripts/scan_vpc_cidrs.sh
```

### Advanced Scanner
```bash
./scripts/scan_vpc_cidrs_advanced.sh
```

## Output Format

The scripts output a table with the following columns:

| Column | Description |
|--------|-------------|
| Account | AWS Account ID |
| Region | AWS Region (us-east-2 or us-west-2) |
| VPC Name/ID | VPC Name tag or VPC ID if no name |
| CIDR(s) | Primary and secondary CIDR blocks |
| Inside /14? | YES/NO - whether CIDR falls within expected /14 ranges |
| Matches Jared's /16? | YES/NO - whether CIDR matches Jared's proposed /16 ranges |
| Notes | Additional information (overlaps, conflicts, exceptions) |
| Subnets | Subnet information (advanced scanner only) |

## Notes Field Values

- `OK` - No issues detected
- `OVERLAP_ONPREM` - CIDR overlaps with on-premises ranges
- `OUTSIDE_EXPECTED_RANGES` - CIDR falls outside expected /14 ranges

## Troubleshooting

### AWS Credentials Not Configured
```
ERROR: AWS credentials not configured. Please run 'aws configure' or set AWS environment variables.
```
**Solution**: Configure AWS credentials using one of the methods listed in Prerequisites.

### No VPCs Found
If the script runs but shows no results, it could mean:
- No VPCs exist in the specified regions
- Insufficient permissions to describe VPCs
- AWS CLI is not properly configured

### Permission Denied
```
An error occurred (UnauthorizedOperation) when calling the DescribeVpcs operation
```
**Solution**: Ensure the AWS credentials have the required permissions listed in Prerequisites.

## Example Output

```
Account|Region|VPC Name/ID|CIDR(s)|Inside /14?|Matches Jared's /16?|Notes|Subnets
-------|------|-----------|-------|-----------|-------------------|-----|--------
123456789012|us-east-2|production-vpc|10.60.0.0/16|YES|YES|OK|subnet-123:10.60.1.0/24:public;subnet-456:10.60.2.0/24:private
123456789012|us-west-2|staging-vpc|10.160.0.0/16|YES|YES|OK|subnet-789:10.160.1.0/24:public
```

## Analysis Guidelines

1. **CIDRs Inside /14 Ranges**: These are acceptable and fall within Stephen's proposed ranges
2. **CIDRs Matching /16 Ranges**: These exactly match Jared's proposed ranges
3. **CIDRs Outside Expected Ranges**: These may need attention or justification
4. **On-Premises Overlaps**: These are critical conflicts that must be resolved
5. **Subnet Information**: Use this to identify if more precise CIDR requests are possible

## Next Steps

After running the scan:
1. Review any CIDRs marked as `OUTSIDE_EXPECTED_RANGES`
2. Investigate any `OVERLAP_ONPREM` conflicts
3. Consider if subnet-level analysis allows for more precise firewall rules
4. Document any exceptions or special cases
5. Update firewall rules based on actual CIDR usage

