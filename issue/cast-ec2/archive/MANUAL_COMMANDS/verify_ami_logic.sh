#!/bin/bash

set -e

echo "Verifying Terraform AMI selection logic..."
echo "Expected result: ami-08acfbd98127249e6"
echo ""

aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --filters \
    "Name=tag-key,Values=Ec2ImageBuilderArn" \
    "Name=platform-details,Values=Windows" \
    "Name=state,Values=available" \
  --query 'Images[*].{AMI_ID:ImageId,ARN:Tags[?Key==`Ec2ImageBuilderArn`].Value | [0],CreationDate:CreationDate}' \
  --output json | python3 << 'PYTHON_SCRIPT'
import json, sys

data = json.load(sys.stdin)

def parse_version_build(arn):
    if not arn or not isinstance(arn, str):
        return None
    try:
        if 'winserver2022' not in arn.lower():
            return None
        parts = arn.split('/')
        if len(parts) >= 4:
            version_str = parts[-2]
            build_str = parts[-1]
            version_parts = version_str.split('.')
            version_tuple = tuple(int(x) for x in version_parts)
            build_num = int(build_str)
            return (version_tuple, build_num, version_str, build_str)
    except:
        pass
    return None

parsed = []
for item in data:
    arn = item.get('ARN', [''])[0] if isinstance(item.get('ARN'), list) else item.get('ARN', '')
    vb = parse_version_build(arn)
    if vb:
        parsed.append({
            'AMI_ID': item['AMI_ID'],
            'Version': vb[2],
            'Build': vb[3],
            'VersionBuild': (vb[0], vb[1]),
            'ARN': arn
        })

if parsed:
    sorted_list = sorted(parsed, key=lambda x: x['VersionBuild'], reverse=True)
    highest = sorted_list[0]
    print('✅ Highest Version/Build AMI Found:')
    print(json.dumps({
        'AMI_ID': highest['AMI_ID'],
        'Version': highest['Version'],
        'Build': highest['Build'],
        'FullVersion': f"{highest['Version']}/{highest['Build']}",
        'ARN': highest['ARN']
    }, indent=2))
    print(f"\nExpected: ami-08acfbd98127249e6")
    print(f"Found:    {highest['AMI_ID']}")
    if highest['AMI_ID'] == 'ami-08acfbd98127249e6':
        print("✅ MATCH - Logic is correct!")
    else:
        print("❌ NO MATCH - Logic needs adjustment")
    
    if len(parsed) > 1:
        print(f"\nAll {len(parsed)} winserver2022 AMIs (sorted by version/build):")
        for i, p in enumerate(sorted_list[:10], 1):
            marker = " <-- SELECTED" if i == 1 else ""
            print(f"  {i}. {p['AMI_ID']} - Version {p['Version']}/{p['Build']}{marker}")
else:
    print('❌ No winserver2022 AMIs found')

PYTHON_SCRIPT

