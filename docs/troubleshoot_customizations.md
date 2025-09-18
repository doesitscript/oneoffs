# EC2 Domain Join: Potential Issues & Troubleshooting (Based on SharedServices Customizations)

Your `sharedservices-general-customizations` VPC setup gives you DNS forwarding and parameterized VPCs, but there are still gaps that could block a domain join. Below is a checklist of what might fail, with nested troubleshooting commands tailored to your setup.

---

## 1. SSM Agent Doesn’t Register
**Why it might fail:**
- No VPC interface endpoints for `ssm`, `ec2messages`, `ssmmessages` in private subnets.
- No NAT gateway to reach SSM APIs.
- EC2 IAM role missing `AmazonSSMManagedInstanceCore`.

**Troubleshooting**
- From workstation/CloudShell:

```bash
aws ssm describe-instance-information \
  --profile $PROFILE \
  --region us-east-2
```

*If the instance is missing:*

- Check endpoints:

```bash
aws ec2 describe-vpc-endpoints --profile $PROFILE --region us-east-2
```
- Check IAM role attachment:

```bash
aws iam list-attached-role-policies \
  --role-name EC2DomainJoinRole \
  --profile $PROFILE
```

---

## 2. DNS Resolution Fails

**Why it might fail:**

- Route 53 Resolver rules not pointing to correct on-prem DNS forwarders.
- DHCP options not set to use VPC DNS.
- EC2 instance not resolving `_ldap._tcp` records.

**Troubleshooting**

- On Windows EC2:

```powershell
Resolve-DnsName yourdomain.local
Resolve-DnsName _ldap._tcp.dc._msdcs.yourdomain.local
```

*If fails:*

- Confirm resolver rules:

```bash
aws route53resolver list-resolver-rules \
  --profile $PROFILE \
  --region us-east-2
```
- Check VPC associations:

```bash
aws route53resolver list-resolver-rule-associations \
  --profile $PROFILE \
  --region us-east-2
```

---

## 3. Ports Blocked to AD/DCs

**Why it might fail:**

- SG defaults changed to restrictive egress.
- NACLs in the VPC blocking outbound.
- Missing rules for LDAP, Kerberos, DNS, SMB.

**Troubleshooting**

- On Windows EC2:

```powershell
Test-NetConnection -ComputerName dc1.yourdomain.local -Port 389   # LDAP
Test-NetConnection -ComputerName dc1.yourdomain.local -Port 636   # LDAPS
Test-NetConnection -ComputerName dc1.yourdomain.local -Port 88    # Kerberos
Test-NetConnection -ComputerName dc1.yourdomain.local -Port 445   # SMB
Test-NetConnection -ComputerName dc1.yourdomain.local -Port 53    # DNS
```

*If blocked:*

- Inspect SGs:

```bash
aws ec2 describe-security-groups \
  --group-ids sg-xxxxxxxx \
  --profile $PROFILE
```
- Inspect NACLs:

```bash
aws ec2 describe-network-acls \
  --filters Name=vpc-id,Values=vpc-xxxxxx \
  --profile $PROFILE
```

---

## 4. Routing Problems

**Why it might fail:**

- Subnets missing routes to AD/DC network via TGW/DX.
- Incorrect propagation of routes in shared VPC.

**Troubleshooting**

- On Linux EC2:

```bash
ip route show
traceroute dc1.yourdomain.local
```
- On Windows EC2:

```powershell
tracert dc1.yourdomain.local
```

*If fails:*

- Inspect routes:

```bash
aws ec2 describe-route-tables \
  --filters Name=vpc-id,Values=vpc-xxxxxx \
  --profile $PROFILE
```

---

## 5. AD Join Completes but No Computer Object

**Why it might fail:**

- Wrong OU specified in SSM association.
- Pre-stage policies required in AD.
- Account permissions missing.

**Troubleshooting**

- On a DC or with RSAT tools:

```powershell
Get-ADComputer -Identity DOMAIN-JOIN-TEST
```

*If missing:*

- Confirm SSM document parameters:

```bash
aws ssm list-associations --profile $PROFILE --region us-east-2
aws ssm describe-association \
  --association-id <assoc-id> \
  --profile $PROFILE --region us-east-2
```

---

This checklist reflects your **sharedservices-general-customizations** setup: DNS forwarding is present, but you must explicitly confirm SSM endpoints, outbound SG rules, and subnet routing. If any of those fail, the EC2 domain join will not succeed.

Do you want me to also create a **flow diagram in Mermaid** that shows where failure can occur (SSM → DNS → SG/NACL → Routing → AD join), so you can walk your team through the troubleshooting visually?
