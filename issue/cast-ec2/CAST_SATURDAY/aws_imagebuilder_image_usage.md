# Using `aws_imagebuilder_image` Data Source

## Yes, this is what you need! ✅

If you already have an Image Builder ARN (which you do), `aws_imagebuilder_image` is exactly what you need.

---

## Current vs Better Approach

### Your Current Approach (Lines 179-189):
```hcl
# You're filtering AMIs by tag to find the AMI
data "aws_imagebuilder_image" "windows_2022_latest" {
  count = local.highest_version_build_arn != null ? 1 : 0
  filter {
    name   = "tag:Ec2ImageBuilderArn"
    values = [local.highest_version_build_arn]  # Using ARN here
  }
  filter {
    name   = "state"
    values = ["available"]
  }
  owners = [local.owner]
}
```

### Better Approach (Direct Image Builder lookup):
```hcl
# Get Image Builder image details directly using the ARN
data "aws_imagebuilder_image" "windows_2022_latest" {
  count = local.highest_version_build_arn != null ? 1 : 0
  arn   = local.highest_version_build_arn  # Direct ARN lookup!
}

# Extract AMI ID from Image Builder output
locals {
  latest_ami_id_from_builder = try(
    data.aws_imagebuilder_image.windows_2022_latest[0].output_resources[0].amis[0].image,
    null
  )
}
```

---

## Why This Is Better

1. **Direct lookup** - No need to filter through all AMIs
2. **More information** - Gets full Image Builder metadata
3. **Faster** - Single API call instead of filtering
4. **Uses Image Builder ARN directly** - What you already have!

---

## What You Get From `aws_imagebuilder_image`

When you use `aws_imagebuilder_image` with an ARN, you get:

- `output_resources[0].amis[0].image` - **The AMI ID** ← What you need!
- `output_resources[0].amis[0].region` - AMI region
- `output_resources[0].amis[0].name` - AMI name
- `version` - Image version
- `platform` - Platform details
- `date_created` - Creation date
- Full Image Builder metadata

---

## Complete Example for Your Code

You can replace your current AMI filtering approach with:

```hcl
# After you determine highest_version_build_arn (your existing logic)
locals {
  highest_version_build_arn = try(
    # ... your existing logic ...
  )
}

# Use Image Builder data source directly
data "aws_imagebuilder_image" "windows_2022_latest" {
  count = local.highest_version_build_arn != null ? 1 : 0
  arn   = local.highest_version_build_arn
}

# Get AMI ID from Image Builder
locals {
  # Your existing approach gets AMI from tag filter
  # But you could also get it directly:
  latest_ami_id_from_imagebuilder = try(
    data.aws_imagebuilder_image.windows_2022_latest[0].output_resources[0].amis[0].image,
    null
  )
}
```

---

## When to Use Each

| Data Source | Use When | Gets |
|------------|----------|------|
| `aws_imagebuilder_image` | ✅ You have Image Builder ARN | Image Builder details + AMI ID |
| `aws_ami` (filter by tag) | You only have AMI tag | AMI details |
| `list-image-pipeline-images` | Need to list ALL images from pipeline | List of all images |

**For your case:** Since you already extract the Image Builder ARN from AMI tags, `aws_imagebuilder_image` is perfect! ✅


