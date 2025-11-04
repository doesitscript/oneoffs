Constructing two commands: first query Image Builder for the pipeline image ARN, then use that ARN to filter EC2 AMIs:


[3 tools called]

## Step 1: Get Image ARN from Image Builder Pipeline

Query the pipeline to find the highest version/build image ARN:

```bash
aws imagebuilder list-image-pipeline-images \
  --image-pipeline-arn "arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2022" \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --query 'imageSummaryList[?imageStatus==`AVAILABLE`].{ARN:arn,Version:version}' \
  --output json
```

This returns images from the pipeline. Sort by version/build to get: `arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/2`

## Step 2: Get EC2 AMI Using the Specific ARN

Use that exact ARN to filter EC2 AMIs:

```bash
IMAGE_ARN="arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/2"

aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --profile SharedServices_imagemanagement_422228628991_admin \
  --filters \
    "Name=tag:Ec2ImageBuilderArn,Values=$IMAGE_ARN" \
    "Name=state,Values=available" \
  --query 'Images[*].{AMI_ID:ImageId,Name:Name,ARN:Tags[?Key==`Ec2ImageBuilderArn`].Value | [0]}' \
  --output json

```

Change: Use `tag:Ec2ImageBuilderArn` with the exact ARN value (not just checking if the tag key exists).

Files created:
- `get_ami_commands.sh` - Automated script that does both steps
- `manual_commands.md` - Documentation with both commands plus a combined one-liner

Final filter (lines 136-146)
Uses tag:Ec2ImageBuilderArn with the exact ARN value (e.g., arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/2)
This matches the CLI command approach
This ensures:
It queries the Image Builder pipeline first
It only gets AMIs from that specific pipeline's recipe
It uses the exact ARN to filter (matching your CLI command)
It returns ami-08acfbd98127249e6 for the highest version/build



I#I#I#I# its own p8,,7]


MLLXLJJ2XVFJ:cast a805120$ aws imagebuilder list-image-pipeline-images   --image-pipeline-arn "arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2022"   --region us-east-2   --profile SharedServices_imagemanagement_422228628991_admin   --query 'imageSummaryList[?imageStatus==`AVAILABLE`].{ARN:arn,Version:version}'   --output jsonimagebuilder list-image-pipeline-images   --image-pipeline-arn "arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2022"   --region us-east-2   --profile SharedServices_imagemanagement_422228628991_admin   --query 'imageSummaryList[?imageStatus==`AVAILABLE`].{ARN:arn,Version:version}'   --output json

aws: [ERROR]: argument --output: Found invalid choice 'jsonimagebuilder'
