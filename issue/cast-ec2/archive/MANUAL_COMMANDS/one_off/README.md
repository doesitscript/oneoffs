# CAST Infrastructure - MVP 1

## Overview
MVP 1 implementing CAST from Image, targeting minimal account and instance values specific to CAST account.

## MVP 1 Configuration Strategy

## Naming Convention

### Added pattern to not confuse the existing servers manually deployed with these: {org}-{region}-{env}-{app}-{role}-{num}

**Example:** `brd-ue2-dev-cast-srv-01`


### AWS Name Tag vs. AD Hostname

**AWS Instance Name Tag:** `brd-ue2-dev-cast-srv-01` # <-- we added this so that we could associate the server name to the ADHOSTNAME in one place>
**AD Computer Name:** `brd26w080n1` <-- we added this so that we could associate the server name to the ADHOSTNAME in one place

### Minimal Account Setup
- **Target**: CAST-specific AWS account deploy
- **Approach**: Minimal viable infrastructure to validate CAST functionality
- **Scope**: mvp: deploy to CAST, import/apply values from running instance, domain join

### Instance Configuration
- **Instance Type**: Optimized for CAST workload requirements
- **Sizing**: Minimal viable compute resources
- Added  specs per Tom's request -- requested full spec reqs prior to handing off product.nd naming conventions

### CAST Account Specifics-- Importing values from running instance for
- IAM roles and policies
- security configurations

## Intermediate Improvement. Adding variables for resource and system specs. 

Note: See Jira issue for Spec updates

## Implementation Notes
- Focus on core CAST functionality
- Implmented AWS security recommended values (partial. need Bread reqs)

## Postdomain Join Instance Connection
aws ssm start-session --target INSTANCE_NAME \
  --profile <your_profile--like CASTSoftware_dev_925774240130_admin> \
  --region us-east-2 \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["3389"],"localPortNumber":["13389"]}'

## Optional: implied use of aws docs: AWS-StartSSHSession / AWS-StartInteractiveCommand
aws ssm start-session \
  --target i-0565d268ae24eff7a \
  --profile  <your_profile--like CASTSoftware_dev_925774240130_admin>  \
  --region us-east-2

## WOrkspace should follow

This is the format of the workspace name for the code hat this was based on. Standarize on this:
ws-<accountid>-<accountname>-<env>-<accountname>