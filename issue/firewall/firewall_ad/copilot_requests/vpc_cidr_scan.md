Scan all AWS accounts and regions for VPC CIDR allocations.

Goals:  
1. Verify which CIDRs are actually provisioned in AWS for our VPCs.  
   - Specifically check if AWS infra is using /16 blocks (10.60.0.0/16, 10.160.0.0/16 as Jared listed)  
     or larger /14 ranges (10.60.0.0/14, 10.160.0.0/14 as Stephen mentioned).  
2. For each VPC, return:  
   - Account ID  
   - Region  
   - VPC ID and Name tag (if any)  
   - All primary and secondary CIDRs  
   - Whether the CIDR is inside the expected /14 ranges  
   - Whether the CIDR matches or conflicts with Jared’s proposed /16s  
3. Highlight any CIDRs that fall outside these ranges or overlap with on-prem ranges (10.91.x.x, 10.131.x.x).  
4. Flag if subnets or child ranges could allow us to request a more precise CIDR than "all traffic".  

Output as a table that shows:  
Account | Region | VPC Name/ID | CIDR(s) | Inside /14? | Matches Jared’s /16? | Notes (overlap, conflict, exception)
