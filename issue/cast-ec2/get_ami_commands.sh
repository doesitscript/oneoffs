#!/bin/bash

echo "Step 1: Get Image ARN from Image Builder pipeline 'ec2-image-builder-win2022'"
echo "Finding highest version/build image..."
echo ""

IMAGE_ARN=$(aws imagebuilder list-image-pipeline-images \
  --image-pipeline-arn "arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2022" \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --query 'imageSummaryList[?imageStatus==`AVAILABLE`].{ARN:arn,Version:version,Date:dateCreated}' \
  --output json | python3 << 'PYTHON_SCRIPT'
import json, sys
from datetime import datetime

data = json.load(sys.stdin)

def parse_version_build(arn):
    if not arn:
        return None
    try:
        parts = arn.split('/')
        if len(parts) >= 4:
            recipe_version = parts[-2]
            build = parts[-1]
            version_parts = recipe_version.split('.')
            version_tuple = tuple(int(x) for x in version_parts)
            build_num = int(build)
            return (version_tuple, build_num, recipe_version, build)
    except:
        pass
    return None

parsed = []
for item in data:
    vb = parse_version_build(item.get('ARN', ''))
    if vb:
        parsed.append({
            'ARN': item['ARN'],
            'Version': vb[2],
            'Build': vb[3],
            'VersionBuild': (vb[0], vb[1]),
            'Date': item.get('Date', '')
        })

if parsed:
    sorted_list = sorted(parsed, key=lambda x: x['VersionBuild'], reverse=True)
    highest = sorted_list[0]
    print(highest['ARN'])
else:
    sys.exit(1)
PYTHON_SCRIPT
)

if [ -z "$IMAGE_ARN" ]; then
    echo "ERROR: Could not find Image ARN from pipeline"
    exit 1
fi

echo "Found Image ARN: $IMAGE_ARN"
echo ""
echo "Step 2: Get EC2 AMI ID using the Image Builder ARN"
echo ""

aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --filters \
    "Name=tag:Ec2ImageBuilderArn,Values=$IMAGE_ARN" \
    "Name=state,Values=available" \
  --query 'Images[*].{AMI_ID:ImageId,Name:Name,Region:ImageLocation,ARN:Tags[?Key==`Ec2ImageBuilderArn`].Value | [0]}' \
  --output json | python3 << 'PYTHON_SCRIPT'
import json, sys

data = json.load(sys.stdin)

if data:
    ami = data[0]
    print("✅ Found AMI:")
    print(json.dumps(ami, indent=2))
    print(f"\nExpected: ami-08acfbd98127249e6")
    print(f"Found:    {ami['AMI_ID']}")
    if ami['AMI_ID'] == 'ami-08acfbd98127249e6':
        print("✅ MATCH!")
    else:
        print("❌ NO MATCH")
else:
    print("❌ No AMI found with that ARN")
    sys.exit(1)
PYTHON_SCRIPT

