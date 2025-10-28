# Team Communication Items

## For Sanjeev - Environment Naming Convention

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

**Action Needed**: 
- Clarification on naming convention for single-environment accounts
- Guidance on whether to use "prod", "main", or account-specific naming

## For Sanjeev - Domain Join Server Redeployment

**Question**: Hey Sanjeev, are we good to redeploy domain joined servers?

**Context**: 
- We're planning to redeploy the CAST server using Terraform
- The server will be domain joined with the same hostname
- Need to understand AD cleanup process before redeployment

**Critical Issue - AD Identity Conflict**:
- If we redeploy a server using the same name before the old account is cleaned up from AD, Active Directory sees two machines claiming the same identity
- This creates a conflict where AD doesn't know which machine is legitimate
- Can cause authentication issues, group policy problems, and security concerns

**What We Need to Know**:
- How long does it take for AD to clean up old computer accounts?
- Should we use a different hostname for the new deployment?
- Is there a process to manually remove the old computer account from AD?
- What's the recommended approach for redeploying domain-joined servers?

**Impact**:
- Could break domain authentication for the new server
- May cause security issues with duplicate identities
- Could affect group policy application
- Might impact other domain services

**Action Needed**:
- Guidance on AD cleanup timing
- Recommended approach for server redeployment
- Process for handling computer account conflicts

## Quick Note - Drive Performance

**For Team**: Cast docs just give "using storage/disk with high IOPS values". Considering IO2 drives for CAST data processing workloads instead of gp3 for better performance. For ref: IO2 provides up to 64,000 IOPS vs 16,000 for gp3. 

There are even faster options like NVMe-based storage that could be explored later if CAST’s analysis performance becomes I/O-bound, though those drives are typically ephemeral and better suited for temporary or cache data rather than persistent storage. <Bringing up since CAST is servering the whole company's and no one wants to wait for sluggish responses, and it wouldn't be the fault of the software.>