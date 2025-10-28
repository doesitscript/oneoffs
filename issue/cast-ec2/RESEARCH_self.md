# Research Items

## Environment Naming Convention for Single-Environment Accounts

**Question**: How should we handle environment values for accounts that don't have dev/prod environments?

**Context**: 
- Some accounts only have one environment (their production environment)
- They don't designate it as "prod" in their naming conventions
- Need guidance on what environment value to use in Terraform configurations

**Specific Example**: 
- CAST account (925774240130) - single environment, no dev/prod designation
- What should the environment variable be set to?

**Impact**: 
- Affects resource naming and tagging
- Affects variable values in Terraform configurations
- Need consistent approach across all account types

**Options to Research**:
1. **"prod"** - since it's their production environment
2. **"main"** - generic single-environment naming
3. **"cast"** - account-specific naming
4. **Something else** - based on organizational standards

**Action Needed**: 
- Clarification on naming convention for single-environment accounts
- Guidance on whether to use "prod", "main", or account-specific naming
- Document decision for future similar accounts

**Status**: Pending team discussion with Sanjeev

## Systematic Environment Detection Strategy

**Question**: How to consistently determine environment across all AWS accounts in the organization?

**Context**: 
- Inconsistent naming across accounts (some have dev/prod, some don't)
- No standardized lifecycle naming (test, prod, uat, etc.)
- No consistent way to extract environment from account names
- Need systematic approach for environment detection

**Current State**:
- CASTSoftware-dev (clearly has "dev" in name)
- Some accounts have no environment designation
- Mixed naming conventions across organization

**Proposed Solution**:
1. **Standardize environment types** (prod, test, uat, dev, etc.)
2. **AFT integration** - when accounts are vended, tag them with environment type
3. **AWS resource queries** - use tags/labels to determine environment dynamically
4. **Terraform data sources** - query AWS for environment information

**Impact**: 
- Affects all Terraform configurations across organization
- Enables consistent resource naming and tagging
- Supports automated environment detection
- Reduces manual configuration errors

**Action Needed**: 
- Design systematic environment detection approach
- Plan AFT integration for environment tagging
- Implement AWS resource queries for dynamic detection
- Standardize environment naming conventions

**Status**: Planning phase - user considering approach
