# WIP – SSO vs Provisioning: Inferred Onboarding Flow

Status: Work in Progress. This document captures the best-available view of how authentication (SSO) and authorization (provisioning to AWS Identity Center) work together in our environment, based on observed evidence and current infrastructure.

This file explains:
- The split between SSO (Okta) and provisioning (SailPoint → AWS Identity Center).
- The inferred onboarding flow for users and groups.
- How Terraform fits (creates SSO targets).
- Practical verification and a runbook to troubleshoot issues.
- A WIP sequence diagram (text/mermaid) that we will replace with a rendered diagram asset.

---

## Plain-English summary

- Okta handles authentication and launches the AWS app. Users sign in to Okta (with the admin account credentials stored in Secret Server), click the AWS tile, and federate into AWS.
- SailPoint handles authorization by writing group membership to AWS IAM Identity Center’s shared Identity Store. Membership determines which permission sets/accounts the user can access.
- Terraform creates the target SSO objects (groups and permission sets) that SailPoint manages.
- Okta SCIM (provisioning from Okta) appears to be present but not functioning for our scope. SSO still works even if SCIM provisioning doesn’t.

Result: Users can authenticate via Okta and land in AWS, and their actual permissions are granted by the Identity Center group memberships that SailPoint maintains via the management account role.

---

## Components

- Active Directory (AD): Source of users and AD groups (authoritative identity data).
- Secret Server: Stores admin account passwords that users retrieve for Okta sign-in.
- Okta (IdP): Performs authentication and launches the AWS app (SSO).
- SailPoint (IdentityNow/IdentityIQ): Aggregates from AD and AWS, correlates/matches, and provisions Identity Center group memberships.
- AWS Management Account (bfh_mgmt):
  - IAM Role: `sailpoint-read-write` (assumed by SailPoint).
  - IAM Identity Center (Shared Identity Store).
  - CloudTrail (audit of Identity Store API calls).
- Terraform: Creates Identity Center SSO groups and permission sets (targets that SailPoint will manage membership for).
- Okta SCIM (optional/legacy): Provisioning connector that is currently nonfunctional for our use case (SSO still works).
- Centralized Logs: Receives CloudTrail events.

---

## Inferred onboarding flow (users & groups)

1) Terraform creates targets
- Terraform creates Identity Center SSO groups and permission sets that represent access.
- These are the objects SailPoint will manage membership for.

2) SailPoint discovery/aggregation
- SailPoint aggregates from:
  - AD: users, AD groups.
  - AWS Identity Center: SSO groups/permission sets (via an AWS source).
- SailPoint correlates users to entitlements (e.g., via access profiles/policies mapping AD → SSO).

3) Triggers that cause provisioning
- Access request approval in SailPoint.
- HR/AD joiner/mover/leaver event.
- Scheduled reconciliation job that computes “who should be in vs who is in.”

4) Provisioning to AWS Identity Center
- SailPoint assumes the `sailpoint-read-write` IAM role in the bfh_mgmt account via STS.
- SailPoint calls the Identity Store APIs (CreateGroupMembership/DeleteGroupMembership).
- CloudTrail logs each call and forwards to central logging.

5) Consumption by AWS accounts
- Member accounts use the shared Identity Store; group membership maps to permission sets for actual authorization.

---

## SSO path vs Provisioning path (separation of concerns)

- SSO (Authentication & App Launch)
  1. Admin account created; password stored in Secret Server.
  2. User retrieves the password and authenticates to Okta using the admin account.
  3. User clicks the AWS tile in Okta; Okta federates them into AWS (SAML/OIDC).
  4. The user arrives in AWS; their effective access depends on group membership in Identity Center.

- Provisioning (Authorization)
  1. SailPoint sees users/groups via AD and Identity Center aggregation.
  2. On a trigger (request/HR/scheduled), SailPoint decides the target membership changes.
  3. SailPoint assumes `sailpoint-read-write` in bfh_mgmt and updates group membership via Identity Store APIs.
  4. CloudTrail logs the change. The user’s authorization changes the next time they use AWS.

Key point: Okta SSO can be fully functional while Okta SCIM provisioning is broken. In our environment, SailPoint (not Okta SCIM) is doing the provisioning to Identity Center.

---

## WIP sequence diagram (text)

- SSO Flow (blue)
  - User → Secret Server: retrieve password (admin account)
  - User → Okta: login
  - Okta → AWS: SSO to AWS (SAML/OIDC)
  - AWS: establish session (permissions depend on Identity Center group membership)

- Provisioning Flow (green)
  - AD → SailPoint: aggregate users/groups
  - AWS Identity Center → SailPoint: aggregate SSO groups/perm sets
  - Trigger (request / HR / scheduled) → SailPoint: compute changes
  - SailPoint → STS: AssumeRole (sailpoint-read-write in bfh_mgmt)
  - SailPoint → Identity Store: Create/DeleteGroupMembership
  - CloudTrail: record events → central logs

- Terraform (gray)
  - Terraform → Identity Center: create groups/permission sets
  - (SailPoint then manages membership of those groups.)

---

## WIP mermaid diagram (for quick visualization)

```mermaid
sequenceDiagram
  autonumber
  participant U as User (Admin acct)
  participant SS as Secret Server
  participant O as Okta (SSO)
  participant SP as SailPoint
  participant AD as Active Directory
  participant STS as AWS STS
  participant SSO as Identity Center (Identity Store)
  participant CT as CloudTrail
  participant TF as Terraform

  %% SSO path (blue)
  U->>SS: Retrieve admin password
  U->>O: Login with admin account
  O->>SSO: Federate to AWS (SAML/OIDC)
  Note over SSO: Session established; effective access<br/>depends on group membership.

  %% Provisioning path (green)
  AD-->>SP: Aggregate users & AD groups
  SSO-->>SP: Aggregate SSO groups & permission sets
  SP->>SP: Trigger (request/HR/scheduled) → compute delta
  SP->>STS: AssumeRole (sailpoint-read-write in bfh_mgmt)
  SP->>SSO: Create/DeleteGroupMembership (Identity Store API)
  SSO-->>CT: CloudTrail logs event

  %% Terraform creates targets (gray)
  TF-->>SSO: Create SSO groups & permission sets
```

---

## Evidence and verification (outside SailPoint)

SailPoint job/task metadata lives inside SailPoint (IdentityNow SaaS or IdentityIQ DB/app). We do not expect SailPoint job state to be in AWS services by default. In AWS, you verify the effects:

- Identity Store state (who is in the group)
- CloudTrail events (who changed what, when)
- STS AssumeRole events (SailPoint assuming the management role)
- Okta System Log (SSO events)

---

## Runbook: SSO vs Provisioning split – verification and triage

1) Identify the target SSO group
- From your request/ticket or Terraform definition, identify the Identity Center group name (and perm set, if relevant).

2) Check Identity Store state (is the user already in?)
- Get Identity Store ID:
  - aws sso-admin list-instances --query 'Instances[0].IdentityStoreId' --output text
- Find the group:
  - aws identitystore list-groups --identity-store-id <ID> --query "Groups[?DisplayName=='<GROUP>'].[GroupId,DisplayName]" --output text
- Find the user:
  - aws identitystore list-users --identity-store-id <ID> --filters AttributePath=UserName,AttributeValue="<user@company.com>" --query "Users[0].UserId" --output text
- List group memberships:
  - aws identitystore list-group-memberships --identity-store-id <ID> --group-id <GROUP_ID>

3) Check CloudTrail for provisioning events (proof of SailPoint activity)
- Recent Identity Store writes:
  - aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership --max-results 20
- Check for the management role assuming:
  - aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRole --max-results 20
  - Look for `sailpoint-read-write` as the role.

4) If urgent: safely add the user via the bfh_mgmt role (same path SailPoint uses)
- After assuming the management role:
  - aws identitystore create-group-membership --identity-store-id <ID> --group-id <GROUP_ID> --member-id UserId="<USER_ID>"
- This is reversible and audited; remove with `delete-group-membership` if needed.

5) If no provisioning events exist
- Likely the entitlement/group is not onboarded in SailPoint or no trigger fired.
- Options:
  - Submit an access request for that entitlement in SailPoint.
  - Ask a SailPoint admin to run on-demand aggregations (AD, AWS) and a provisioning task.
  - Onboard the group into SailPoint’s AWS application so it’s managed going forward.

6) Confirm SSO path is healthy
- Okta System Log: verify the user’s SSO event to AWS.
- If SSO works but the user still lacks permissions, it’s a provisioning/membership issue.

7) Optional: AD “should be” vs Identity Store “is”
- Query the AD group that serves as source-of-truth.
- Compare membership to the Identity Store group; plan adds/removes accordingly.

---

## Safety and guardrails

- Changes to Identity Store are fully auditable via CloudTrail and central logs.
- Membership operations are idempotent and reversible.
- The `sailpoint-read-write` role should be scoped to Identity Store membership CRUD—not broad administrative power.
- If both Okta SCIM and SailPoint provisioning target the same group later, updates are still consistent (adds/removes converge to the same state).

---

## Next steps (WIP)
- Render a companion diagram for this sequence (PNG/SVG) and store alongside this document.
- Add a tiny helper script to wrap common AWS CLI checks (Identity Store + CloudTrail).
- If desired, add an EventBridge rule for near-real-time alerts on Identity Store membership changes.

---

## WIP – Manager one‑pager (SSO vs Provisioning)

- Authentication (SSO) → Okta: Users sign in (admin account password retrieved from Secret Server) and click the AWS tile to launch AWS. This part works independently of provisioning.
- Authorization (Provisioning) → SailPoint: Determines actual AWS access by adding/removing users in IAM Identity Center groups via the management account role (sailpoint-read-write). Every change is logged in CloudTrail.
- Terraform creates the SSO groups and permission sets that SailPoint targets.
- Okta SCIM is not required for SSO and appears broken for provisioning in our scope (0 Identity Store writes). That does not impact the SSO experience.

Implication: Users can log in via Okta but still lack access if their Identity Center group membership wasn’t provisioned. The fix is to ensure SailPoint onboards those groups or to perform an audited, reversible membership change via the management role.

---

## WIP – Exact AWS CLI checks (copy/paste)

1) Identity Store basics
```bash
# Identity Store ID
aws sso-admin list-instances --query 'Instances[0].IdentityStoreId' --output text
IDENTITY_STORE_ID=<paste>

# Find an SSO group by display name
GROUP_NAME="<your-sso-group-name>"
aws identitystore list-groups \
  --identity-store-id "$IDENTITY_STORE_ID" \
  --query "Groups[?DisplayName=='${GROUP_NAME}'].[GroupId,DisplayName]" --output text

# Find a user by username/email
USER_LOOKUP_VALUE="<user@company.com>"
aws identitystore list-users \
  --identity-store-id "$IDENTITY_STORE_ID" \
  --filters AttributePath=UserName,AttributeValue="$USER_LOOKUP_VALUE" \
  --query "Users[0].UserId" --output text

# List current members of a group
GROUP_ID=<paste>
aws identitystore list-group-memberships \
  --identity-store-id "$IDENTITY_STORE_ID" \
  --group-id "$GROUP_ID"
```

2) CloudTrail evidence
```bash
# Recent membership writes
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
  --max-results 20 --query 'Events[].{time:EventTime,user:Username,name:EventName}'

# Recent role assumptions (look for sailpoint-read-write)
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRole \
  --max-results 20 --query 'Events[].{time:EventTime,user:Username,name:EventName}'
```

3) Safe, audited unblock (after assuming the management role)
```bash
# Add user to group (reversible)
USER_ID=<paste>
aws identitystore create-group-membership \
  --identity-store-id "$IDENTITY_STORE_ID" \
  --group-id "$GROUP_ID" \
  --member-id UserId="$USER_ID"
```

---

## WIP – Optional SQL (Athena / CloudTrail Lake)

```sql
-- Identity Store membership writes in the last 7 days
SELECT eventTime, userIdentity.arn AS actor, eventName, sourceIPAddress
FROM cloudtrail_logs
WHERE eventSource = 'identitystore.amazonaws.com'
  AND eventName IN ('CreateGroupMembership','DeleteGroupMembership')
  AND eventTime >= current_timestamp - interval '7' day
ORDER BY eventTime DESC
LIMIT 200;
```

---

## WIP – Expanded sign‑in sequence (Admin account + Secret Server + Okta tile)

1) Admin account and password are created and stored in Secret Server.
2) User retrieves the admin password from Secret Server.
3) User logs into Okta with the admin account; Okta performs MFA/SSO as configured.
4) User clicks the AWS application tile in Okta; Okta federates the user into AWS.
5) The user’s effective AWS permissions depend on Identity Center group membership. If SailPoint has not yet added the user to the correct group(s), they can authenticate but won’t have the expected access.

---

## WIP – Ownership and where data lives

- SailPoint job/task metadata and provisioning audits reside in SailPoint (IdentityNow SaaS or IdentityIQ DB/app), not in AWS by default.
- In AWS you will see:
  - STS AssumeRole for the sailpoint-read-write role.
  - Identity Store API calls (Create/DeleteGroupMembership) in CloudTrail.
  - The final membership state in the Identity Store.
- Okta System Log shows SSO events; Okta SCIM provisioning logs may show failures/emptiness (consistent with our findings).

---

## WIP – Diagram rendering via AWS diagrams MCP tool

Use the standard diagrams capability in this workspace to generate artifacts (PNG/SVG) from the maintained diagram definitions.
No local Graphviz/Python or custom scripts are required. The previous custom script approach is deprecated and has been removed.

---