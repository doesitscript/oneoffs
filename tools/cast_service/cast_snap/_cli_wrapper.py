import argparse
from typing import Optional, Any, Dict, List


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="cast_snapshot_tool")
    p.add_argument("--instance-id", nargs="+", help="EC2 instance-id(s) (optional)")
    p.add_argument(
        "--filter", action="append", help="EC2 filter name=value (repeatable)"
    )
    p.add_argument(
        "--policy",
        required=True,
        help="Policy name (e.g., cast-daily, cast-manual-baseline)",
    )
    p.add_argument("--region", default="us-east-2", help="AWS region")
    p.add_argument("--profile", help="AWS CLI profile")
    p.add_argument("--keep", type=int, default=0, help="Retention: keep N snapshots")
    p.add_argument("--wait", action="store_true", help="Wait for snapshots to complete")
    p.add_argument("--dry-run", action="store_true", help="Dry run mode")
    return p


def parse_args() -> Dict[str, Any]:
    args = build_parser().parse_args()
    return dict(
        instance_id=args.instance_id,
        filter=args.filter,
        policy=args.policy,
        region=args.region,
        profile=args.profile,
        keep=args.keep,
        wait=args.wait,
        dry_run=args.dry_run,
    )
