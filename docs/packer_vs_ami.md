# Default AMI vs. Packer Image – Comparison

| Category              | Default AWS AMI                          | Packer-Built Image (Enterprise)                 |
|-----------------------|------------------------------------------|------------------------------------------------|
| **Networking / IPs**  | May assign public IP if subnet allows.   | Org may disable public IPs by default; private-only. |
| **Management Agents** | AWS SSM Agent included; nothing else.    | May include MECM/SCCM, CrowdStrike, Qualys, monitoring/logging agents. |
| **Security / Hardening** | Baseline Windows/Linux OS, minimal changes. | CIS/STIG hardening, local admin disabled/renamed, enforced encryption. |
| **Domain Join**       | Workgroup only; must join manually/script. | May include pre-steps for domain join or baked-in automation. |
| **Software & Patching** | Base OS + AWS drivers; needs patch cycle at boot. | Patched to baseline; may include runtimes (DLLs, .NET, Java, etc.). |
| **Logging/Monitoring** | No CloudWatch/3rd-party agents by default. | Often preconfigured CloudWatch/Datadog/ELK/log forwarders. |
| **Bootstrapping/User Data** | Fully open to run User Data scripts. | May already run first-boot configs; could override or conflict with User Data. |

---

## Note on Public IPs
- **Yes**, it is possible that a **Packer-built image** will launch without a public IP showing in the AWS console.  
- That’s not because of the AMI itself (images don’t “carry” IP settings) but because:  
  - Launch template or Terraform config tied to that image may have `associate_public_ip_address = false`.  
  - Enterprise defaults often enforce **private-only networking** for security.  
- In those cases, the instance will only have a **private IP** in the console, and access is through **SSM, VPN, or a bastion host**, not directly via public RDP/SSH.
