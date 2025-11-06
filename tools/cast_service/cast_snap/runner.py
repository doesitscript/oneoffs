import os

# from _cli_wrapper import parse_args  # File deleted - uncomment if you recreate _cli_wrapper.py

profile = os.getenv("AWS_PROFILE")
region = os.getenv("AWS_REGION")

try:
    from cast_snapshot_tool import main  # your function
except Exception as e:
    raise SystemExit(f"Could not import main() from cast_snapshot_tool: {e}")

if __name__ == "__main__":
    # Option A: hardcode params for fast debugging:
    cfg = dict(
        instance_id=["i-054443c7dc4253556"],
        filter=["tag:Role=srv", "tag:Environment=dev", "tag:Application=cast"],
        policy="cast-manual-baseline",
        region="us-east-2",
        profile=profile,
        wait=True,
        dry_run=True,
    )

    # Option B: reuse CLI-style args (works in F5 too):
    # cfg = parse_args()  # comment this out if using Option A above
    # keep=7,

    rc = main(**cfg)
    raise SystemExit(rc if isinstance(rc, int) else 0)
