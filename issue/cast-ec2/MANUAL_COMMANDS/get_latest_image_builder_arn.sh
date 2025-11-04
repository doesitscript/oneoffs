#!/bin/bash
#
# Get Latest AVAILABLE Image Builder ARN by Recipe Name
# 
# This script finds the highest version/build image ARN for a given recipe name
# that has AVAILABLE state.
#
# Usage:
#   ./get_latest_image_builder_arn.sh [RECIPE_NAME] [AWS_REGION] [ACCOUNT_ID]
#
# Example:
#   ./get_latest_image_builder_arn.sh winserver2022 us-east-2 422228628991
#

set -euo pipefail

# Default values
RECIPE_NAME="${1:-winserver2022}"
AWS_REGION="${2:-us-east-2}"
ACCOUNT_ID="${3:-422228628991}"
AWS_PROFILE="${AWS_PROFILE:-SharedServices_imagemanagement_422228628991_admin}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Searching for latest AVAILABLE image for recipe: ${RECIPE_NAME}"
echo "   Account: ${ACCOUNT_ID}"
echo "   Region: ${AWS_REGION}"
echo ""

# Step 1: List all versions for the recipe
echo "Step 1: Listing all image versions..."
VERSION_ARNS=$(aws imagebuilder list-images \
    --region "${AWS_REGION}" \
    --profile "${AWS_PROFILE}" \
    --no-verify-ssl \
    --query "imageVersionList[?starts_with(arn, \`arn:aws:imagebuilder:${AWS_REGION}:${ACCOUNT_ID}:image/${RECIPE_NAME}/\`)].[arn]" \
    --output text 2>/dev/null || echo "")

if [ -z "$VERSION_ARNS" ]; then
    echo -e "${RED}❌ No images found for recipe: ${RECIPE_NAME}${NC}"
    exit 1
fi

echo "   Found $(echo "$VERSION_ARNS" | wc -l | tr -d ' ') version(s)"
echo ""

# Step 2: Query each version to get build-level details with state
echo "Step 2: Checking builds and states for each version..."
AVAILABLE_BUILDS=()

while IFS= read -r version_arn; do
    [ -z "$version_arn" ] && continue
    
    echo "   Checking: $version_arn"
    
    # Get image details - this returns the latest build for this version
    IMAGE_DETAILS=$(aws imagebuilder get-image \
        --region "${AWS_REGION}" \
        --profile "${AWS_PROFILE}" \
        --no-verify-ssl \
        --image-build-version-arn "${version_arn}" \
        --query '{arn:image.arn, state:image.state.status, version:image.version, build:image.name}' \
        --output json 2>/dev/null || echo "{}")
    
    if [ "$IMAGE_DETAILS" = "{}" ]; then
        echo "     ⚠️  No builds found (version may not exist or inaccessible)"
        continue
    fi
    
    STATE=$(echo "$IMAGE_DETAILS" | python3 -c "import json, sys; data=json.load(sys.stdin); print(data.get('state', 'UNKNOWN'))" 2>/dev/null || echo "UNKNOWN")
    BUILD_ARN=$(echo "$IMAGE_DETAILS" | python3 -c "import json, sys; data=json.load(sys.stdin); print(data.get('arn', ''))" 2>/dev/null || echo "")
    
    if [ "$STATE" = "AVAILABLE" ] && [ -n "$BUILD_ARN" ]; then
        echo "     ✅ AVAILABLE: $BUILD_ARN"
        AVAILABLE_BUILDS+=("$BUILD_ARN")
    else
        echo "     ❌ State: $STATE"
    fi
    
done <<< "$VERSION_ARNS"

echo ""

# Step 3: Parse version/build numbers and find the highest
if [ ${#AVAILABLE_BUILDS[@]} -eq 0 ]; then
    echo -e "${RED}❌ No AVAILABLE builds found for recipe: ${RECIPE_NAME}${NC}"
    exit 1
fi

echo "Step 3: Sorting available builds by version/build number..."
echo ""

# Parse ARNs and extract version/build for sorting
# ARN format: arn:aws:imagebuilder:REGION:ACCOUNT:image/RECIPE/VERSION/BUILD
SORTED_ARNS=$(printf '%s\n' "${AVAILABLE_BUILDS[@]}" | python3 << 'PYTHON_SCRIPT'
import json
import sys
import re

def parse_arn(arn):
    """Extract version and build from ARN"""
    # Format: arn:aws:imagebuilder:REGION:ACCOUNT:image/RECIPE/VERSION/BUILD
    parts = arn.split('/')
    if len(parts) >= 4:
        version_str = parts[-2]  # e.g., '1.0.3'
        build_str = parts[-1]    # e.g., '3'
        # Convert version to comparable tuple
        version_parts = [int(x) for x in version_str.split('.')]
        build_num = int(build_str)
        # Return sort key: (major, minor, patch, build)
        return (tuple(version_parts) + (build_num,), arn)
    return ((0, 0, 0, 0), arn)

arns = [line.strip() for line in sys.stdin if line.strip()]

# Parse and sort
parsed = [parse_arn(arn) for arn in arns]
sorted_arns = sorted(parsed, key=lambda x: x[0], reverse=True)

# Output the highest one
if sorted_arns:
    print(sorted_arns[0][1])
PYTHON_SCRIPT
)

if [ -z "$SORTED_ARNS" ]; then
    echo -e "${RED}❌ Failed to determine latest build${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Latest AVAILABLE build:${NC}"
echo -e "${GREEN}${SORTED_ARNS}${NC}"
echo ""

# Output as single line for scripting use
echo "$SORTED_ARNS"

