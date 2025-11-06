from typing import Optional, List


class Args:
    instance_id: Optional[List[str]]
    tag: Optional[List[str]]
    copy_instance_tags: Optional[List[str]]
    copy_volume_tags: Optional[List[str]]
    filter: Optional[List[str]]
    policy: Optional[str]
    region: Optional[str]
    profile: Optional[str]
    wait: bool
    dry_run: bool

    def __init__(
        self,
        instance_id: List[str],
        tag: List[str],
        copy_instance_tags: List[str],
        copy_volume_tags: List[str],
        filter: List[str],
        policy: str,
        region: str,
        profile: str,
        wait: bool,
        dry_run: bool,
        keep: int,
    ):
        self.instance_id = instance_id
        self.tag = tag
        self.copy_instance_tags = copy_instance_tags
        self.copy_volume_tags = copy_volume_tags
        self.filter = filter
        self.policy = policy
        self.region = region
        self.profile = profile
        self.wait = wait
        self.dry_run = dry_run
        self.keep = keep
