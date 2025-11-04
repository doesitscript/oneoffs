# AMI Reverse Lookup - Requirements & Step-by-Step Guide

## 📋 Prerequisites & Requirements

### 1. AWS Access Requirements
- **AWS Account Access**: Must have access to account `422228628991` (Image Management Account)
- **AWS Profile**: `SharedServices_imagemanagement_422228628991_admin` profile configured
- **Region**: Primary region is `us-east-2` (some resources may be in other regions)
- **IAM Permissions**: Need the following permissions:
  - `ec2:DescribeImages` - To query AMI details
  - `imagebuilder:GetImage` - To get image build version details
  - `imagebuilder:GetImagePipeline` - To get pipeline configuration
  - `imagebuilder:GetImageRecipe` - To get recipe details
  - `imagebuilder:GetInfrastructureConfiguration` - To get infrastructure config (optional)
  - `imagebuilder:GetDistributionConfiguration` - To get distribution config (optional)

### 2. Starting Information Required
- **AMI ID**: The Amazon Machine Image ID you want to reverse lookup
  - Example: `ami-03018fe8006ce8d21`
- **Region**: The AWS region where the AMI exists
  - Example: `us-east-2`

### 3. Tools Required
- **AWS CLI**: Version 2.x installed and configured
- **Shell Access**: Bash or compatible shell
- **SSL Certificate Handling**: (Optional) If using corporate SSL, may need to disable validation:
  ```bash
  export AWS_CA_BUNDLE=""
  export SSL_CERT_FILE=""
  export REQUESTS_CA_BUNDLE=""
  ```

---

## 🔍 Step-by-Step Process

### Step 1: Verify AMI Exists and Get Basic Details

**Purpose**: Confirm the AMI exists and get basic information including the Image Builder ARN tag.

**Command**:
```bash
aws ec2 describe-images \
  --image-ids ami-03018fe8006ce8d21 \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --query 'Images[0]' \
  --output json
```

**What This Returns**:
- AMI basic details (name, creation date, state, platform, etc.)
- **IMPORTANT**: Look for the `Ec2ImageBuilderArn` tag in the Tags array
  - This ARN format: `arn:aws:imagebuilder:REGION:ACCOUNT:image/RECIPE_NAME/VERSION/BUILD`
  - Example: `arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2025/1.0.4/2`

**Alternative - Extract Just the ARN**:
```bash
aws ec2 describe-images \
  --image-ids ami-03018fe8006ce8d21 \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --query 'Images[0].Tags[?Key==`Ec2ImageBuilderArn`].Value' \
  --output text
```

**What You Need From This Step**:
- ✅ Confirmation AMI exists and is accessible
- ✅ **Image Build Version ARN** (from the `Ec2ImageBuilderArn` tag)
  - Format: `arn:aws:imagebuilder:REGION:ACCOUNT:image/RECIPE_NAME/VERSION/BUILD`
  - This ARN contains: Recipe name, Version number, Build number

---

### Step 2: Get Complete Image Build Version Details

**Purpose**: Get comprehensive information about the specific image build, including recipe, pipeline, infrastructure, and distribution details.

**Required Information from Step 1**:
- Image Build Version ARN
  - Example: `arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2025/1.0.4/2`

**Command**:
```bash
aws imagebuilder get-image \
  --image-build-version-arn "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2025/1.0.4/2" \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --output json
```

**What This Returns**:
- **Image Details**:
  - Image name, version, build number
  - Status (AVAILABLE, BUILDING, FAILED, etc.)
  - Build type (USER_INITIATED, SCHEDULED, etc.)
  - Creation date
- **Recipe Information** (embedded):
  - Recipe ARN, name, version
  - Components installed
  - Parent/base image
  - Block device mappings
- **Pipeline Information** (embedded):
  - Pipeline ARN: `sourcePipelineArn`
- **Infrastructure Configuration** (embedded):
  - Instance types, security groups, subnet
  - Instance profile, key pair
- **Distribution Configuration** (embedded):
  - Regions where AMI is distributed
  - AMI IDs in each region
  - AMI tags and permissions

**What You Extract From This Step**:
- ✅ **Pipeline ARN**: From `sourcePipelineArn` field
  - Example: `arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2025`
- ✅ **Recipe ARN**: From `imageRecipe.arn` field
  - Example: `arn:aws:imagebuilder:us-east-2:422228628991:image-recipe/winserver2025/1.0.4`
- ✅ **Version**: From `version` field (shows version and build)
  - Example: `1.0.4/2` (version 1.0.4, build #2)
- ✅ **Components**: List of all components installed
- ✅ **Distribution**: Where the AMI is available

---

### Step 3: Get Pipeline Details (Optional but Recommended)

**Purpose**: Get detailed pipeline configuration including schedule, triggers, and settings.

**Required Information from Step 2**:
- Pipeline ARN
  - Example: `arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2025`

**Command**:
```bash
aws imagebuilder get-image-pipeline \
  --image-pipeline-arn "arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2025" \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --output json
```

**What This Returns**:
- Pipeline name and description
- **Schedule**: Cron expression for automated builds
  - Example: `cron(0 22 ? * 2#2 *)` (2nd Tuesday at 10 PM UTC)
- Pipeline status (ENABLED/DISABLED)
- Execution conditions
- Last run date
- Next scheduled run
- Associated recipe, infrastructure, and distribution ARNs

**What You Extract From This Step**:
- ✅ **Pipeline Name**: Human-readable pipeline identifier
- ✅ **Schedule**: When/how often builds run automatically
- ✅ **Last Run Date**: When this specific build was triggered
- ✅ **Next Run Date**: When the next build will run
- ✅ **Pipeline Status**: Whether pipeline is active

---

### Step 4: Get Recipe Details (Optional but Recommended)

**Purpose**: Get detailed recipe configuration including exact component versions and configurations.

**Required Information from Step 2**:
- Recipe ARN
  - Example: `arn:aws:imagebuilder:us-east-2:422228628991:image-recipe/winserver2025/1.0.4`

**Command**:
```bash
aws imagebuilder get-image-recipe \
  --image-recipe-arn "arn:aws:imagebuilder:us-east-2:422228628991:image-recipe/winserver2025/1.0.4" \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --output json
```

**What This Returns**:
- Recipe name and version
- **Complete Component List**: All components with their ARNs
- **Parent Image**: Base image used
- **Block Device Mappings**: Storage configuration
- **Working Directory**: Base directory for installations
- Recipe creation date
- Tags applied

**What You Extract From This Step**:
- ✅ **Exact Component Versions**: See all components and their versions
- ✅ **Base Image**: What the recipe builds on top of
- ✅ **Storage Configuration**: Volume sizes, types, encryption
- ✅ **Component Order**: Sequence of component installations

---

## 📊 Understanding the Results

### Version & Build Number Breakdown

The Image Build Version ARN follows this pattern:
```
arn:aws:imagebuilder:REGION:ACCOUNT:image/RECIPE_NAME/VERSION/BUILD
```

**Example**: `arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2025/1.0.4/2`

- **Recipe Name**: `winserver2025`
- **Version**: `1.0.4` (recipe version)
- **Build**: `2` (this is the 2nd build of version 1.0.4)

**What This Means**:
- The recipe `winserver2025` has version `1.0.4`
- This specific AMI is build #2 of that version
- If the recipe is updated to version `1.0.5`, that would be a new version
- Multiple builds of the same version can exist (1.0.4/1, 1.0.4/2, etc.)

### Key Information Flow

```
AMI ID (Starting Point)
    ↓
Step 1: Get AMI Details
    ↓
Extract: Image Build Version ARN
    ↓
Step 2: Get Image Build Details
    ↓
Extract: Pipeline ARN, Recipe ARN, Version/Build Info
    ↓
Step 3: Get Pipeline Details (Optional)
    ↓
Step 4: Get Recipe Details (Optional)
```

---

## 🎯 Quick Reference: Minimum Required Steps

**If you only need basic info (Pipeline, Recipe, Version, Build)**:

1. **Step 1**: Get AMI details and extract `Ec2ImageBuilderArn` tag
2. **Step 2**: Use that ARN to get image build details
   - From Step 2, you get:
     - Pipeline ARN
     - Recipe ARN  
     - Version and Build number
     - All major details

**Steps 3 & 4 are optional** for deeper details about pipeline schedule and recipe components.

---

## 🔧 Troubleshooting

### Issue: AMI Not Found
- **Check**: AMI exists in the specified region
- **Check**: Correct AWS profile is being used
- **Check**: You have `ec2:DescribeImages` permission

### Issue: Image Builder ARN Tag Missing
- **Cause**: AMI was not created by Image Builder
- **Solution**: This reverse lookup only works for Image Builder-created AMIs

### Issue: Permission Denied
- **Check**: IAM permissions for Image Builder APIs
- **Check**: AWS profile has access to account `422228628991`
- **Required Permissions**: `imagebuilder:GetImage`, `imagebuilder:GetImagePipeline`, `imagebuilder:GetImageRecipe`

### Issue: SSL Certificate Errors
```bash
# Disable SSL validation (for corporate environments)
export AWS_CA_BUNDLE=""
export SSL_CERT_FILE=""
export REQUESTS_CA_BUNDLE=""
```

---

## 📝 Example Complete Workflow

```bash
# Set up environment (if needed)
export AWS_CA_BUNDLE=""
export SSL_CERT_FILE=""
export REQUESTS_CA_BUNDLE=""

# Step 1: Get AMI and extract Image Builder ARN
AMI_ID="ami-03018fe8006ce8d21"
REGION="us-east-2"
PROFILE="SharedServices_imagemanagement_422228628991_admin"

IMAGE_ARN=$(aws ec2 describe-images \
  --image-ids $AMI_ID \
  --region $REGION \
  --profile $PROFILE \
  --query 'Images[0].Tags[?Key==`Ec2ImageBuilderArn`].Value' \
  --output text)

echo "Image Build ARN: $IMAGE_ARN"

# Step 2: Get complete image details
aws imagebuilder get-image \
  --image-build-version-arn "$IMAGE_ARN" \
  --region $REGION \
  --profile $PROFILE \
  --output json > image_details.json

# Step 3: Extract Pipeline ARN and get pipeline details
PIPELINE_ARN=$(aws imagebuilder get-image \
  --image-build-version-arn "$IMAGE_ARN" \
  --region $REGION \
  --profile $PROFILE \
  --query 'image.sourcePipelineArn' \
  --output text)

echo "Pipeline ARN: $PIPELINE_ARN"

aws imagebuilder get-image-pipeline \
  --image-pipeline-arn "$PIPELINE_ARN" \
  --region $REGION \
  --profile $PROFILE \
  --output json > pipeline_details.json

# Step 4: Extract Recipe ARN and get recipe details
RECIPE_ARN=$(aws imagebuilder get-image \
  --image-build-version-arn "$IMAGE_ARN" \
  --region $REGION \
  --profile $PROFILE \
  --query 'image.imageRecipe.arn' \
  --output text)

echo "Recipe ARN: $RECIPE_ARN"

aws imagebuilder get-image-recipe \
  --image-recipe-arn "$RECIPE_ARN" \
  --region $REGION \
  --profile $PROFILE \
  --output json > recipe_details.json
```

---

## 📌 Summary Checklist

To perform an AMI reverse lookup, you need:

- [ ] **Starting Point**: AMI ID
- [ ] **AWS Access**: Profile with access to account `422228628991`
- [ ] **Region**: Know which region the AMI is in
- [ ] **IAM Permissions**: 
  - [ ] `ec2:DescribeImages`
  - [ ] `imagebuilder:GetImage`
  - [ ] `imagebuilder:GetImagePipeline` (optional)
  - [ ] `imagebuilder:GetImageRecipe` (optional)
- [ ] **Tools**: AWS CLI installed and configured

**Minimum Steps to Get Core Info**:
1. [ ] Query AMI to get `Ec2ImageBuilderArn` tag
2. [ ] Use that ARN to query `get-image` API
3. [ ] Extract Pipeline, Recipe, Version, and Build from results

**Optional Steps for Complete Details**:
4. [ ] Query pipeline details for schedule info
5. [ ] Query recipe details for component versions



