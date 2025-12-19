# SailPoint Connector Checks (Track B)
Research and implementation guide for enabling and validating SailPoint “direct integration” with AWS IAM Identity Center

Status: Draft (production-proven pattern exists in bfh_mgmt)
Audience: AWS platform engineers, SailPoint engineers, security reviewers

---

## Purpose

This document describes:
- What a working SailPoint → AWS IAM Identity Center connector must be configured with
- How to validate the connector end-to-end using CloudTrail evidence
- What commonly breaks (and how to fix it)
- Guardrails, monitoring, and rollout guidance so the connector mirrors SCIM outcomes with better reliability

This is the “Track B” path: get real automation working via SailPoint’s direct integration to AWS APIs (not SCIM).

---

## Known-Working Pattern (from bfh_mgmt)

- Connector assumes IAM role: arn:aws:iam::739275453939:role/sailpoint-read-write
- Calls the Identity Store service in us-east-2 (shared Identity Store)
- Evidence shows: CreateGroupMembership only (exactly what a provisioning engine should do)
- SDK signature: aws-sdk-go-v2 … api/identitystore
- Identity Store ID: d-9a6763d7d3
- Scale: ~50 events in 7 days without failures during the observed period

Artifacts (evidence in repo):
- identity store events (bfh_mgmt): investigations/20241114_scim_investigation/raw_data/bfh_mgmt_739275453939_admin/group_membership_events.json
- observed user agents: investigations/20241114_scim_investigation/raw_data/bfh_mgmt_739275453939_admin/user_agents.txt

---

## Minimal Viable Configuration (MVC)

1) AWS IAM role for SailPoint to assume (per target account)
- Role name (suggested): sailpoint-read-write
- Trust: allow SailPoint to AssumeRole with an ExternalId
- Policy: least-privilege to read groups/users and create/delete group memberships in the shared Identity Store

Trust policy (example – replace placeholders):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SailPointAssumeRole",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<SAILPOINT_AWS_ACCOUNT_ID>:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "<EXTERNAL_ID_PROVIDED_BY_SAILPOINT>"
        }
      }
    }
  ]
}
```

Permissions policy (Identity Store group membership only):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "IdentityStoreRead",
      "Effect": "Allow",
      "Action": [
        "identitystore:ListUsers",
        "identitystore:ListGroups",
        "identitystore:DescribeUser",
        "identitystore:DescribeGroup",
        "identitystore:ListGroupMemberships"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "identitystore:IdentityStoreId": "d-9a6763d7d3"
        }
      }
    },
    {
      "Sid": "IdentityStoreWriteMemberships",
      "Effect": "Allow",
      "Action": [
        "identitystore:CreateGroupMembership",
        "identitystore:DeleteGroupMembership"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "identitystore:IdentityStoreId": "d-9a6763d7d3"
        }
      }
    }
  ]
}
```

Notes:
- Identity Store has limited resource-level IAM scoping. The IdentityStoreId condition is the strongest scoping control presently available.
- If you want even more control, enforce naming conventions (prefixes) at SailPoint (which groups it manages).

2) SailPoint source/connector configuration
- Source type: AWS IAM Identity Center (or AWS SSO/Identity Center)
- Auth: AssumeRole
  - Role ARN: arn:aws:iam::<ACCOUNT_ID>:role/sailpoint-read-write
  - ExternalId: <provided by/onboarded in SailPoint>
- Region: us-east-2
- Identity Store ID: d-9a6763d7d3
- Provisioning scope: restrict to the groups you intend to manage (e.g., prefix “App-AWS-”)
- Start with a single test user and single test group

Outcome (target surface):
- CreateGroupMembership/DeleteGroupMembership calls in the shared Identity Store (d-9a6763d7d3)

---

## End-to-End Validation

Use any AWS profile with read permissions in us-east-2 (the Identity Center region).

Quick checks:
- Test connection in SailPoint UI (should succeed)
- Add one user to one managed group; wait for completion status in SailPoint

CloudTrail verification (management events):
- Expect: eventSource = identitystore.amazonaws.com
- Expect: eventName = CreateGroupMembership (or DeleteGroupMembership)
- Expect: userAgent contains aws-sdk-go-v2 … api/identitystore
- Expect: userIdentity.type = AssumedRole (assumed-role/sailpoint-read-write/…)
- Expect: requestParameters.identityStoreId = d-9a6763d7d3

Membership verification:
- identitystore:list-group-memberships should show the new user membership on the group

Evidence correlation (what to look for):
- Role used: arn:aws:sts::<ACCOUNT_ID>:assumed-role/sailpoint-read-write/<session>
- Operation: CreateGroupMembership
- Store: d-9a6763d7d3
- Region: us-east-2
- User agent: aws-sdk-go-v2

---

## Guardrails and Hardening

- IAM role limited strictly to Identity Store read + membership write
- Condition on identitystore:IdentityStoreId = d-9a6763d7d3
- Enforce group naming/prefix scoping in SailPoint configuration (only manage intended groups)
- Monitoring:
  - CloudWatch metric filters and alarms for CreateGroupMembership/DeleteGroupMembership spikes
  - Alerts for AssumeRole failures (trust/policy/config drift)
- Periodic reconciliation:
  - Compare SailPoint authoritative state vs. actual group members (detect drift early)

---

## Common Failure Modes (Troubleshooting Matrix)

| Symptom | Likely Cause | How to Confirm | Fix |
|---|---|---|---|
| “Test connection” fails in SailPoint | Trust policy mismatch (ExternalId, principal) | CloudTrail shows no AssumeRole; IAM Access Advisor | Fix trust policy: correct Principal and ExternalId |
| No Identity Store events appear | Wrong region or Identity Store Id | CloudTrail lookup empty in us-east-2 | Set connector region to us-east-2; set IdentityStoreId = d-9a6763d7d3 |
| AccessDenied on CreateGroupMembership | IAM role policy missing actions/condition | CloudTrail error event | Add identitystore:CreateGroupMembership/DeleteGroupMembership + IdentityStoreId condition |
| Users not found | Connector searching wrong attribute | identitystore:ListUsers output vs. connector mapping | Align attribute mapping to UserName or Emails.value |
| Only some groups update | SailPoint scoping excludes group | Connector scope config | Include correct group(s)/prefix in connector scope |
| Random throttling/backoff | High rate of changes | CloudTrail + retry behavior | Stage rollouts; enable backoff in connector settings |
| Unexpected group changes | Too broad scope | Change set too large | Restrict scope to naming/prefix; add staged rollout |

---

## Rollout Plan (Phased)

1) Pilot (single account, single group, 1–2 users)
- Create the IAM role with least privilege and trust
- Configure SailPoint source to assume role (ExternalId)
- Validate end-to-end (CloudTrail + group membership)

2) Expand scope (more groups in that account)
- Enable group name/prefix scoping in SailPoint
- Monitor CloudTrail for spikes/errors

3) Replicate to more accounts
- Reuse role name + same trust/policy pattern (per account)
- Keep IdentityStoreId (shared store) and region (us-east-2) consistent

4) Standardize
- Publish connector/role template (trust + policy)
- Add guardrails and alerting
- Add a reconciliation job (optional)

---

## What “Good” Looks Like

- CloudTrail shows a steady trickle of CreateGroupMembership/DeleteGroupMembership events (no errors)
- All events show:
  - userAgent: aws-sdk-go-v2 … api/identitystore
  - assumed-role/sailpoint-read-write
  - identityStoreId = d-9a6763d7d3
- Group memberships reflect SailPoint’s authoritative state
- No direct/manual provisioning required

---

## What This Replaces (Behavioral Parity With SCIM)

- SCIM → (broken in your environment) should have driven the same outcome (group membership CRUD)
- SailPoint direct integration → uses AWS APIs to achieve the same outcome with better reliability, clearer guardrails, and CloudTrail audit

---

## Runbooks

A) Add user to managed group (manual parity test)
1. Identify UserId (via list-users filter)
2. Call CreateGroupMembership (CLI or connector)
3. Verify via list-group-memberships + CloudTrail

B) Remove user from managed group (manual parity test)
1. Identify membershipId (list-group-memberships)
2. Call DeleteGroupMembership
3. Verify via list-group-memberships + CloudTrail

C) Connector test runbook
- In SailPoint, test connection → if fail, check trust policy and ExternalId
- Provision single user to single group (scoped) → check CloudTrail in us-east-2
- Verify Identity Store membership count changed

D) Rollback
- If an incorrect membership is added:
  - Remove via DeleteGroupMembership (connector or CLI)
  - Scope connector to avoid re-adding
  - Confirm in CloudTrail and Identity Store

---

## Security Notes

- ExternalId must be unique and treated as a secret with the connector
- IAM role should not carry broader permissions than Identity Store CRUD for group membership
- Condition by IdentityStoreId for strong scoping
- Avoid embedding long-lived credentials; prefer AssumeRole

---

## “Broken” Checklist (What to Look For When It Isn’t Working)

- Trust policy:
  - Wrong Principal (SailPoint account)
  - Missing or incorrect ExternalId
- Policy:
  - Missing identitystore:{Create,Delete}GroupMembership
  - No IdentityStoreId condition (or wrong ID)
- Configuration:
  - Wrong region (must be us-east-2)
  - Wrong Identity Store ID
  - Scope excludes your groups
- Platform:
  - Connector disabled/paused
  - Agent egress/network issues
- Audit:
  - CloudTrail absent (wrong region or trail not capturing management events)

---

## Appendix A – Useful CLI Commands

Find a user:
```bash
aws identitystore list-users \
  --identity-store-id d-9a6763d7d3 \
  --filters AttributePath=UserName,AttributeValue=<user-name-or-email> \
  --region us-east-2
```

List group memberships:
```bash
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id <group-id> \
  --region us-east-2
```

Create membership (simulated outcome of the connector):
```bash
aws identitystore create-group-membership \
  --identity-store-id d-9a6763d7d3 \
  --group-id <group-id> \
  --member-id UserId=<user-id> \
  --region us-east-2
```

Delete membership:
```bash
aws identitystore delete-group-membership \
  --identity-store-id d-9a6763d7d3 \
  --membership-id <membership-id> \
  --region us-east-2
```

CloudTrail lookup (recent create events):
```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreateGroupMembership \
  --region us-east-2
```

---

## Appendix B – Project Pointers

- Evidence set (bfh_mgmt):
  - investigations/20241114_scim_investigation/raw_data/bfh_mgmt_739275453939_admin/group_membership_events.json
  - investigations/20241114_scim_investigation/raw_data/bfh_mgmt_739275453939_admin/user_agents.txt
- Lifecycle diagrams (automation proof & safety):
  - diagrams/lifecycle_bfh_mgmt/
- This guide:
  - research/identity-center-investigation/SAILPOINT_CONNECTOR_CHECKS.md

---