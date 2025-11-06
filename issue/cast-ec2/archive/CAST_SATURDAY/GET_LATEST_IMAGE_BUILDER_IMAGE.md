# Getting the Latest Image Builder Image

## The Problem You Identified ✅

You're absolutely right! There's a chicken-and-egg problem:
- To get image details, you need the full ARN with version (e.g., `/1.0.3/3`)
- But to know the latest version, you'd need to query it first!
- How do you get the latest without knowing what "latest" is?

---

## Solution: Use Wildcards! ✅

### Standard AWS Provider Supports Wildcards

The `aws_imagebuilder_image` data source **supports wildcards** in the ARN to get the latest version automatically!

```hcl
data "aws_imagebuilder_image" "latest" {
  arn = "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/x.x.x"
  #                                                                    ^^^^^^^^
  #                                                                    Wildcard!
}
```

**The `x.x.x` wildcard automatically resolves to the latest version!**

---

## How It Works

### Image Builder ARN Format:
```
arn:aws:imagebuilder:REGION:ACCOUNT:image/NAME/VERSION/BUILD
                                          ^^^^^  ^^^^^^^  ^^^^^
                                          Name   Version  Build
```

### With Wildcard:
```
arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/x.x.x
                                                          ^^^^^^^^
                                                          Latest version automatically
```

When you use `x.x.x`, Image Builder API automatically resolves it to the most recent version.

---

## Complete Working Example

```hcl
locals {
  image_builder_account = "422228628991"
  image_name           = "winserver2022"  # From Image Builder pipeline/recipe name
  region               = "us-east-2"
}

# Get latest Image Builder image using wildcard
data "aws_imagebuilder_image" "latest" {
  arn = "arn:aws:imagebuilder:${local.region}:${local.image_builder_account}:image/${local.image_name}/x.x.x"
}

# Extract AMI ID
locals {
  latest_ami_id = data.aws_imagebuilder_image.latest.output_resources[0].amis[0].image
}

# Use in EC2 instance
resource "aws_instance" "example" {
  ami = local.latest_ami_id
  # ...
}
```

---

## Using AWSCC Provider (Alternative)

AWSCC provider also works with wildcards:

```hcl
data "awscc_imagebuilder_image" "latest" {
  id = "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/x.x.x"
}

# Get AMI ID directly (simpler!)
locals {
  latest_ami_id = data.awscc_imagebuilder_image.latest.image_id
}
```

---

## What You Need to Know

To use wildcards, you need:
1. ✅ **Image name** - The name part of the ARN (e.g., `winserver2022`)
2. ✅ **Account ID** - The Image Builder account (e.g., `422228628991`)
3. ✅ **Region** - The region where images are built

**You DON'T need:**
- ❌ Version number
- ❌ Build number
- ❌ To query for latest first

---

## Finding the Image Name

The image name typically comes from:
1. **Image Recipe name** - If you know the recipe
2. **Pipeline name** - Sometimes matches
3. **Image Builder Console** - Check existing images
4. **From AMI tags** - If `Ec2ImageBuilderArn` tag exists (but yours don't yet)

---

## Your Use Case Solution

Since your AMIs don't have tags yet, you have a few options:

### Option 1: Use AMI Name Pattern (What You're Doing Now)
```hcl
data "aws_ami" "selected_ami" {
  most_recent = true
  owners      = ["422228628991"]

  filter {
    name   = "name"
    values = ["amidistribution-*"]
  }

  filter {
    name   = "platform-details"
    values = ["Windows"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
```

### Option 2: Use Image Builder with Wildcard (If You Know Image Name)
```hcl
# If you know the Image Builder image name is "winserver2022"
data "aws_imagebuilder_image" "latest" {
  arn = "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/x.x.x"
}

locals {
  latest_ami_id = data.aws_imagebuilder_image.latest.output_resources[0].amis[0].image
}
```

### Option 3: Find Image Name from Pipeline
```hcl
# Get pipeline to find image name pattern
data "aws_imagebuilder_image_pipeline" "pipeline" {
  arn = "arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/winserver2022"
}

# Extract image recipe name or construct image name
# Then use wildcard...
```

---

## Summary

**You're not missing anything!** The solution is:

✅ **Use `x.x.x` wildcard in the ARN** - This tells Image Builder to give you the latest version automatically!

The standard AWS provider documentation confirms this:
> "ARN of the image. Can use wildcards (`x.x.x`) for latest or full version"

So your ARN should be:
```
arn:aws:imagebuilder:REGION:ACCOUNT:image/IMAGE_NAME/x.x.x
```

Not:
```
arn:aws:imagebuilder:REGION:ACCOUNT:image/IMAGE_NAME/1.0.3/3  # ❌ Need to know version
```

---

## Finding Your Image Name

To use the wildcard approach, you need to know the image name. Check:

1. **Image Builder Console** - Look at existing images
2. **Pipeline configuration** - Image name often matches recipe or pipeline name
3. **Your code** - You might already know it (e.g., `winserver2022` from your locals)

Once you have the image name, the wildcard approach is the cleanest solution!


