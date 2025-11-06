Missing attributes (compared to main() function):
keep: int (default 0)
tag: Optional[List[str]]
copy_instance_tags: Optional[List[str]]
copy_volume_tags: Optional[List[str]]
Additional issues:
Type hint inconsistency: class uses list[str] but should use List[str] (capital L) since you're using from typing import Optional. You'll need from typing import Optional, List.
__init__ parameters should be Optional (except keep, wait, dry_run) to match main().
Default values: __init__ should have defaults matching main().
What you need to add:
Add the 4 missing attributes to the class definition (lines 5-11)
Add them to __init__ parameters (lines 13-22)
Assign them in __init__ (lines 23-29)
Fix the type hints to use List[str] instead of list[str]
Make parameters Optional where appropriate