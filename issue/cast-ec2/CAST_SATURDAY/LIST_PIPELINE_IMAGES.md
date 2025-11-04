# Listing Images from Image Builder Pipeline in Terraform

## The Problem

AWS CLI has this command:
```bash
aws imagebuilder list-image-pipeline-images \
  --image-pipeline-arn arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/winserver2022
```

**Terraform AWS Provider does NOT have a direct data source equivalent** for `list-image-pipeline-images`.

## Available Options

### Option 1: Use `external` Data Source (Same API as CLI) ✅

Use Terraform's `external` data source to call the AWS CLI command directly:

```hcl
data "external" "pipeline_images" {
  program = ["bash", "-c", <<-EOT
    aws imagebuilder list-image-pipeline-images \
      --image-pipeline-arn "${var.pipeline_arn}" \
      --region "${data.aws_region.current.name}" \
      --query 'imageSummaryList[*].[arn, name, version, platform, state.status]' \
      --output json | jq '[.[] | {arn: .[0], name: .[1], version: .[2], platform: .[3], status: .[4]}]' | jq -c '{images: .}'
  EOT
  ]
}

# Parse the JSON response
locals {
  pipeline_images = jsondecode(data.external.pipeline_images.result.images)
}
```

**Pros:**
- Uses the exact same API as `list-image-pipeline-images`
- Gets all images from the pipeline
- Returns structured data

**Cons:**
- Requires AWS CLI and `jq` installed
- Less portable (depends on external tools)
- JSON parsing needed

---

### Option 2: Filter AMIs by Tag (Your Current Approach) ✅

This is what you're already doing in your code:

```hcl
data "aws_ami_ids" "windows_2022_all" {
  owners = [local.owner]

  filter {
    name   = "tag-key"
    values = ["Ec2ImageBuilderArn"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "platform-details"
    values = ["Windows"]
  }
}
```

**Pros:**
- Pure Terraform (no external dependencies)
- Works well for finding AMIs
- Your current approach

**Cons:**
- Requires AMIs to be tagged with `Ec2ImageBuilderArn`
- May not match the exact API results
- Only finds AMIs, not all pipeline images

---

### Option 3: Use `aws_imagebuilder_image_pipeline` + Parse ARNs

If you know the pipeline ARN pattern, you could construct image ARNs:

```hcl
data "aws_imagebuilder_image_pipeline" "pipeline" {
  arn = var.pipeline_arn
}

# Extract pipeline name from ARN
locals {
  pipeline_name = split("/", split(":", data.aws_imagebuilder_image_pipeline.pipeline.arn)[5])[1]
}

# Use external data source to list images
data "external" "pipeline_images" {
  program = ["bash", "-c", <<-EOT
    aws imagebuilder list-image-pipeline-images \
      --image-pipeline-arn "${data.aws_imagebuilder_image_pipeline.pipeline.arn}" \
      --region "${data.aws_region.current.name}" \
      --output json | jq -c '{images: .imageSummaryList}'
  EOT
  ]
}
```

---

### Option 4: Use `null_resource` with `local-exec`

```hcl
resource "null_resource" "get_pipeline_images" {
  triggers = {
    pipeline_arn = var.pipeline_arn
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws imagebuilder list-image-pipeline-images \
        --image-pipeline-arn "${var.pipeline_arn}" \
        --region "${data.aws_region.current.name}" \
        --output json > /tmp/pipeline_images.json
    EOT
  }
}

data "external" "pipeline_images" {
  program = ["cat", "/tmp/pipeline_images.json"]
  depends_on = [null_resource.get_pipeline_images]
}
```

---

## Complete Example: Using `external` Data Source

Here's a complete working example:

```hcl
# Get current region
data "aws_region" "current" {}

# Variables
variable "pipeline_arn" {
  type = string
  default = "arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/winserver2022"
}

# Call AWS CLI to list pipeline images
data "external" "pipeline_images" {
  program = ["bash", "-c", <<-EOT
    set -e
    
    # Get pipeline images
    RESULT=$(aws imagebuilder list-image-pipeline-images \
      --image-pipeline-arn "${var.pipeline_arn}" \
      --region "${data.aws_region.current.name}" \
      --output json)
    
    # Output as single-line JSON for external data source
    echo "$RESULT" | jq -c '{images: .imageSummaryList}'
  EOT
  ]
}

# Parse the images
locals {
  pipeline_images_list = jsondecode(data.external.pipeline_images.result.images)
  
  # Extract image ARNs
  image_arns = [
    for img in local.pipeline_images_list : img.arn
  ]
  
  # Get latest image (assuming sorted by date)
  latest_image_arn = try(local.image_arns[0], null)
}

# Use the latest image
data "aws_imagebuilder_image" "latest" {
  count = local.latest_image_arn != null ? 1 : 0
  arn   = local.latest_image_arn
}

# Get AMI ID from the latest image
locals {
  latest_ami_id = try(
    data.aws_imagebuilder_image.latest[0].output_resources[0].amis[0].image,
    null
  )
}
```

---

## JSON Output Structure

The `list-image-pipeline-images` API returns:

```json
{
  "requestId": "...",
  "imageSummaryList": [
    {
      "arn": "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/3",
      "name": "WinServer2022",
      "type": "AMI",
      "version": "1.0.3/3",
      "platform": "Windows",
      "osVersion": "Microsoft Windows Server 2022",
      "state": {
        "status": "AVAILABLE"
      },
      "owner": "422228628991",
      "dateCreated": "2024-01-15T10:30:00.000Z",
      "outputResources": {
        "amis": [
          {
            "region": "us-east-2",
            "image": "ami-1234567890abcdef0",
            "name": "WinServer2022",
            "description": "..."
          }
        ]
      }
    }
  ]
}
```

---

## Recommendation

For your use case, I recommend:

1. **Use `external` data source** if you need the exact same results as `list-image-pipeline-images`
2. **Continue using your current AMI filtering approach** if you just need to find AMIs (which is working)

Your current code already effectively finds AMIs from Image Builder pipelines using the tag filtering approach, which is a valid workaround.

---

## Comparison

| Method | Uses Same API? | Pure Terraform? | Requires External Tools? |
|--------|---------------|-----------------|-------------------------|
| `external` data source | ✅ Yes | ❌ No | ✅ Yes (AWS CLI, jq) |
| Filter AMIs by tag | ❌ No | ✅ Yes | ❌ No |
| `null_resource` + local-exec | ✅ Yes | ❌ No | ✅ Yes (AWS CLI) |


