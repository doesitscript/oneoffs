from typing import Optional


class Args:
    instance_id: Optional[list[str]]
    filter: Optional[list[str]]
    policy: Optional[str]
    region: Optional[str]
    profile: Optional[str]
    wait: bool
    dry_run: bool

    def __init__(
        self,
        instance_id: list[str],
        filter: list[str],
        policy: str,
        region: str,
        profile: str,
        wait: bool,
        dry_run: bool,
    ):
        self.instance_id = instance_id
        self.filter = filter
        self.policy = policy
        self.region = region
