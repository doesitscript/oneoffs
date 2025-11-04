# Get AMI with Highest Version and Highest Build

## Requirements

**Static Values (Fixed Parameters)**:
- **Pipeline**: `ec2-image-builder-win2022`
- **Status**: `AVAILABLE`
- **Region**: `us-east-2`
- **OS**: `Microsoft Windows Server 2022`

**Dynamic Values (What We're Looking For)**:
- **Version**: `HIGHEST_VERSION` (latest version number)
- **Build**: `HIGHEST_BUILD` (highest build number of that highest version)

## Command

```bash
aws ec2 describe-images \
  --owners 422228628991 \
  --filters \
    "Name=platform-details,Values=Windows" \
    "Name=state,Values=available" \
    "Name=tag-key,Values=Ec2ImageBuilderArn" \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --query 'Images[*].{AMI_ID:ImageId,ImageBuilderARN:Tags[?Key==`Ec2ImageBuilderArn`].Value | [0]}' \
  --output json | \
  python3 -c "
import json, sys

data = json.load(sys.stdin)
# The Image Builder ARN format: arn:aws:imagebuilder:REGION:ACCOUNT:image/RECIPE/VERSION/BUILD
# Extract version/build: VERSION is like '1.0.3', BUILD is like '2', combined as '1.0.3/2'

def parse_version_build(arn):
    if not arn:
        return None
    try:
        # Extract the version/build part from ARN: image/RECIPE/VERSION/BUILD
        parts = arn.split('/')
        if len(parts) >= 4:
            version_str = parts[-2]  # e.g., '1.0.3'
            build_str = parts[-1]    # e.g., '2'
            # Convert version to tuple for comparison: (major, minor, patch)
            version_parts = version_str.split('.')
            version_tuple = tuple(int(x) for x in version_parts)
            build_num = int(build_str)
            return (version_tuple, build_num, version_str, build_str)
    except:
        pass
    return None

# Filter and parse
parsed = []
for item in data:
    arn = item.get('ImageBuilderARN', [''])[0] if isinstance(item.get('ImageBuilderARN'), list) else item.get('ImageBuilderARN', '')
    if not arn:
        continue
    # Only process if ARN contains the recipe name (pipeline ec2-image-builder-win2022 uses recipe winserver2022)
    # Image ARN format: arn:aws:imagebuilder:REGION:ACCOUNT:image/RECIPE/VERSION/BUILD
    if 'winserver2022' not in arn.lower():
        continue
    vb = parse_version_build(arn)
    if vb:
        parsed.append({
            'AMI_ID': item['AMI_ID'],
            'Version': vb[2],  # version_str
            'Build': vb[3],    # build_str
            'VersionBuild': (vb[0], vb[1]),  # (version_tuple, build_num) for sorting
            'ARN': arn
        })

# Sort by version (desc) then build (desc), get the highest
if parsed:
    sorted_list = sorted(parsed, key=lambda x: x['VersionBuild'], reverse=True)
    highest = sorted_list[0]
    print(json.dumps({
        'AMI_ID': highest['AMI_ID'],
        'Version': highest['Version'],
        'Build': highest['Build'],
        'FullVersion': f\"{highest['Version']}/{highest['Build']}\",
        'ImageBuilderARN': highest['ARN']
    }, indent=2))
else:
    print('{}')
"
```

## How It Works

1. **Query EC2 AMIs**: Gets all available Windows AMIs owned by account `422228628991` that have Image Builder ARN tags
2. **Filter by Recipe**: Python script filters for ARNs containing `winserver2022` (the recipe name used by pipeline `ec2-image-builder-win2022`)
3. **Parse Version/Build**: Extracts version and build numbers from the Image Builder ARN
   - ARN format: `arn:aws:imagebuilder:REGION:ACCOUNT:image/RECIPE/VERSION/BUILD`
   - Example: `arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/2`
     - Recipe: `winserver2022`
     - Version: `1.0.3`
     - Build: `2`
4. **Sort**: Sorts by version (descending), then by build number (descending)
5. **Return Highest**: Returns the AMI with the highest version and highest build

## Example Output

```json
{
  "AMI_ID": "ami-06e5b9cbee7ab08c8",
  "Version": "1.0.3",
  "Build": "2",
  "FullVersion": "1.0.3/2",
  "ImageBuilderARN": "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/2"
}
```

## Key Points

- **Pipeline Name vs Recipe Name**: The pipeline `ec2-image-builder-win2022` creates images using the recipe `winserver2022`. The Image Builder ARN tag on AMIs contains the recipe name, not the pipeline name.
- **Version Sorting**: Versions are sorted numerically (e.g., `1.0.2` < `1.0.3` < `1.1.0`)
- **Build Sorting**: Within the same version, builds are sorted numerically (e.g., build `1` < build `2`)

## Simplified Version (Just AMI ID)

If you only need the AMI ID as output:

```bash
aws ec2 describe-images \
  --owners 422228628991 \
  --filters \
    "Name=platform-details,Values=Windows" \
    "Name=state,Values=available" \
    "Name=tag-key,Values=Ec2ImageBuilderArn" \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --query 'Images[*].{AMI_ID:ImageId,ImageBuilderARN:Tags[?Key==`Ec2ImageBuilderArn`].Value | [0]}' \
  --output json | \
  python3 -c "
import json, sys
data = json.load(sys.stdin)
def parse_vb(arn):
    if not arn or 'winserver2022' not in arn.lower():
        return None
    try:
        parts = arn.split('/')
        if len(parts) >= 4:
            v_parts = [int(x) for x in parts[-2].split('.')]
            b = int(parts[-1])
            return (tuple(v_parts), b)
    except: pass
    return None
parsed = [(item['AMI_ID'], parse_vb(item.get('ImageBuilderARN', [''])[0] if isinstance(item.get('ImageBuilderARN'), list) else item.get('ImageBuilderARN', ''))) for item in data]
parsed = [(ami, vb) for ami, vb in parsed if vb]
if parsed:
    print(sorted(parsed, key=lambda x: x[1], reverse=True)[0][0])
"
```

This will output just the AMI ID: `ami-06e5b9cbee7ab08c8`



