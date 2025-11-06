export SSL_CERT_FILE="";export REQUESTS_CA_BUNDLE="";export AWS_CA_BUNDLE="";
https://urllib3.readthedocs.io/en/1.26.x/advanced-usage.html#ssl-warnings
# 1.26.x/advanced-usage.html#ssl-warnings
#   warnings.warn(
# /opt/homebrew/Cellar/awscli/2.31.3/libexec/lib/python3.13/site-packages/urllib3/connectionpool.py:1064: InsecureRequestWarning: Unverified HTTPS request is being made to host 'ec2.us-east-2.amazonaws.com'. Adding certificate verification is strongly advised. See: https://urllib3.readthedocs.io/en/1.26.x/advanced-usage.html#ssl-warnings
#   warnings.warn(
# null

# Query for most recent Windows Server 2022 AMI from Image Builder
# Image Builder creates AMIs with pattern: amidistribution-YYYY-MM-DDTHH-MM-SS.sssZ
# NOTE: The "GoldenAMI" is stored as a TAG, not in the AMI name field!
#
# PRIMARY QUERY (filters by Tag "Name=GoldenAMI" - this is what the original query was looking for):
aws ec2 describe-images \
  --owners 422228628991 \
  --filters \
    "Name=tag:Name,Values=GoldenAMI" \
    "Name=platform-details,Values=Windows" \
    "Name=state,Values=available" \
    "Name=architecture,Values=x86_64" \
  --query 'sort_by(Images, &CreationDate)[-1].{AMI_ID:ImageId,Name:Name,CreationDate:CreationDate,Description:Description}' \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin

{
    "AMI_ID": "ami-03018fe8006ce8d21",
    "Name": "amidistribution-2025-10-20T16-28-54.190Z",
    "CreationDate": "2025-10-20T16:51:40.000Z",
    "Description": "AMI distribution from Central Image Management Account"
}

# ALTERNATIVE QUERY (matches Image Builder naming pattern by AMI name):
# aws ec2 describe-images \
#   --owners 422228628991 \
#   --filters \
#     "Name=name,Values=amidistribution-*" \
#     "Name=platform-details,Values=Windows" \
#     "Name=state,Values=available" \
#     "Name=architecture,Values=x86_64" \
#   --query 'sort_by(Images, &CreationDate)[-1].{AMI_ID:ImageId,Name:Name,CreationDate:CreationDate,Description:Description}' \
#   --region us-east-2 \
#   --profile SharedServices_imagemanagement_422228628991_admin

# ALTERNATIVE QUERY (if above doesn't work, try filtering by description):
# aws ec2 describe-images \
#   --owners 422228628991 \
#   --filters \
#     "Name=name,Values=amidistribution-*" \
#     "Name=platform-details,Values=Windows" \
#     "Name=state,Values=available" \
#     "Name=description,Values=*Windows Server 2022*" \
#   --query 'sort_by(Images, &CreationDate)[-1].{AMI_ID:ImageId,Name:Name,CreationDate:CreationDate,Description:Description}' \
#   --region us-east-2 \
#   --profile SharedServices_imagemanagement_422228628991_admin

# DEBUG QUERY (see all available Windows AMIs to understand the pattern):
# aws ec2 describe-images \
#   --owners 422228628991 \
#   --filters \
#     "Name=platform-details,Values=Windows" \
#     "Name=state,Values=available" \
#   --query 'sort_by(Images, &CreationDate)[-10:].{AMI_ID:ImageId,Name:Name,CreationDate:CreationDate,Description:Description}' \
#   --region us-east-2 \
#   --profile SharedServices_imagemanagement_422228628991_admin \
#   --output table

# QUERY SPECIFIC AMI - List all keys and values for ami-03018fe8006ce8d21:
# JSON output (full details):
aws ec2 describe-images \
  --image-ids ami-03018fe8006ce8d21 \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --query 'Images[0]' \
  --output json

# TABLE output (readable format for key properties):
# aws ec2 describe-images \
#   --image-ids ami-03018fe8006ce8d21 \
#   --region us-east-2 \
#   --profile SharedServices_imagemanagement_422228628991_admin \
#   --query 'Images[0].{ImageId:ImageId,Name:Name,Description:Description,CreationDate:CreationDate,State:State,Architecture:Architecture,Platform:Platform,PlatformDetails:PlatformDetails,OwnerId:OwnerId,RootDeviceType:RootDeviceType,RootDeviceName:RootDeviceName,VirtualizationType:VirtualizationType,Hypervisor:Hypervisor}' \
#   --output table

# ==============================================================================
# REVERSE LOOKUP: AMI to Pipeline/Recipe/Version/Build Details
# ==============================================================================
# From AMI: ami-03018fe8006ce8d21
# Get the Image Builder ARN tag from the AMI, then query Image Builder for details
#
# Step 1: Extract Image Builder ARN from AMI tags:
# aws ec2 describe-images \
#   --image-ids ami-03018fe8006ce8d21 \
#   --region us-east-2 \
#   --profile SharedServices_imagemanagement_422228628991_admin \
#   --query 'Images[0].Tags[?Key==`Ec2ImageBuilderArn`].Value' \
#   --output text
#
# Step 2: Get complete Image Build Version details (includes all pipeline info):
aws imagebuilder get-image \
  --image-build-version-arn "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2025/1.0.4/2" \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --output json

# Step 3: Get Pipeline details:
# aws imagebuilder get-image-pipeline \
#   --image-pipeline-arn "arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2025" \
#   --region us-east-2 \
#   --profile SharedServices_imagemanagement_422228628991_admin \
#   --output json

# Step 4: Get Recipe details:
# aws imagebuilder get-image-recipe \
#   --image-recipe-arn "arn:aws:imagebuilder:us-east-2:422228628991:image-recipe/winserver2025/1.0.4" \
#   --region us-east-2 \
#   --profile SharedServices_imagemanagement_422228628991_admin \
#   --output json

# ==============================================================================
# QUERY: Get AMI with Highest Version and Highest Build from Pipeline
# ==============================================================================
# Requirements:
# - Pipeline: ec2-image-builder-win2022 (static)
# - Status: AVAILABLE (static)
# - Region: us-east-2 (static)
# - OS: Microsoft Windows Server 2022 (static)
# - Version: HIGHEST_VERSION (dynamic - what we're looking for)
# - Build: HIGHEST_BUILD (dynamic - highest build of highest version)
#
# Approach: Query EC2 AMIs filtered by Image Builder pipeline tag,
# then sort by version/build numbers embedded in the ARN tag
#
# PRIMARY METHOD: Query EC2 with pipeline filter, sort by version/build
# Note: The Image Builder ARN uses recipe name 'winserver2022' (not pipeline name)
# Pipeline 'ec2-image-builder-win2022' creates images with recipe 'winserver2022'
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

# ALTERNATIVE METHOD: Using Image Builder list-images (if Python packaging not available)
# This lists images and filters by pipeline name pattern
# aws imagebuilder list-images \
#   --filters "name=name,values=WinServer2022" \
#   --region us-east-2 \
#   --profile SharedServices_imagemanagement_422228628991_admin \
#   --query 'imageVersionList[?state.status==`AVAILABLE` && osVersion==`Microsoft Windows Server 2022` && contains(arn, `ec2-image-builder-win2022`)].{ARN:arn,Version:version,Status:state.status}' \
#   --output json

# SIMPLE METHOD: Just get newest by creation date (if version parsing fails)
# Filters for winserver2022 recipe (used by ec2-image-builder-win2022 pipeline)
# aws ec2 describe-images \
#   --owners 422228628991 \
#   --filters \
#     "Name=platform-details,Values=Windows" \
#     "Name=state,Values=available" \
#     "Name=tag-key,Values=Ec2ImageBuilderArn" \
#   --region us-east-2 \
#   --profile SharedServices_imagemanagement_422228628991_admin \
#   --query 'Images[*].{AMI_ID:ImageId,ImageBuilderARN:Tags[?Key==`Ec2ImageBuilderArn`].Value | [0],CreationDate:CreationDate}' \
#   --output json | \
#   python3 -c "
# import json, sys
# data = json.load(sys.stdin)
# filtered = [x for x in data if x.get('ImageBuilderARN', '').lower().find('winserver2022') != -1]
# if filtered:
#     sorted_list = sorted(filtered, key=lambda x: x.get('CreationDate', ''), reverse=True)
#     print(json.dumps(sorted_list[0], indent=2))
# "


│ Error: Your query returned no results. Please change your search criteria and try again.
│ 
│   with data.aws_ami.windows_2022_latest,
│   on data.tf line 32, in data "aws_ami" "windows_2022_latest":
│   32: data "aws_ami" "windows_2022_latest" {
│ 