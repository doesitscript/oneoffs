#!/usr/bin/env python3
"""
cast_snapshot_tool.py
Create EBS snapshots for CAST Windows Server instances.

Features
- Target instances by --instance-id or by tag filters (e.g., --filter tag:Role=CASTServer).
- Uses AWS profile/region if provided, else falls back to environment/defaults.
- Tags snapshots consistently and can copy selected tags from the volume or instance.
- Optional retention: keep the latest N snapshots per policy key and delete older ones.
- Dry run and JSON summary output.

Usage examples
  python cast_snapshot_tool.py --profile bd-ue2-root-tfstate-lock --region us-east-2 \
    --filter tag:Role=CASTServer --policy cast-daily --keep 7 --wait

  python cast_snapshot_tool.py --profile bd-ue2-root-tfstate-lock --instance-id i-0123ab... i-0456cd... \
    --policy cast-manual-baseline --tag CreatedBy=handoff --wait

Prereqs
  # Recommended: Use uv (fast Python package manager)
  # For corporate proxy environments, set UV_NATIVE_TLS=1 to use certificate bundle:
  # export UV_NATIVE_TLS=1
  # export SSL_CERT_FILE=/Users/a805120/certs/corp-rootCA-bundle.pem  # or your cert path
  # export REQUESTS_CA_BUNDLE=$SSL_CERT_FILE
  #
  # uv venv                    # Create virtual environment
  # source .venv/bin/activate  # On Windows: .venv\\Scripts\\activate
  # uv pip install -r requirements.txt
  #
  # Or install directly with uv (creates venv automatically):
  # uv pip install boto3 botocore
  
"""

import argparse
import boto3
import botocore
import json
import logging
import os
from datetime import datetime, timezone
from typing import List, Dict, Any, Optional

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)

# Optional: Load .env file if python-dotenv is available
try:
    from dotenv import load_dotenv

    load_dotenv()  # Loads .env file from current directory
except ImportError:
    pass  # python-dotenv not installed, skip


def parse_kv_list(items: List[str]) -> Dict[str, str]:
    out = {}
    for item in items or []:
        if "=" not in item:
            raise ValueError(f"Tag must be key=value, got: {item}")
        k, v = item.split("=", 1)
        out[k] = v
    return out


def parse_filters(filters: List[str]) -> List[Dict[str, Any]]:
    out = []
    for f in filters or []:
        if "=" not in f:
            raise ValueError(f"Filter must be name=value, got: {f}")
        name, value = f.split("=", 1)
        values = [v for v in value.split(",") if v]
        out.append({"Name": name, "Values": values})
    return out


def get_boto3_clients(profile: Optional[str], region: Optional[str]):
    session_kwargs = {}
    if profile:
        session_kwargs["profile_name"] = profile
    session = boto3.Session(**session_kwargs)
    ec2 = session.client("ec2", region_name=region)
    return ec2


def list_instances(ec2, instance_ids: List[str], filters: List[Dict[str, Any]]):
    args = {}
    if instance_ids:
        args["InstanceIds"] = instance_ids
    if filters:
        args["Filters"] = filters
    res = ec2.describe_instances(**args)
    instances = []
    for r in res.get("Reservations", []):
        for i in r.get("Instances", []):
            instances.append(i)
    return instances


def list_attached_ebs_volumes(instance: Dict[str, Any]):
    vols = []
    for m in instance.get("BlockDeviceMappings", []):
        ebs = m.get("Ebs")
        if ebs and "VolumeId" in ebs:
            vols.append(
                {"DeviceName": m.get("DeviceName"), "VolumeId": ebs["VolumeId"]}
            )
    return vols


def ensure_tags(ec2, resource_id: str, tags: Dict[str, str], dry_run: bool = False):
    if not tags:
        return
    tag_list = [{"Key": k, "Value": v} for k, v in tags.items()]
    if dry_run:
        return
    ec2.create_tags(Resources=[resource_id], Tags=tag_list)


def copy_subset_tags(source_tags, allowlist):
    result = {}
    if not source_tags or not allowlist:
        return result
    for t in source_tags:
        k = t.get("Key")
        v = t.get("Value")
        if k in allowlist and v is not None:
            result[k] = v
    return result


def create_snapshot(
    ec2, volume_id: str, desc: str, tags: Dict[str, str], dry_run: bool = False
) -> str:
    kwargs = {
        "VolumeId": volume_id,
        "Description": desc,
        "TagSpecifications": [
            {
                "ResourceType": "snapshot",
                "Tags": [{"Key": k, "Value": v} for k, v in tags.items()],
            }
        ],
    }
    if dry_run:
        return f"snap-dryrun-{volume_id[-8:]}"
    resp = ec2.create_snapshot(**kwargs)
    return resp["SnapshotId"]


def wait_for_snapshots(ec2, snapshot_ids):
    if not snapshot_ids:
        return
    waiter = ec2.get_waiter("snapshot_completed")
    waiter.wait(SnapshotIds=snapshot_ids)


def list_old_snapshots_for_policy(
    ec2, policy: str, keep: int, instance_id: str, volume_id: str
):
    filters = [
        {"Name": "tag:Policy", "Values": [policy]},
        {"Name": "tag:SourceInstanceId", "Values": [instance_id]},
        {"Name": "tag:SourceVolumeId", "Values": [volume_id]},
    ]
    res = ec2.describe_snapshots(Filters=filters, OwnerIds=["self"])
    snaps = sorted(res.get("Snapshots", []), key=lambda s: s["StartTime"], reverse=True)
    old = (
        [s["SnapshotId"] for s in snaps[keep:]]
        if keep > 0
        else [s["SnapshotId"] for s in snaps]
    )
    return old


def delete_snapshots(ec2, snapshot_ids, dry_run: bool = False):
    deleted = []
    for sid in snapshot_ids:
        if dry_run:
            deleted.append(sid)
        else:
            try:
                ec2.delete_snapshot(SnapshotId=sid)
                deleted.append(sid)
            except botocore.exceptions.ClientError:
                pass
    return deleted


def main(
    instance_id: Optional[List[str]] = None,
    policy: Optional[str] = None,
    region: Optional[str] = None,
    profile: Optional[str] = None,
    filter: Optional[List[str]] = None,
    keep: int = 0,
    tag: Optional[List[str]] = None,
    copy_instance_tags: Optional[List[str]] = None,
    copy_volume_tags: Optional[List[str]] = None,
    wait: Optional[bool] = True,
    bool: Optional[bool] = False,
    dry_run: Optional[bool] = False,
):
    """
    Main entry point. Can be called with keyword arguments or as CLI (uses argparse).
    If policy is provided as a kwarg, uses kwargs; otherwise parses sys.argv using argparse.
    """
    # If policy is provided, use kwargs; otherwise use argparse (CLI mode)
    if policy is not None:
        # Use provided keyword arguments
        class Args:
            pass

        args = Args()
        args.instance_id = instance_id
        args.policy = policy
        args.region = region or os.getenv("AWS_REGION", os.getenv("AWS_DEFAULT_REGION"))
        args.profile = profile or os.getenv("AWS_PROFILE")
        args.filter = filter
        args.keep = keep
        args.tag = tag
        args.copy_instance_tags = copy_instance_tags
        args.copy_volume_tags = copy_volume_tags
        args.wait = wait
        args.dry_run = dry_run

    else:
        # Fall back to argparse for CLI compatibility
        args = _parse_args()

    filters = parse_filters(args.filter) if args.filter else []

    extra_tags = parse_kv_list(args.tag or [])

    ec2 = get_boto3_clients(args.profile, args.region)

    instances = list_instances(ec2, args.instance_id or [], filters)
    if not instances:
        print(
            json.dumps(
                {"ok": False, "error": "No instances matched the criteria"}, indent=2
            )
        )
        return 1

    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    created = []
    deleted = []

    for inst in instances:
        iid = inst["InstanceId"]
        inst_tags = inst.get("Tags", [])
        copy_i_tags = copy_subset_tags(inst_tags, args.copy_instance_tags or [])

        volumes = list_attached_ebs_volumes(inst)
        for v in volumes:
            vid = v["VolumeId"]
            # Fetch volume tags if needed
            vol_tags_resp = ec2.describe_volumes(VolumeIds=[vid])
            vtags_all = vol_tags_resp["Volumes"][0].get("Tags", [])
            copy_v_tags = copy_subset_tags(vtags_all, args.copy_volume_tags or [])

            base_tags = {
                "Policy": args.policy,
                "CreatedAt": now,
                "SourceInstanceId": iid,
                "SourceVolumeId": vid,
                "CreatedBy": "cast_snapshot_tool",
            }
            snap_tags = {**base_tags, **copy_i_tags, **copy_v_tags, **extra_tags}

            desc = f"CAST snapshot policy={args.policy} instance={iid} volume={vid} at {now}"
            sid = create_snapshot(ec2, vid, desc, snap_tags, dry_run=args.dry_run)
            created.append({"SnapshotId": sid, "InstanceId": iid, "VolumeId": vid})

            if args.keep is not None and args.keep >= 0:
                old = list_old_snapshots_for_policy(
                    ec2, args.policy, args.keep, iid, vid
                )
                deleted_ids = delete_snapshots(ec2, old, dry_run=args.dry_run)
                for d in deleted_ids:
                    deleted.append(
                        {"SnapshotId": d, "InstanceId": iid, "VolumeId": vid}
                    )

    if args.wait and not args.dry_run:
        real_ids = [
            c["SnapshotId"] for c in created if c["SnapshotId"].startswith("snap-")
        ]
        if real_ids:
            wait_for_snapshots(ec2, real_ids)

    print(
        json.dumps(
            {
                "ok": True,
                "created_count": len(created),
                "deleted_count": len(deleted),
                "created": created,
                "deleted": deleted,
            },
            indent=2,
        )
    )
    return 0


def _parse_args():
    """Parse command-line arguments using argparse."""
    ap = argparse.ArgumentParser(
        description="Create EBS snapshots for CAST servers with optional retention."
    )
    # Environment variables can override defaults, but command-line args take precedence
    ap.add_argument(
        "--profile",
        default=os.getenv("AWS_PROFILE"),
        help="AWS profile (boto3 session profile_name). Can also set AWS_PROFILE env var.",
    )
    ap.add_argument(
        "--region",
        default=os.getenv("AWS_REGION", os.getenv("AWS_DEFAULT_REGION")),
        help="AWS region, e.g., us-east-2. Can also set AWS_REGION or AWS_DEFAULT_REGION env var.",
    )
    ap.add_argument("--instance-id", nargs="+", help="One or more instance IDs")
    ap.add_argument(
        "--filter",
        action="append",
        help="EC2 filter name=value (repeatable). Example: --filter tag:Role=CASTServer",
    )
    ap.add_argument(
        "--policy",
        required=True,
        help="Snapshot policy name (e.g., cast-daily, cast-manual-baseline)",
    )
    ap.add_argument(
        "--keep",
        type=int,
        default=0,
        help="Retention: keep the newest N snapshots per volume (older will be deleted). 0 means no deletion.",
    )
    ap.add_argument(
        "--tag", action="append", help="Additional snapshot tag key=value (repeatable)"
    )
    ap.add_argument(
        "--copy-instance-tags",
        nargs="*",
        help="Copy these tag keys from the instance to the snapshot",
    )
    ap.add_argument(
        "--copy-volume-tags",
        nargs="*",
        help="Copy these tag keys from the volume to the snapshot",
    )
    ap.add_argument(
        "--wait", action="store_true", help="Wait for snapshots to complete"
    )
    ap.add_argument(
        "--dry-run", action="store_true", help="Dry run, print what would happen"
    )
    return ap.parse_args()


if __name__ == "__main__":
    raise SystemExit(main())
