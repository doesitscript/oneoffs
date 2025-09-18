# CAST EC2 Instance – Requirements & Checklist  

## Project Requirements  
- [ ] **Create Windows EC2 instance with required specs** (≥64 GB RAM, 500 GB disk).  
  - If fails: wrong instance type or disk size in Terraform/console.  

- [ ] **Security group allows RDP from approved CAST/public IPs.**  
  - If fails:  
    - Security group not attached or missing rule.  
    - Wrong IPs (user’s source IP changed).  
  - **Test:** From your laptop → connect via `mstsc` (Windows) or `xfreerdp` (Linux/Mac).  

- [ ] **Outbound connectivity sufficient to reach `*.castsoftware.com`.**  
  - If fails:  
    - Security group outbound blocked.  
    - NACL egress blocked.  
    - Corporate proxy/firewall requirement.  
  - **Test:** From inside EC2 (RDP session):  
    ```powershell
    Test-NetConnection castsoftware.com -Port 443
    ```  

- [ ] **Align on image source:**  
  - [ ] Packer-built base image with Windows pre-steps (preferred), or  
  - [ ] Stock Windows AMI + manual domain join.  
  - If fails:  
    - Stock AMI missing required components.  
    - Packer image not yet shared across accounts.  

- [ ] **Domain join to on-prem AD.**  
  - If fails:  
    - No routing from VPC → on-prem (TGW/DX missing).  
    - Firewall not open to DC ports (88, 389, 445, etc.).  
    - Wrong credentials or missing join rights.  
  - **Test:** From inside EC2:  
    ```powershell
    Test-NetConnection <domain-controller> -Port 389
    Test-NetConnection <domain-controller> -Port 445
    nslookup corp.example.com
    ```  

- [ ] **Ensure management/security setup before hand-off.**  
  - If fails:  
    - Agents/packages can’t download.  
    - Permissions missing to install.  

- [ ] **Confirm application prerequisites (DLLs, dependencies) and source.**  
  - If fails:  
    - Repo not reachable (Bitbucket on-prem).  
    - Wrong version.  
  - **Test:** From inside EC2:  
    ```powershell
    Test-NetConnection bitbucket.company.local -Port 443
    ```  

---

## Things to Verify After Build (Checklist)  
- [ ] Instance deployed in correct account/VPC/subnet.  
- [ ] Instance type/disk size correct.  
- [ ] Security group rules applied correctly.  
- [ ] Able to RDP from approved IPs.  
- [ ] Outbound connectivity to CAST + Bitbucket.  
- [ ] Domain join successful.  
- [ ] Required setup completed (security/management).  
- [ ] CAST stakeholders validated access.  
- [ ] Inputs/config documented in Jira for codification.  

---

## Troubleshooting Workflow (Mermaid)  

```mermaid
flowchart TD
    A[Cannot RDP into EC2] --> B{Check Security Group Ingress}
    B -->|Rule Missing| B1[Add RDP rule for approved IPs]
    B -->|Rule Present| C[Check Source IP Matches Allowed Range]

    C -->|Mismatch| C1[Update SG with correct IP]
    C -->|Match| D[Check if Public IP Assigned]

    D -->|No Public IP| D1[Use SSM Session Manager or Bastion]
    D -->|Has Public IP| E[Check NACLs and Routing]

    E -->|NACL Blocks| E1[Update NACL]
    E -->|Routing Issue| E2[Check Route Tables/TGW]
    E -->|Looks Good| F[Check Windows Firewall inside EC2]

    F -->|Still Blocked| F1[Escalate to Network/AD Team]

    G[Domain Join Fails] --> H{Check Outbound to DC Ports}
    H -->|Ports Blocked| H1[Open ports 88,389,445,etc.]
    H -->|Ports OK| I[Check Credentials and Join Rights]
    I -->|Wrong Creds| I1[Use Service Account]
    I -->|Correct| J[Escalate: AD Config Issue]
