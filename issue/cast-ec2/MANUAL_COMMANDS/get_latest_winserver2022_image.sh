#!/bin/bash
#
# Get Latest AVAILABLE Windows Server 2022 Image with Full Details
#
# This command finds the highest version/build for winserver2022 and returns
# the complete image details including AMI IDs.
#
# Usage:
#   ./get_latest_winserver2022_image.sh [REGION] [ACCOUNT_ID] [PROFILE]
#
# Example:
#   ./get_latest_winserver2022_image.sh us-east-2 422228628991 SharedServices_imagemanagement_422228628991_admin
#

set -euo pipefail

AWS_REGION="${1:-us-east-2}"
ACCOUNT_ID="${2:-422228628991}"
AWS_PROFILE="${3:-SharedServices_imagemanagement_422228628991_admin}"
RECIPE_NAME="winserver2022"

# Step 1: Get all version ARNs for the recipe
# Step 2: Query each version to get build details (get-image returns latest build for version)
# Step 3: Filter for AVAILABLE, sort by version/build, get highest
# Step 4: Get full image details for the highest one

LATEST_ARN=$(aws imagebuilder list-images \
    --region "${AWS_REGION}" \
    --profile "${AWS_PROFILE}" \
    --no-verify-ssl \
    --query "imageVersionList[?starts_with(arn, \`arn:aws:imagebuilder:${AWS_REGION}:${ACCOUNT_ID}:image/${RECIPE_NAME}/\`)].[arn]" \
    --output text 2>/dev/null | \
while IFS= read -r version_arn; do
    [ -z "$version_arn" ] && continue
    aws imagebuilder get-image \
        --region "${AWS_REGION}" \
        --profile "${AWS_PROFILE}" \
        --no-verify-ssl \
        --image-build-version-arn "$version_arn" \
        --query '{arn:image.arn, state:image.state.status}' \
        --output json 2>/dev/null || echo "{}"
done | python3 << 'PYTHON_SCRIPT'
import json
import sys

def parse_arn(arn):
    """Extract version and build from ARN for sorting"""
    try:
        parts = arn.split('/')
        if len(parts) >= 4:
            version_str = parts[-2]  # e.g., '1.0.3'
            build_str = parts[-1]    # e.g., '3'
            version_parts = tuple(int(x) for x in version_str.split('.'))
            build_num = int(build_str)
            return (version_parts, build_num), arn
    except:
        pass
    return None, None

available_images = []
for line in sys.stdin:
    line = line.strip()
    if not line or line == "{}":
        continue
    try:
        data = json.loads(line)
        state = data.get('state', '')
        arn = data.get('arn', '')
        if state == 'AVAILABLE' and arn:
            sort_key, _ = parse_arn(arn)
            if sort_key:
                available_images.append((sort_key, arn))
    except:
        continue

if not available_images:
    sys.exit(1)

# Sort by (version_tuple, build_num) descending
available_images.sort(key=lambda x: x[0], reverse=True)
print(available_images[0][1])
PYTHON_SCRIPT)

if [ -z "$LATEST_ARN" ]; then
    echo "ERROR: No AVAILABLE builds found for ${RECIPE_NAME}" >&2
    exit 1
fi

# Step 4: Get full image details
aws imagebuilder get-image \
    --image-build-version-arn "$LATEST_ARN" \
    --region "${AWS_REGION}" \
    --profile "${AWS_PROFILE}" \
    --no-verify-ssl \
    --output json

