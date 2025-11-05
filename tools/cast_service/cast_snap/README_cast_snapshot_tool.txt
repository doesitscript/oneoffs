CAST Snapshot Tool

What this is
- A small Python CLI to create EBS snapshots for CAST Windows Server instances.
- Target by instance IDs or tag filters.
- Consistent snapshot tags, optional tag copying, retention, and wait support.

Install
  pip install boto3 botocore

Run (examples)
  python cast_snapshot_tool.py --profile bd-ue2-root-tfstate-lock --region us-east-2 \
    --filter tag:Role=CASTServer --policy cast-manual-baseline --wait

  python cast_snapshot_tool.py --profile bd-ue2-root-tfstate-lock --region us-east-2 \
    --instance-id i-0123abcd i-0456efgh --policy cast-daily --keep 7 --wait --tag Environment=DEV

Notes
- Uses your AWS CLI profile/creds automatically if you pass --profile; otherwise relies on default provider chain.
- Retention keeps the newest N snapshots per instance/volume for the given --policy and deletes older ones.
- Dry run mode shows what would be created/deleted without making API calls.

## Note on tags 

Tag	Role	Why it matters
Application = "cast"	Core grouping key	Use this as your top-level selector for anything CAST-specific. It’s stable and reusable for all related resources (servers, volumes, security groups, etc.).
Environment = "dev"	Lifecycle scope	Lets you run the same automation across dev, uat, prod, etc., just by changing one variable.
ManagedBy = "Terraform"	Ownership indicator	Tells future teams (and your scripts) not to modify these manually — a key guardrail.
Owner = "cast-team"	Accountability	Identifies who should be notified about costs or incidents.

Given those, you don’t need a custom CASTServer tag — that’s effectively duplicating what Application=cast and ManagedBy=Terraform already express.