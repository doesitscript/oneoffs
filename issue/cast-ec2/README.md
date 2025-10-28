# CAST EC2 Infrastructure Adaptation

## Overview

This document captures the complete adaptation of Sanjeev's Varonis EC2 configuration for the CAST team's requirements. The adaptation focused on extracting hardcoded values into variables while preserving proven cross-account dependencies and networking configurations.

## Key Decisions Made

### 1. Foundation Choice: Varonis Configuration
**Decision**: Use Sanjeev's Varonis configuration as the foundation rather than experimental CAST_PERSONAL work or manual dump.

**Rationale**:
- Varonis config has proven cross-account dependencies
- More stable and production-tested approach
- Better networking configuration (corporate network vs personal IP)
- Includes proper domain join and secrets management

### 2. Variable Extraction Strategy
**Decision**: Extract hardcoded values into variables for CAST-specific customization.

**Values Replaced**:
- `name_prefix`: "varonis" → "cast"
- `env`: "Production" → "dev" (from CASTSoftware-dev account)
- `domain_join_user_data`: "brd03w255,prod" → "brd26w080n1,dev"

### 3. Cross-Account Resources Preserved
**Decision**: Keep all cross-account dependencies from SharedServices-imagemanagement account.

**Resources Maintained**:
- **AMI Access**: Account `422228628991` (SharedServices-imagemanagement)
- **Secrets Manager**: Domain join secrets from `422228628991`
- **VPC/Subnet**: Local to CAST account (925774240130)

## Resource Configuration Comparison

### Instance Specifications

| **Resource** | **CAST Manual (Working)** | **Varonis Original** | **CAST Adapted** |
|--------------|---------------------------|---------------------|------------------|
| **Instance Type** | `r5a.2xlarge` (8 vCPU, 64GB) | `m5.8xlarge` (32 vCPU, 128GB) | `m5.8xlarge` ✅ |
| **Root Drive** | 80GB gp2 | 250GB gp3 | 250GB gp3 ✅ |
| **Second Drive** | 500GB gp3 | **MISSING** ❌ | 500GB gp3 ✅ |
| **AMI Source** | `ami-0684b1bd72f4b0d55` | Latest from `422228628991` | Latest from `422228628991` ✅ |

### Security Groups

| **Access Type** | **CAST Manual (Working)** | **Varonis Original** | **CAST Adapted** |
|-----------------|---------------------------|---------------------|------------------|
| **RDP (3389)** | `163.116.249.49/32` (personal IP) | `10.0.0.0/8` (corporate) | `10.0.0.0/8` ✅ |
| **HTTPS (443)** | **NOT CONFIGURED** ❌ | `10.0.0.0/8` (corporate) | `10.0.0.0/8` ✅ |
| **Egress** | `0.0.0.0/0` | `0.0.0.0/0` | `0.0.0.0/0` ✅ |

### Domain Join & User Data

| **Configuration** | **CAST Manual (Working)** | **Varonis Original** | **CAST Adapted** |
|-------------------|---------------------------|---------------------|------------------|
| **Domain Join** | **NOT CONFIGURED** ❌ | `"brd03w255,prod"` | `"brd26w080n1,dev"` ✅ |
| **SSH Setup** | Full PowerShell script | **NOT CONFIGURED** ❌ | **NOT CONFIGURED** ❌ |

### IAM Configuration

| **Resource** | **CAST Manual (Working)** | **Varonis Original** | **CAST Adapted** |
|--------------|---------------------------|---------------------|------------------|
| **Instance Profile** | `bf-global-devonly-AmazonSSMManagedInstanceCore` | Custom Varonis profile | Custom CAST profile ✅ |
| **Secrets Access** | **NOT CONFIGURED** ❌ | Full Secrets Manager access | Full Secrets Manager access ✅ |
| **CloudWatch** | **NOT CONFIGURED** ❌ | Full CloudWatch access | Full CloudWatch access ✅ |

## Key Improvements Made

### 1. Second Drive Configuration
**Problem**: Varonis config was missing the 500GB second drive that CAST requires.

**Solution**: Added configurable second drive with variables:
- `second_drive_size` (default: 500GB)
- `second_drive_type` (default: gp3)
- `second_drive_device_name` (default: /dev/sdf)

**Benefits**:
- Easy to upgrade drive size (500GB → 1000GB)
- Can switch to high-performance drives (gp3 → io2)
- Can change device names if conflicts occur
- All configuration in tfvars file

### 2. Networking Configuration
**Problem**: CAST manual instance used personal IP (`163.116.249.49/32`) for RDP access.

**Solution**: Adopted Varonis approach with corporate network access (`10.0.0.0/8`).

**Benefits**:
- More scalable for team access
- Works from any corporate network location
- Includes HTTPS access for Windows updates/services
- Production-ready configuration

### 3. Domain Join Integration
**Problem**: CAST manual instance had no domain join configuration.

**Solution**: Implemented proper domain join with CAST-specific values.

**Configuration**:
- Hostname: `brd26w080n1`
- Environment: `dev`
- Secrets access to SharedServices-imagemanagement account

## File Structure

```
components/cast/
├── main.tf                 # Main EC2 instance and EBS volumes
├── iam.tf                  # IAM roles, policies, and instance profile
├── data.tf                 # Data sources for VPC, subnet, AMI
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── backend_local.tf        # Local backend configuration
├── README.md               # Component documentation
└── cast.tfvars.example     # Example configuration file
```

## Configuration Examples

### Standard Configuration (matches working instance)
```hcl
second_drive_size        = 500
second_drive_type        = "gp3"
second_drive_device_name = "/dev/sdf"
```

### Upgrade to 1000GB
```hcl
second_drive_size = 1000
```

### High-Performance Drive
```hcl
second_drive_type = "io2"
```

### Different Device Name
```hcl
second_drive_device_name = "/dev/sdg"
```

## Target Account Information

- **Account Name**: CASTSoftware-dev
- **Account ID**: 925774240130
- **Email**: AwsAccount+CASTSoftware-dev@breadfinancial.com
- **Environment**: dev (extracted from account name)

## Cross-Account Dependencies

### SharedServices-imagemanagement Account (422228628991)
- **AMI Images**: Windows images with `amidistribution*` filter
- **Secrets Manager**: Domain join secrets (`BreadDomainSecret-CORP*`)
- **Access**: Read-only access for AMI and secrets

### Local CAST Account (925774240130)
- **VPC/Subnet**: Local data sources
- **Security Groups**: Local configuration
- **IAM Roles**: Local instance profile and policies

## Status

✅ **MVP Variable Extraction Complete**
- All hardcoded values extracted to variables
- Second drive made configurable
- Networking uses corporate access
- Cross-account dependencies preserved

**Next Steps**:
- Create tfvars file with CAST values
- Verify networking configuration
- Ready for testing when user is ready

## Related Documents

- `DECISIONS_adapted.md` - Detailed decision tracking
- `COMMS_team.md` - Team communication items
- `RESEARCH_self.md` - Research items and questions
- `STATUS_updates.md` - Progress tracking and journal entries
