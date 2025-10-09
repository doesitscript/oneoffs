The DXGW attachment ranges (10.60.0.0/14 and 10.160.0.0/14) are “under the hood” — your SGs almost never need explicit entries for them.

You’d only add them if your security team explicitly requires allowing those AWS-managed infra ranges for observability, health checks, or routing quirks.

---
When AWS architects put a GWLB endpoint in your spoke VPCs, they change the route tables.

Normal route table (no inspection):

0.0.0.0/0 → nat-gateway-id
10.0.0.0/8 → tgw-attach-id


With centralized inspection via GWLB:

0.0.0.0/0 → vpc-endpoint-id (gwlb-endpoint)
10.0.0.0/8 → vpc-endpoint-id (gwlb-endpoint)


So all traffic goes first to the ENIs of the GWLB endpoint, which live in 10.62.0.0/24.