# AWSCC (Cloud Control API) Image Builder Data Sources

Yes! I have access to AWSCC resources through the Terraform MCP server. Here's what's available for Image Builder:

---

## Available AWSCC Image Builder Data Sources

| Data Source | Purpose | Key Difference from AWS Provider |
|------------|---------|----------------------------------|
| `awscc_imagebuilder_image` | Get image details | **Returns `image_id` (AMI ID) directly!** ✅ |
| `awscc_imagebuilder_image_pipelines` | List all pipelines | Returns set of pipeline IDs only |
| `awscc_imagebuilder_image_pipeline` | Get pipeline details | Single pipeline lookup |
| `awscc_imagebuilder_image_recipes` | List recipes | Plural data source |
| `awscc_imagebuilder_image_recipe` | Get recipe details | Single recipe lookup |
| `awscc_imagebuilder_distribution_configurations` | List dist configs | Plural data source |
| `awscc_imagebuilder_distribution_configuration` | Get dist config details | Single config lookup |

---

## Key Feature: `awscc_imagebuilder_image` Returns AMI ID Directly!

The AWSCC provider's `awscc_imagebuilder_image` data source has a significant advantage:

**Returns `image_id` attribute** - This is the AMI ID directly! No need to navigate through `output_resources`.

### Comparison:

**Standard AWS Provider:**
```hcl
data "aws_imagebuilder_image" "example" {
  arn = "arn:aws:imagebuilder:..."
}

# Get AMI ID (complex path)
ami_id = data.aws_imagebuilder_image.example.output_resources[0].amis[0].image
```

**AWSCC Provider:**
```hcl
data "awscc_imagebuilder_image" "example" {
  id = "arn:aws:imagebuilder:..."  # Uses 'id' instead of 'arn'
}

# Get AMI ID (simple!)
ami_id = data.awscc_imagebuilder_image.example.image_id  # ← Direct!
```

---

## `awscc_imagebuilder_image` Data Source

### Syntax

```hcl
data "awscc_imagebuilder_image" "example" {
  id = "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/3"
}
```

### Key Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | `string` | Input: ARN of the image |
| `arn` | `string` | ARN of the image |
| **`image_id`** | `string` | **AMI ID directly!** ✅ |
| `name` | `string` | Image name |
| `version` | `string` | Image version |
| `platform` | `string` | Platform (Windows/Linux) |
| `tags` | `map(string)` | Tags on the image |
| `image_recipe_arn` | `string` | Recipe ARN |
| `distribution_configuration_arn` | `string` | Distribution config ARN |
| `image_uri` | `string` | Container image URI (if applicable) |
| `latest_version` | `object` | Latest version references |
| `output_resources` | Not present | AWSCC doesn't expose this (but has `image_id` instead) |

---

## Complete Example: Using AWSCC to Get AMI ID

```hcl
# Using AWSCC provider - much simpler!
data "awscc_imagebuilder_image" "latest" {
  id = "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/x.x.x"
}

# Get AMI ID directly - no complex nested paths!
locals {
  ami_id = data.awscc_imagebuilder_image.latest.image_id
}

# Use in EC2 instance
resource "aws_instance" "example" {
  ami = data.awscc_imagebuilder_image.latest.image_id  # ← Simple!
  # ...
}
```

---

## AWSCC vs Standard AWS Provider

### When to Use AWSCC:

✅ **Use AWSCC when:**
- You have Image Builder ARNs
- You want direct AMI ID access (`image_id` attribute)
- You want simpler attribute paths
- You're working with Cloud Control API resources

❌ **Use Standard AWS Provider when:**
- You need to filter AMIs (AWSCC doesn't have filters)
- You need `output_resources` structure
- You're already using standard provider

---

## Note: No List Pipeline Images in AWSCC

Unfortunately, AWSCC also doesn't have a direct equivalent to `list-image-pipeline-images`. However, you can:

1. Use `awscc_imagebuilder_image_pipelines` to list pipeline IDs
2. Then query each pipeline or use external data source for `list-image-pipeline-images`

---

## Summary

**Yes, AWSCC provider has Image Builder data sources!**

**Key Benefit:** `awscc_imagebuilder_image` provides `image_id` directly, making it easier to get the AMI ID from an Image Builder image ARN.

**Limitation:** Still no direct equivalent to `list-image-pipeline-images` in either provider.


