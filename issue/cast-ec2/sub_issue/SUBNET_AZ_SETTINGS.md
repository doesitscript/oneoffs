1 AZ (dev): simpler, cheaper, faster to iterate. If the AZ hiccups, dev can be down briefly without pain.

2 AZs (prod): baseline HA for most apps; works well with ALB/ASG and most managed DBs.

3 AZs: only when a platform specifically benefits (e.g., certain DB clusters or strict resilience policies). Otherwise it’s extra cost/complexity for little gain.