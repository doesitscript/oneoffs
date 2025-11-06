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
    keep: int

    def __init__(
        self,
        instance_id: Optional[List[str]] = None,
        tag: Optional[List[str]] = None,
        copy_instance_tags: Optional[List[str]] = None,
        copy_volume_tags: Optional[List[str]] = None,
        filter: Optional[List[str]] = None,
        policy: Optional[str] = None,
        region: Optional[str] = None,
        profile: Optional[str] = None,
        wait: bool = False,
        dry_run: bool = False,
        keep: int = 0,
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
