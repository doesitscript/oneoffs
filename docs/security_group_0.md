# What an EC2 Security Group is

A **stateful virtual firewall** that AWS attaches at the ENI (Elastic Network Interface) level — basically, it controls what traffic can flow into and out of your instance's network card.

> **Important**: It is not a change inside the Windows/Linux OS firewall. Your VM's local firewall (Windows Firewall, iptables, etc.) still exists separately.

## How they work

### Inbound rules
Define which traffic from outside is allowed to reach the instance (by port, protocol, source IP/CIDR, or source security group).

### Outbound rules
Define which traffic the instance is allowed to send out.

### Stateful behavior
If you allow inbound on port 3389 (RDP), return traffic is automatically allowed out — you don't need a matching outbound rule.

## Analogy

Think of it like AWS puts a firewall in front of your NIC.

- **Security Groups** = who's allowed to knock on the door
- **Instance firewall** (inside the OS) = what you do with them after they knock

## Example

In your CAST EC2 case:

- **Inbound rule**: only allow RDP (3389) from CAST's public IPs → means only people at those IPs can even try to RDP into your VM
- **Outbound rule**: allow all → means the VM can reach the internet, *.castsoftware.com, etc.

## Why it matters

### Troubleshooting scenarios

- **If domain join fails**: Check if the Security Group allows outbound to AD/DCs on the right ports?
- **If CAST can't RDP**: Check if the Security Group inbound matches their source IPs?

## Direct answers

**Are they firewall changes to the VM itself?**  
→ No, they're enforced at the AWS hypervisor level, not inside the OS.

**What are they?**  
→ A stateful, AWS-managed firewall that wraps your ENI and controls inbound/outbound traffic before it hits your OS.