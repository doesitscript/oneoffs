# AFT Three-Tier Customization Structure & SSM Parameter Usage Guide

## Executive Summary

This guide explains:
1. **How to set up the three-tier AFT customization structure** (Global, Account, Provisioning)
2. **Why SSM parameters were likely adopted but then abandoned** in your organization
3. **How SSM parameters are actually being used** vs. **how they should be used**
4. **Practical patterns** for reviving SSM parameter usage

---

## Part 1: Three-Tier Customization Structure

### Architecture Overview

AFT uses three distinct customization layers that execute at different stages of account lifecycle:

```
┌─────────────────────────────────────────────────────────┐
│  Account Request Submitted                              │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│  TIER 1: Account Provisioning Customizations            │
│  Repository: aft-account-provisioning-customizations    │
│  Execution: Step Functions (during account creation)    │
│  Scope: Pre-provisioning setup                         │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│  Account Created by Control Tower                      │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│  TIER 2: Global Customizations                          │
│  Repository: aft-global-customizations                  │
│  Execution: CodePipeline (after account creation)       │
│  Scope: All accounts - baseline configurations         │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│  TIER 3: Account Customizations                         │
│  Repository: aft-account-customizations                 │
│  Execution: CodePipeline (after global customizations)  │
│  Scope: Account-specific configurations                │
└─────────────────────────────────────────────────────────┘
```

### Tier 1: Account Provisioning Customizations

**Purpose**: Execute Step Functions during account creation, before global customizations

**Repository**: `aft-account-provisioning-customizations`
**SSM Path**: `/aft/config/account-provisioning-customizations/`

**Use Cases**:
- Custom IAM roles that need to exist before other customizations
- Initial account metadata setup
- Pre-provisioning guardrails
- Custom Step Function workflows

**Example Structure**:
```
aft-account-provisioning-customizations/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── states/
│       └── custom_provisioning_step_function.asl.json
└── README.md
```

**Key Configuration** (in AFT main module):
```hcl
variable "account_provisioning_customizations_repo_name" {
  default = "aft-account-provisioning-customizations"
}

variable "account_provisioning_customizations_repo_branch" {
  default = "main"
}
```

### Tier 2: Global Customizations

**Purpose**: Apply baseline configurations to ALL accounts

**Repository**: `aft-global-customizations`
**SSM Path**: `/aft/config/global-customizations/`

**Use Cases**:
- Security baselines (CloudTrail, GuardDuty, Config)
- Compliance policies
- IAM baseline roles
- Service Control Policies (SCPs)
- Cross-account guardrails
- Organization-wide tagging policies

**Example Structure**:
```
aft-global-customizations/
├── terraform/
│   ├── main.tf
│   ├── modules/
│   │   ├── security-baseline/
│   │   ├── compliance-policies/
│   │   └── iam-roles/
│   └── variables.tf
└── README.md
```

**Key Configuration**:
```hcl
variable "global_customizations_repo_name" {
  default = "aft-global-customizations"
}

variable "global_customizations_repo_branch" {
  default = "main"
}
```

### Tier 3: Account Customizations

**Purpose**: Apply environment or account-specific configurations

**Repository**: `aft-account-customizations`
**SSM Path**: `/aft/config/account-customizations/`

**Use Cases**:
- Environment-specific resources (DEV vs PROD)
- Account-specific VPC configurations
- Service-specific setups (Harness, Image Management, etc.)
- Custom resource allocations
- Account tagging
- OU-specific configurations

**Example Structure**:
```
aft-account-customizations/
├── foundation-customizations/
├── sdlc-dev-customizations/
├── sdlc-uat-customizations/
├── sharedservices-harness-customizations/
└── sharedservices-imagemanagement-customizations/
```

**Key Configuration**:
```hcl
variable "account_customizations_repo_name" {
  default = "aft-account-customizations"
}

variable "account_customizations_repo_branch" {
  default = "main"
}
```

### Setup Process

#### Step 1: Configure AFT Main Module

In your AFT management account Terraform configuration:

```hcl
module "aft" {
  source = "github.com/aws-ia/terraform-aws-control_tower_account_factory?ref=v1.12.0"

  # Repository Configuration
  global_customizations_repo_name   = "aft-global-customizations"
  global_customizations_repo_branch = "main"
  
  account_customizations_repo_name   = "aft-account-customizations"
  account_customizations_repo_branch = "main"
  
  account_provisioning_customizations_repo_name   = "aft-account-provisioning-customizations"
  account_provisioning_customizations_repo_branch = "main"
  
  # VCS Configuration
  vcs_provider = "github"  # or "codecommit", "gitlab"
  
  # ... other required variables
}
```

#### Step 2: Create Repository Structure

For **CodeCommit** (AWS native):
- AFT creates repositories automatically
- Default names are used

For **GitHub/GitLab**:
- Create repositories manually or via Terraform
- Ensure they match the names in your AFT configuration
- Set up proper access (CodeConnections, OAuth, etc.)

#### Step 3: Initialize Customization Repositories

**Global Customizations**:
```bash
cd /path/to/aft-global-customizations
mkdir -p terraform
cd terraform
# Initialize with your Terraform configuration
```

**Account Customizations**:
```bash
cd /path/to/aft-account-customizations
mkdir -p foundation-customizations/terraform
mkdir -p sdlc-dev-customizations/terraform
# ... etc
```

**Account Provisioning Customizations**:
```bash
cd /path/to/aft-account-provisioning-customizations
mkdir -p terraform/states
# Create Step Function definitions
```

#### Step 4: Verify SSM Parameters

After AFT deployment, verify SSM parameters are created:

```bash
# AFT Management Account
aws ssm get-parameter --name "/aft/config/global-customizations/repo-name"
aws ssm get-parameter --name "/aft/config/account-customizations/repo-name"
aws ssm get-parameter --name "/aft/config/account-provisioning-customizations/repo-name"
```

---

## Part 2: SSM Parameter Usage Analysis

### How SSM Parameters Are Intended to Be Used

#### Category A: AFT Framework Parameters

**Created by**: AFT framework itself
**Location**: AFT Management Account
**Purpose**: Store AFT configuration and resource references

**Key Parameters**:
```
/aft/config/terraform/version
/aft/config/terraform/distribution
/aft/config/vcs/provider
/aft/config/global-customizations/repo-name
/aft/config/global-customizations/repo-branch
/aft/config/account-customizations/repo-name
/aft/config/account-customizations/repo-branch
/aft/config/account-provisioning-customizations/repo-name
/aft/config/account-provisioning-customizations/repo-branch
/aft/resources/sqs/aft-request-queue-name
/aft/resources/ddb/aft-request-table-name
/aft/account/aft-management/account-id
/aft/account/aft-management/sns/topic-arn
```

**Usage in Customizations**:
```hcl
# In customizations pipeline templates
data "aws_ssm_parameter" "aft_global_customizations_repo_name" {
  name = "/aft/config/global-customizations/repo-name"
}

data "aws_ssm_parameter" "aft_account_customizations_repo_name" {
  name = "/aft/config/account-customizations/repo-name"
}
```

#### Category B: Account Request Custom Fields

**Created by**: Account request process
**Location**: AFT Management Account (initially), then vended accounts
**Purpose**: Store metadata passed during account creation

**Key Parameters**:
```
/aft/account-request/custom-fields/{field_name}
/aft/account-request/customization_name
```

**Intended Usage**:
```hcl
# In account customizations
data "aws_ssm_parameters_by_path" "aft_custom_fields" {
  path = "/aft/account-request/custom-fields"
}

locals {
  aft_custom_fields = {
    for i, v in data.aws_ssm_parameters_by_path.aft_custom_fields.names :
    split("/", v)[4] => nonsensitive(
      data.aws_ssm_parameters_by_path.aft_custom_fields.values
    )[i]
  }
}

# Access specific field
data "aws_ssm_parameter" "environment" {
  name = "/aft/account-request/custom-fields/environment"
}

locals {
  environment = data.aws_ssm_parameter.environment.value
}
```

**Example Account Request**:
```hcl
# In aft-account-request repository
module "account_request" {
  source = "./modules/aft-account-request"
  
  account_name = "my-new-account"
  account_email = "aws+my-new-account@example.com"
  
  custom_fields = {
    environment = "production"
    cost_center = "engineering"
    team = "platform"
  }
}
```

#### Category C: Organization-Wide Parameters

**Created by**: Your organization (manually or via Terraform)
**Location**: Each account (replicated)
**Purpose**: Cross-account configuration sharing

**Your Current Parameters** (from your codebase):
```
/organization/network-hub-account-id
/organization/key-management-account-id
/organization/sdlc-name-1
/organization/sdlc-name-2
/organization/sdlc-name-3
/organization/sdlc-name-4
/organization/sdlc-1-org-unit-id
/organization/sdlc-2-org-unit-id
/organization/sdlc-3-org-unit-id
/organization/sdlc-4-org-unit-id
/organization/sre-account-id
```

**Your Current Usage** (minimal):
```hcl
# From sdlc-uat-customizations/terraform/data.tf
data "aws_ssm_parameter" "network_hub_acct_id" {
  name = "/organization/network-hub-account-id"
}

data "aws_ssm_parameter" "key_management_acct_id" {
  name = "/organization/key-management-account-id"
}
```

#### Category D: Platform Parameters

**Created by**: Your organization (Network Hub account)
**Location**: Network Hub account only
**Purpose**: Platform infrastructure references

**Your Parameters** (from project context):
```
/platform/tgw/* - Transit Gateway configuration
/platform/route53/* - Route53 resolver rules and hosted zones
/platform/ipam/* - IPAM pool IDs by region and environment
/platform/dns-vpc/* - DNS VPC configuration
```

### Why SSM Parameters Were Likely Abandoned

Based on the codebase analysis, here's what likely happened:

#### 1. Initial Adoption Enthusiasm
- SSM parameters were set up during initial AFT adoption
- Organization parameters were created for cross-account sharing
- Custom fields were planned but not fully implemented

#### 2. Practical Challenges
- **Cross-Account Access Complexity**: SSM parameters in Network Hub but needed in other accounts
- **Provider Alias Issues**: Your codebase shows provider alias mismatches
- **Documentation Gap**: Not clear how to use custom fields
- **Template Inconsistency**: Different customizations use different patterns

#### 3. Workarounds Developed
- Hard-coded account IDs instead of SSM lookups
- Direct provider references instead of SSM-based discovery
- Manual configuration instead of parameter-driven automation

#### 4. Abandonment
- SSM parameters exist but are rarely referenced
- Only basic organization parameters are used (network-hub, key-management)
- Custom fields (`/aft/account-request/custom-fields/*`) are not utilized
- AFT framework parameters are only used by AFT itself, not customizations

### Current State vs. Intended State

#### What You're Currently Using ✅

```hcl
# Minimal usage - basic org account IDs
data "aws_ssm_parameter" "network_hub_acct_id" {
  name = "/organization/network-hub-account-id"
}
```

#### What You Should Be Using 🎯

**1. Custom Fields for Environment Detection**:
```hcl
# In account customizations
data "aws_ssm_parameter" "environment" {
  name = "/aft/account-request/custom-fields/environment"
}

locals {
  environment = data.aws_ssm_parameter.environment.value
  is_prod = local.environment == "production"
}
```

**2. Dynamic Account Discovery**:
```hcl
# Instead of hardcoding, use SSM parameters
data "aws_ssm_parameter" "network_hub_account_id" {
  name = "/organization/network-hub-account-id"
}

provider "aws" {
  alias  = "hub"
  region = var.hub_region
  assume_role {
    role_arn = "arn:aws:iam::${data.aws_ssm_parameter.network_hub_account_id.value}:role/OrganizationAccountAccessRole"
  }
}
```

**3. Cross-Account Configuration Sharing**:
```hcl
# Platform parameters from Network Hub
data "aws_ssm_parameter" "tgw_main_id" {
  name     = "/platform/tgw/main-id"
  provider = aws.hub_main
}

# Use in local account
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  transit_gateway_id = data.aws_ssm_parameter.tgw_main_id.value
  # ...
}
```

**4. AFT Framework Integration**:
```hcl
# Access AFT management account info
data "aws_ssm_parameter" "aft_management_account_id" {
  name = "/aft/account/aft-management/account-id"
}

# Use for cross-account access
provider "aws" {
  alias  = "aft"
  region = var.aft_region
  assume_role {
    role_arn = "arn:aws:iam::${data.aws_ssm_parameter.aft_management_account_id.value}:role/AWSAFTExecution"
  }
}
```

---

## Part 3: Reviving SSM Parameter Usage

### Strategy 1: Incremental Adoption

#### Phase 1: Audit Current Parameters
```bash
# List all SSM parameters in AFT management account
aws ssm describe-parameters \
  --parameter-filters "Key=Path,Values=/aft/" \
  --query 'Parameters[*].Name' \
  --output table \
  --profile aft_admin_474668427263

# List organization parameters in a vended account
aws ssm describe-parameters \
  --parameter-filters "Key=Path,Values=/organization/" \
  --query 'Parameters[*].Name' \
  --output table \
  --profile <account_profile>
```

#### Phase 2: Document Parameter Inventory

Create a parameter inventory document:
```markdown
## SSM Parameter Inventory

### AFT Framework Parameters
- `/aft/config/terraform/version` - Terraform version used by AFT
- `/aft/config/global-customizations/repo-name` - Global customizations repo
- ...

### Organization Parameters
- `/organization/network-hub-account-id` - Network Hub account ID
- `/organization/sdlc-name-1` - SDLC environment 1 name
- ...

### Custom Fields (Currently Unused)
- `/aft/account-request/custom-fields/*` - Should be populated during account creation
```

#### Phase 3: Start Using Custom Fields

**Step 1**: Update account request templates to include custom fields:
```hcl
# In aft-account-request repository
module "sdlc_dev_account" {
  source = "./modules/aft-account-request"
  
  account_name = "sdlc-dev-${var.project_name}"
  
  custom_fields = {
    environment     = "development"
    sdlc_tier       = "1"
    cost_center     = "engineering"
    team            = var.team_name
    customization   = "sdlc-dev-customizations"
  }
}
```

**Step 2**: Use custom fields in account customizations:
```hcl
# In sdlc-dev-customizations/terraform/data.tf
data "aws_ssm_parameter" "environment" {
  name = "/aft/account-request/custom-fields/environment"
}

data "aws_ssm_parameter" "sdlc_tier" {
  name = "/aft/account-request/custom-fields/sdlc_tier"
}

locals {
  environment = data.aws_ssm_parameter.environment.value
  sdlc_tier   = data.aws_ssm_parameter.sdlc_tier.value
}
```

#### Phase 4: Replace Hard-Coded Values

**Before**:
```hcl
provider "aws" {
  alias  = "hub"
  region = "us-east-2"
  assume_role {
    role_arn = "arn:aws:iam::207567762220:role/OrganizationAccountAccessRole"
  }
}
```

**After**:
```hcl
data "aws_ssm_parameter" "network_hub_account_id" {
  name = "/organization/network-hub-account-id"
}

data "aws_ssm_parameter" "network_hub_region" {
  name = "/organization/network-hub-region"
}

provider "aws" {
  alias  = "hub"
  region = data.aws_ssm_parameter.network_hub_region.value
  assume_role {
    role_arn = "arn:aws:iam::${data.aws_ssm_parameter.network_hub_account_id.value}:role/OrganizationAccountAccessRole"
  }
}
```

### Strategy 2: Create Parameter Management Module

Create a reusable module for SSM parameter access:

```hcl
# modules/ssm-parameters/data.tf
data "aws_ssm_parameter" "network_hub_account_id" {
  name = "/organization/network-hub-account-id"
}

data "aws_ssm_parameter" "key_management_account_id" {
  name = "/organization/key-management-account-id"
}

data "aws_ssm_parameter" "aft_management_account_id" {
  name = "/aft/account/aft-management/account-id"
}

# Custom fields
data "aws_ssm_parameters_by_path" "custom_fields" {
  path = "/aft/account-request/custom-fields"
}

locals {
  custom_fields = {
    for i, v in data.aws_ssm_parameters_by_path.custom_fields.names :
    split("/", v)[4] => nonsensitive(
      data.aws_ssm_parameters_by_path.custom_fields.values
    )[i]
  }
}

# Platform parameters (from Network Hub)
data "aws_ssm_parameter" "tgw_main_id" {
  name     = "/platform/tgw/main-id"
  provider = aws.hub_main
}

data "aws_ssm_parameter" "tgw_region" {
  name     = "/platform/tgw/region"
  provider = aws.hub_main
}
```

**Usage**:
```hcl
module "org_params" {
  source = "./modules/ssm-parameters"
  
  providers = {
    aws.hub_main = aws.hub_main
  }
}

locals {
  network_hub_account_id = module.org_params.network_hub_account_id
  environment            = module.org_params.custom_fields["environment"]
  tgw_id                 = module.org_params.tgw_main_id
}
```

### Strategy 3: Establish Best Practices

#### Naming Convention
```
/aft/config/*                    - AFT framework configuration
/aft/resources/*                 - AFT framework resources
/aft/account/*                   - Account-specific AFT data
/aft/account-request/custom-fields/* - Custom fields from account request
/organization/*                  - Organization-wide parameters
/platform/*                      - Platform infrastructure (Network Hub)
```

#### Access Patterns
- **Read-only in customizations**: Use `data.aws_ssm_parameter`
- **Cross-account access**: Use provider aliases with assume role
- **Sensitive data**: Use `insecure_value` or `aws_secretsmanager_secret` instead

#### Documentation Requirements
- Document all custom parameters in a central location
- Include parameter purpose, location, and update procedures
- Version control parameter schemas

---

## Part 4: Implementation Checklist

### Setup Checklist

- [ ] **Configure AFT with three repositories**
  - [ ] Set `global_customizations_repo_name`
  - [ ] Set `account_customizations_repo_name`
  - [ ] Set `account_provisioning_customizations_repo_name`
  - [ ] Verify repositories exist and are accessible

- [ ] **Create Global Customizations Repository**
  - [ ] Initialize Terraform structure
  - [ ] Add security baseline modules
  - [ ] Add compliance policies
  - [ ] Test with one account

- [ ] **Organize Account Customizations**
  - [ ] Create directory structure per customization type
  - [ ] Migrate existing customizations to proper structure
  - [ ] Update AFT account requests to reference correct customizations

- [ ] **Set Up Account Provisioning Customizations** (if needed)
  - [ ] Create Step Function definitions
  - [ ] Add pre-provisioning tasks
  - [ ] Test provisioning workflow

### SSM Parameter Revival Checklist

- [ ] **Audit Existing Parameters**
  - [ ] List all `/aft/*` parameters
  - [ ] List all `/organization/*` parameters
  - [ ] Identify unused parameters
  - [ ] Document parameter purposes

- [ ] **Update Account Request Templates**
  - [ ] Add custom fields to account requests
  - [ ] Document custom field schema
  - [ ] Test account creation with custom fields

- [ ] **Update Customization Code**
  - [ ] Replace hard-coded account IDs with SSM lookups
  - [ ] Use custom fields for environment detection
  - [ ] Create parameter access modules
  - [ ] Update documentation

- [ ] **Establish Governance**
  - [ ] Create parameter naming standards
  - [ ] Document access patterns
  - [ ] Set up parameter review process
  - [ ] Create parameter inventory

---

## Conclusion

The three-tier customization structure provides a clear separation of concerns:
- **Provisioning**: Pre-account setup
- **Global**: Baseline for all accounts
- **Account**: Environment-specific configurations

SSM parameters are a powerful mechanism for cross-account configuration sharing, but they require:
1. **Proper setup** during account creation (custom fields)
2. **Consistent usage** across all customizations
3. **Documentation** of parameter schemas
4. **Governance** to prevent drift

By reviving SSM parameter usage, you can:
- Eliminate hard-coded account IDs
- Enable dynamic account discovery
- Standardize configuration access
- Improve maintainability

Start with Phase 1 (audit) and Phase 2 (documentation), then incrementally adopt custom fields and replace hard-coded values.


