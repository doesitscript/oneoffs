# CAST EC2 Adaptation Decisions

## Decision 1: Use Teammate's Varonis Configuration as Foundation
**Date**: Current session  
**Decision**: Adapt Sanjeev's Varonis Terraform configuration rather than starting from scratch or using experimental CAST_PERSONAL work.

**Rationale**:
- Varonis config has proven cross-account dependencies and complex resources
- CAST_PERSONAL contains experimental/learning attempts that may not apply
- CAST_MANUAL_DUMP provides real-world values but lacks the infrastructure complexity needed

**Cross-Account Resources to Preserve**:
- AMI from account `422228628991` (customer-image-mgmt)
- Secrets Manager access to `422228628991` account
- Domain join parameters in user data

**Complex Resources to Preserve**:
- SSH key management (TLS generation + Secrets Manager)
- Multi-volume configuration (C: and D: drives)
- Advanced security groups with CIDR controls
- Instance protection settings

## Decision 2: Variable-Based Value Replacement Strategy
**Date**: Current session  
**Decision**: Focus on extracting hardcoded values into variables and replacing them with CAST-specific values.

**Scope**:
- **Target**: Replace Varonis-specific parameters/inputs with CAST values
- **Exclude**: Resource names (keep existing naming patterns)
- **Approach**: Variable extraction → CAST value assignment → tfvars creation

**Key Values to Replace**:
- Domain join user data: `"brd03w255,prod"` → `"brd26w080n1,dev"` (Windows hostname,environment)
- Instance specifications: Size, type, volume configs
- Security group CIDR blocks
- IAM policy resource ARNs

**Cross-Account Resources to Keep (No Changes)**:

1. **AMI Access** (`main.tf` lines 72-90):
   - Account: `422228628991` (SharedServices-imagemanagement)
   - AMI filter: `amidistribution*` Windows images
   - Line 74: `owners = ["422228628991"]` (teammate labeled as "customer-image-mgmt account")

2. **Secrets Manager Access** (`iam.tf` lines 62-88):
   - Account: `422228628991` (SharedServices-imagemanagement) 
   - Secret pattern: `BreadDomainSecret-CORP*`
   - Line 75: `Resource = "arn:aws:secretsmanager:*:422228628991:secret:BreadDomainSecret-CORP*"`
   - Actions: `secretsmanager:GetSecretValue`, `secretsmanager:DescribeSecret`
   - Note: Teammate labeled as "customer-image-mgmt" but correct name is "SharedServices-imagemanagement"

3. **VPC/Subnet Data Sources** (`data.tf` lines 5-22):
   - VPC lookup by tag: `tag:Name = "${local.app}${local.env}"`
   - Subnet selection: First available subnet in VPC
   - Note: User has implemented different approach (lines 12-15) with same outcome

**Target Account**:
- **Account Name**: CASTSoftware-dev
- **Account ID**: 925774240130
- **Email**: AwsAccount+CASTSoftware-dev@breadfinancial.com
- **AWS Profile**: [To be determined from AWS config - matches account 925774240130]

**Outcome**: Minimal viable product focused on value substitution rather than architectural changes.

## Decision 3: Server Specifications and Variable Strategy
**Date**: Current session  
**Decision**: Implement selective variable extraction for known requirements while waiting for final server specifications.

**Known Requirements (Make Variables)**:
- **Domain join user data**: `"brd26w080n1,dev"` (Windows hostname,environment)
- **Second drive requirement**: Minimum 500GB, fast drive type (gp3)
- **Instance type**: To be determined by CAST team specifications
- **Memory/RAM**: To be determined by CAST team specifications
- **Root drive size**: To be determined by CAST team specifications

**Current Varonis Values (Keep as Defaults)**:
- Instance type: `m5.8xlarge` (32 vCPUs, 128 GB RAM)
- Root drive: 250GB gp3
- Second drive: 500GB gp3 (already meets requirement)

**Variable Strategy**:
- **Extract now**: Domain join, drive requirements, basic networking
- **Keep hardcoded**: Instance specs until CAST team provides requirements
- **Document**: All current values as defaults with comments about pending specifications

**Implementation Note**: 
- Current Varonis config already has 500GB second drive (meets requirement)
- Need to ensure second drive is implemented (user's previous implementations lacked this)
- Focus on getting working MVP first, then optimize specs when requirements are finalized

## Decision 4: Networking Configuration Strategy
**Date**: Current session  
**Decision**: Use Sanjeev's Varonis networking configuration over user's experimental/troubleshooting approaches.

**Networking Analysis Results**:
- **Working CAST Instance**: Used specific IP `163.116.249.49/32` (user's personal IP during troubleshooting)
- **Sanjeev's Varonis Config**: Uses corporate network `10.0.0.0/8` for RDP and HTTPS access
- **User's CAST_PERSONAL**: Experimental work with various approaches (not production-ready)

**Decision**: Use Sanjeev's approach:
- **RDP Access**: `10.0.0.0/8` (corporate network)
- **HTTPS Access**: `10.0.0.0/8` (corporate network)
- **Egress**: `0.0.0.0/0` (all outbound traffic)

**Rationale**: Sanjeev's configuration is production-tested and designed for corporate network access, while user's specific IP was troubleshooting work.
