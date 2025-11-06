
objective
This is research and teaching only, don't fix things:

Account i think you need, find the correct sso profile locally stored:
```
# instance deployed here:
CASTSoftware-dev
925774240130

# Use for identity center, ie finding the right sso profile 
Identity Center
717279730613

```

Confirm whether users a-a836660 and a-a837172 already have the right SSO permissions to start SSM sessions to the target EC2 instance, and whether your environment is configured to support SSM port forwarding. Capture findings so you know exactly what to change, if anything.

what to gather up front

target account id and region

ec2 instance id you want them to reach

your own admin access to the target account

names of any existing “SSM operator” style permission sets or groups, if known

step 1 — identity center users and groups

console path

iam identity center → users → search for a-a836660 and a-a837172

open each user → group memberships tab

note any groups that look like aws access groups, especially anything like aws-ec2-ssm-operators

what good looks like

both users exist in identity center

both are in a group you expect sailpoint to manage for this access

step 2 — account assignments and permission sets

console path

iam identity center → assignments

filter by target account id and principal type user

look for assignments for each user, or for their groups

open each permission set used by those assignments → permissions

what to verify in the permission set

includes ssm:startsession

optionally constrained to the session document aws-startportforwardingsession

resource scope limited to intended instances, ideally by tag such as ssmaccess=true

allow basic session lifecycle calls (describe, terminate, resume)

if session manager uses a customer kms key, ensure kms:decrypt and kms:generatedatakey are allowed on that key

decision

if users have no assignment, or the permission set lacks startsession or proper scoping, note the gap

step 3 — session manager preferences

console path

systems manager → session manager → preferences

record

kms key id, if set

cloudwatch log group and s3 bucket, if logging is enabled

shell profiles aren’t relevant for port forwarding, but note if customized

what this means

if a customer kms key is configured, the sso role that users assume must be permitted on that key

if logs use sse-kms, the delivery roles need key access too

step 4 — kms key access (only if a key is set in preferences)

console path

kms → customer managed keys → open the key shown in session manager preferences

verify

key policy or grants allow the sso role created from the users’ permission set to use decrypt and generatedatakey

key policy owners are correct so future changes are possible

step 5 — instance readiness for ssm

console paths

ec2 → instances → select instance → check iam role on the details tab

iam → roles → open that role → attached policies

verify

instance role effectively includes amazonsmmanagedinstancecore permissions

systems manager → fleet manager or managed instances → instance shows online and has a recent agent version

networking has egress to ssm endpoints, either via internet nat or vpc endpoints for ssm, ec2messages, and ssmmessages

nice to have for least-privilege

ec2 → tags on the instance → add or confirm ssmaccess=true if you plan to scope by tag

step 6 — where sailpoint fits

what to understand

sailpoint is your source of truth for who belongs in which access groups

those groups map to identity center groups, which are assigned to accounts with permission sets

day to day, you change access by adjusting group membership and account assignments rather than editing roles directly

what to confirm with your sailpoint contact or ui

which business role or entitlement corresponds to “ec2 ssm operator” for this account

whether you have rights to request or approve adding these two users to that entitlement

whether identity center group membership is synced from sailpoint, and expected sync cadence

step 7 — capture evidence for the change

collect lightweight proof so you can implement quickly later

screenshot or note of each user’s identity center groups

list of account assignments that currently apply to them for the target account

the permission set name you will use or modify

session manager preferences showing kms key id and logging settings

instance role name and whether amazonsmmanagedinstancecore is present

instance ssm status online and agent version

instance tag plan if using tag scoping

step 8 — quick interpretation guide

users already have a permission set with ssm:startsession and doc restriction, and the instance is online in ssm
→ you’re ready to test a port-forwarding session once their sso role creds are active

users lack a useful permission set but groups exist
→ plan to assign an ec2-ssm-operator permission set to the group in the target account

session manager uses a customer kms key and your sso role isn’t on the key policy
→ add the sso role principal to the key with decrypt and generatedatakey

instance offline in ssm
→ fix the instance role, agent, or network before touching identity