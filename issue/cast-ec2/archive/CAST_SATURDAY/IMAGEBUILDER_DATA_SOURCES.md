# AWS Image Builder Data Sources Documentation

Complete documentation for Image Builder data sources from Terraform AWS Provider (via Terraform MCP Server)

---

## 1. `data "aws_imagebuilder_image"` - Image Details

**Purpose:** Get details about an Image Builder Image (the built AMI).

### Syntax

```hcl
data "aws_imagebuilder_image" "example" {
  arn    = "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/3"
  region = "us-east-2"  # Optional
}
```

### Arguments

| Argument | Type | Required | Description |
|----------|------|----------|-------------|
| `arn` | `string` | ✅ Yes | ARN of the image. Can use wildcards (`x.x.x`) for latest or full version (`2020.11.26/1`) |
| `region` | `string` | No | Region (defaults to provider region) |

### ARN Format

**With Wildcard (Latest Version):**
```
arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/x.x.x
```

**Specific Version:**
```
arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/3
```

### Returned Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `build_version_arn` | `string` | Full build version ARN (always has `#.#.#/#` suffix) |
| `container_recipe_arn` | `string` | ARN of container recipe (if used) |
| `date_created` | `string` | Date the image was created |
| `distribution_configuration_arn` | `string` | ARN of distribution configuration |
| `enhanced_image_metadata_enabled` | `bool` | Whether enhanced metadata is collected |
| `image_recipe_arn` | `string` | ARN of the image recipe |
| `image_scanning_configuration` | `list(object)` | Image scanning configuration |
| `image_tests_configuration` | `list(object)` | Image tests configuration |
| `infrastructure_configuration_arn` | `string` | ARN of infrastructure configuration |
| `name` | `string` | Name of the image |
| `platform` | `string` | Platform (e.g., `"Windows"`, `"Linux"`) |
| `os_version` | `string` | OS version (e.g., `"Microsoft Windows Server 2022"`) |
| `output_resources` | `list(object)` | Resources created by the image |
| `tags` | `map(string)` | Tags applied to the image |
| `version` | `string` | Version of the image |

### `output_resources` Structure

**Most Important for Your Use Case:**
```hcl
output_resources = [{
  amis = [
    {
      account_id  = "422228628991"
      description = "AMI description"
      image       = "ami-1234567890abcdef0"  # ← The AMI ID!
      name        = "WinServer2022"          # ← AMI name
      region      = "us-east-2"
    }
  ]
  containers = []  # If container image
}]
```

### Example Usage

```hcl
# Get latest version
data "aws_imagebuilder_image" "latest" {
  arn = "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/x.x.x"
}

# Get specific version
data "aws_imagebuilder_image" "specific" {
  arn = "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/3"
}

# Extract AMI ID from output
output "ami_id" {
  value = data.aws_imagebuilder_image.latest.output_resources[0].amis[0].image
}
```

---

## 2. `data "aws_imagebuilder_image_recipe"` - Recipe Details

**Purpose:** Get details about an Image Builder Image Recipe.

### Syntax

```hcl
data "aws_imagebuilder_image_recipe" "example" {
  arn = "arn:aws:imagebuilder:us-east-2:422228628991:image-recipe/winserver2022/1.0.0"
}
```

### Arguments

| Argument | Type | Required | Description |
|----------|------|----------|-------------|
| `arn` | `string` | ✅ Yes | ARN of the image recipe |
| `region` | `string` | No | Region (defaults to provider region) |

### Returned Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `ami_tags` | `map(string)` | **Tags applied to AMI during build** (before distribution) |
| `block_device_mapping` | `set(object)` | Block device mappings |
| `component` | `list(object)` | Components in the recipe |
| `date_created` | `string` | Creation date |
| `description` | `string` | Description |
| `name` | `string` | Name of recipe |
| `owner` | `string` | Owner account ID |
| `parent_image` | `string` | Base/parent image |
| `platform` | `string` | Platform |
| `tags` | `map(string)` | Recipe tags |
| `user_data_base64` | `string` | Base64 encoded user data |
| `version` | `string` | Recipe version |
| `working_directory` | `string` | Working directory for build |

### Example Usage

```hcl
data "aws_imagebuilder_image_recipe" "recipe" {
  arn = "arn:aws:imagebuilder:us-east-2:422228628991:image-recipe/winserver2022/1.0.0"
}

# Access AMI tags that will be applied
output "recipe_ami_tags" {
  value = data.aws_imagebuilder_image_recipe.recipe.ami_tags
}
```

---

## 3. `data "aws_imagebuilder_distribution_configuration"` - Distribution Config

**Purpose:** Get details about Distribution Configuration (where AMIs are distributed and how they're tagged).

### Syntax

```hcl
data "aws_imagebuilder_distribution_configuration" "example" {
  arn = "arn:aws:imagebuilder:us-east-2:422228628991:distribution-configuration/example"
}
```

### Arguments

| Argument | Type | Required | Description |
|----------|------|----------|-------------|
| `arn` | `string` | ✅ Yes | ARN of distribution configuration |
| `region` | `string` | No | Region (defaults to provider region) |

### Returned Attributes

**Most Important:**
| Attribute | Type | Description |
|-----------|------|-------------|
| `distribution` | `set(object)` | Distribution settings |
| `name` | `string` | Name of distribution config |
| `description` | `string` | Description |
| `date_created` | `string` | Creation date |
| `date_updated` | `string` | Last update date |
| `tags` | `map(string)` | Tags |

### `distribution` Structure

```hcl
distribution = [
  {
    region = "us-east-2"
    
    ami_distribution_configuration = [{
      ami_tags = {
        "Name"             = "GoldenAMI"  # ← Your tag!
        "Ec2ImageBuilderArn" = "arn:aws:imagebuilder:..."
      }
      description    = "AMI description"
      kms_key_id     = "arn:aws:kms:..."
      target_account_ids = ["422228628991"]
      launch_permission = [...]
    }]
    
    container_distribution_configuration = []
    fast_launch_configuration = []
    launch_template_configuration = []
  }
]
```

### Example Usage

```hcl
data "aws_imagebuilder_distribution_configuration" "dist" {
  arn = "arn:aws:imagebuilder:us-east-2:422228628991:distribution-configuration/example"
}

# Access AMI tags from distribution configuration
output "distribution_ami_tags" {
  value = data.aws_imagebuilder_distribution_configuration.dist.distribution[0].ami_distribution_configuration[0].ami_tags
}
```

---

## 4. `data "aws_imagebuilder_image_pipeline"` - Pipeline Details

**Purpose:** Get details about an Image Builder Pipeline (automated builds).

### Syntax

```hcl
data "aws_imagebuilder_image_pipeline" "example" {
  arn = "arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/example"
}
```

### Arguments

| Argument | Type | Required | Description |
|----------|------|----------|-------------|
| `arn` | `string` | ✅ Yes | ARN of the image pipeline |
| `region` | `string` | No | Region (defaults to provider region) |

### Returned Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `container_recipe_arn` | `string` | Container recipe ARN |
| `date_created` | `string` | Creation date |
| `date_last_run` | `string` | Last pipeline run date |
| `date_next_run` | `string` | Next scheduled run |
| `date_updated` | `string` | Last update date |
| `description` | `string` | Description |
| `distribution_configuration_arn` | `string` | Distribution config ARN |
| `enhanced_image_metadata_enabled` | `bool` | Enhanced metadata enabled |
| `image_recipe_arn` | `string` | Image recipe ARN |
| `image_tests_configuration` | `list(object)` | Image tests config |
| `infrastructure_configuration_arn` | `string` | Infrastructure config ARN |
| `name` | `string` | Pipeline name |
| `platform` | `string` | Platform |
| `schedule` | `list(object)` | Schedule settings |
| `status` | `string` | Pipeline status |
| `tags` | `map(string)` | Tags |

### Example Usage

```hcl
data "aws_imagebuilder_image_pipeline" "pipeline" {
  arn = "arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/winserver2022-pipeline"
}

# Get related ARNs
output "recipe_arn" {
  value = data.aws_imagebuilder_image_pipeline.pipeline.image_recipe_arn
}

output "distribution_arn" {
  value = data.aws_imagebuilder_image_pipeline.pipeline.distribution_configuration_arn
}
```

---

## How to Use for Your Use Case

Based on your code, you're extracting Image Builder ARNs from AMI tags like:
```hcl
tag:Ec2ImageBuilderArn = "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/3"
```

### Option 1: Query Image Builder Directly (Instead of AMI Tags)

```hcl
# Get Image Builder image details directly
data "aws_imagebuilder_image" "latest" {
  # Use wildcard for latest version
  arn = "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/x.x.x"
}

# Extract AMI ID from Image Builder output
locals {
  ami_id_from_imagebuilder = data.aws_imagebuilder_image.latest.output_resources[0].amis[0].image
}
```

### Option 2: Get Distribution Config to See Tags

```hcl
data "aws_imagebuilder_distribution_configuration" "dist" {
  arn = var.distribution_config_arn  # You'd need this ARN
}

# See what tags are configured
output "configured_tags" {
  value = data.aws_imagebuilder_distribution_configuration.dist.distribution[0].ami_distribution_configuration[0].ami_tags
}
```

### Option 3: Use Image Builder Image to Get AMI Details

```hcl
# If you have the Image Builder ARN from AMI tag
locals {
  image_builder_arn = "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/3"
}

data "aws_imagebuilder_image" "from_tag" {
  arn = local.image_builder_arn
}

# Get the AMI ID directly
output "ami_id" {
  value = data.aws_imagebuilder_image.from_tag.output_resources[0].amis[0].image
}
```

---

## Complete List of Available Image Builder Data Sources

| Data Source | Purpose | Key Use Case |
|------------|---------|--------------|
| `aws_imagebuilder_image` | Get image details | Extract AMI ID from Image Builder image |
| `aws_imagebuilder_image_recipe` | Get recipe details | See recipe configuration |
| `aws_imagebuilder_distribution_configuration` | Get distribution config | See AMI tags configuration |
| `aws_imagebuilder_image_pipeline` | Get pipeline details | See automated build schedule |
| `aws_imagebuilder_infrastructure_configuration` | Get infrastructure config | See build infrastructure |
| `aws_imagebuilder_component` | Get component details | See build components |
| `aws_imagebuilder_*_recipes` (plural) | List recipes | Find available recipes |
| `aws_imagebuilder_*_pipelines` (plural) | List pipelines | Find available pipelines |

---

## ARN Patterns

### Image ARN
```
arn:aws:imagebuilder:REGION:ACCOUNT:image/NAME/VERSION/BUILD
arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/3
```

### Image Recipe ARN
```
arn:aws:imagebuilder:REGION:ACCOUNT:image-recipe/NAME/VERSION
arn:aws:imagebuilder:us-east-2:422228628991:image-recipe/winserver2022/1.0.0
```

### Distribution Configuration ARN
```
arn:aws:imagebuilder:REGION:ACCOUNT:distribution-configuration/NAME
arn:aws:imagebuilder:us-east-2:422228628991:distribution-configuration/example
```

### Image Pipeline ARN
```
arn:aws:imagebuilder:REGION:ACCOUNT:image-pipeline/NAME
arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/winserver2022-pipeline
```

---

## Important Notes

1. **Wildcards Supported:** Image ARN can use `x.x.x` to get latest version
2. **Region Specific:** Each resource must be queried in its region
3. **AMI ID Extraction:** Use `output_resources[0].amis[0].image` to get AMI ID
4. **Tag Sources:** Tags can come from:
   - Recipe (`ami_tags` in recipe) - Applied during build
   - Distribution Config (`ami_tags` in distribution) - Applied during distribution
5. **Version Format:** `VERSION/BUILD` (e.g., `1.0.3/3`)


