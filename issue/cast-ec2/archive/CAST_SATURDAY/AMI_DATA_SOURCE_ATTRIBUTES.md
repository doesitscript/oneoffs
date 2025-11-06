# AWS AMI Data Source Return Attributes

This document shows exactly what data types and attributes are returned by `aws_ami` and `aws_ami_ids` data sources based on official Terraform AWS Provider documentation.

---

## `data "aws_ami"` - Return Attributes

The `aws_ami` data source returns a **single AMI object** with comprehensive details.

### Access Pattern
```hcl
data.aws_ami.example.<attribute>
# or for for_each/count:
data.aws_ami.example[each.value].<attribute>
```

### Primitive Attributes (String/Boolean/Number)

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | `string` | ID of the AMI (e.g., `"ami-1234567890abcdef0"`) |
| `arn` | `string` | ARN of the AMI |
| `image_id` | `string` | ID of the AMI (same as `id`) |
| `name` | `string` | Name of the AMI that was provided during image creation |
| `description` | `string` | Description of the AMI |
| `image_location` | `string` | Location of the AMI |
| `image_owner_alias` | `string` | AWS account alias or account ID (e.g., `"amazon"`, `"self"`, `"422228628991"`) |
| `owner_id` | `string` | AWS account ID of the image owner |
| `platform` | `string` | Value is `"Windows"` for Windows AMIs; otherwise blank |
| `platform_details` | `string` | Platform details associated with the billing code of the AMI |
| `architecture` | `string` | OS architecture (e.g., `"i386"`, `"x86_64"`, `"arm64"`) |
| `boot_mode` | `string` | Boot mode of the image |
| `hypervisor` | `string` | Hypervisor type of the image (e.g., `"xen"`, `"nitro"`, `"kvm"`) |
| `virtualization_type` | `string` | Type of virtualization (`"hvm"` or `"paravirtual"`) |
| `root_device_name` | `string` | Device name of the root device (e.g., `"/dev/sda1"`) |
| `root_device_type` | `string` | Type of root device (`"ebs"` or `"instance-store"`) |
| `root_snapshot_id` | `string` | Snapshot ID associated with the root device (only for EBS root devices) |
| `kernel_id` | `string` | Kernel associated with the image (if any) |
| `ramdisk_id` | `string` | RAM disk associated with the image (if any) |
| `image_type` | `string` | Type of image |
| `sriov_net_support` | `string` | Whether enhanced networking is enabled |
| `tpm_support` | `string` | NitroTPM support (`"v2.0"` if enabled) |
| `imds_support` | `string` | Instance Metadata Service support mode (`"v2.0"` if IMDSv2 enforced) |
| `usage_operation` | `string` | Operation of the Amazon EC2 instance and billing code |
| `creation_date` | `string` | Date and time the image was created (ISO 8601 format) |
| `deprecation_time` | `string` | Date and time when the image will be deprecated |
| `last_launched_time` | `string` | Date and time when AMI was last used (ISO 8601, 24-hour delay) |
| `state` | `string` | Current state (`"available"`, `"pending"`, `"failed"`, `"deregistered"`) |
| `uefi_data` | `string` | Base64 representation of the non-volatile UEFI variable store |

### Boolean Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `public` | `bool` | `true` if the image has public launch permissions |
| `ena_support` | `bool` | Whether enhanced networking with ENA is enabled |

---

### Complex Attributes

#### `tags` - Map of Tags
**Type:** Set of objects with `key` and `value` properties

**Structure:**
```hcl
tags = [
  {
    key   = "Name"
    value = "GoldenAMI"
  },
  {
    key   = "Ec2ImageBuilderArn"
    value = "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/2"
  }
]
```

**Access Patterns:**
```hcl
# Access specific tag by key (common pattern)
lookup({ for tag in data.aws_ami.example.tags : tag.key => tag.value }, "Name", "")

# Iterate over all tags
for tag in data.aws_ami.example.tags : tag.key => tag.value

# Convert to map
{ for tag in data.aws_ami.example.tags : tag.key => tag.value }
```

**Attributes:**
- `tags.#.key` - Key name of the tag (string)
- `tags.#.value` - Value of the tag (string)

---

#### `block_device_mappings` - Block Device Mappings
**Type:** Set of objects

**Structure:**
```hcl
block_device_mappings = [
  {
    device_name = "/dev/sda1"
    ebs = {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      snapshot_id           = "snap-1234567890abcdef0"
      volume_size           = 250
      volume_type           = "gp3"
      throughput            = 125
      volume_initialization_rate = 1000
    }
    virtual_name = null
    no_device    = null
  }
]
```

**Access Pattern:**
```hcl
# Note: Unlike most object attributes, EBS is accessed directly as a map
data.aws_ami.example.block_device_mappings[0].ebs.volume_size
# NOT: data.aws_ami.example.block_device_mappings[0].ebs[0].volume_size
```

**Attributes:**
- `block_device_mappings.#.device_name` - Physical name of the device (string)
- `block_device_mappings.#.ebs` - Map containing EBS information (if EBS-based)
  - `ebs.delete_on_termination` - `bool` - `true` if EBS volume deleted on termination
  - `ebs.encrypted` - `bool` - `true` if EBS volume is encrypted
  - `ebs.iops` - `number` - IOPS count (0 if not provisioned IOPS)
  - `ebs.snapshot_id` - `string` - ID of the snapshot
  - `ebs.volume_size` - `number` - Size of the volume in GiB
  - `ebs.volume_type` - `string` - Volume type (e.g., `"gp3"`, `"gp2"`, `"io1"`, `"io2"`)
  - `ebs.throughput` - `number` - Throughput in MiB/s
  - `ebs.volume_initialization_rate` - `number` - Volume initialization rate in MiB/s
- `block_device_mappings.#.no_device` - `string` - Suppresses specified device
- `block_device_mappings.#.virtual_name` - `string` - Virtual device name (for instance stores)

---

#### `product_codes` - Product Codes
**Type:** List of objects

**Structure:**
```hcl
product_codes = [
  {
    product_code_id   = "prod-code-123"
    product_code_type = "marketplace"
  }
]
```

**Attributes:**
- `product_codes.#.product_code_id` - The product code (string)
- `product_codes.#.product_code_type` - The type of product code (string)

---

#### `state_reason` - State Reason
**Type:** Object (may be unset)

**Structure:**
```hcl
state_reason = {
  code    = "Client.UserInitiatedShutdown"
  message = "Client.UserInitiatedShutdown: User initiated shutdown"
}
```

**Attributes:**
- `state_reason.code` - `string` - The reason code for the state change
- `state_reason.message` - `string` - The message for the state change

**Note:** Fields may be `UNSET` if not available

---

### Example Usage in Terraform

```hcl
data "aws_ami" "example" {
  most_recent = true
  owners      = ["422228628991"]
  
  filter {
    name   = "tag:Name"
    values = ["GoldenAMI"]
  }
}

# Access attributes
output "ami_id" {
  value = data.aws_ami.example.id
}

output "ami_name" {
  value = data.aws_ami.example.name
}

output "ami_tags" {
  value = { for tag in data.aws_ami.example.tags : tag.key => tag.value }
}

output "root_volume_size" {
  value = data.aws_ami.example.block_device_mappings[0].ebs.volume_size
}

output "creation_date" {
  value = data.aws_ami.example.creation_date
}
```

---

## `data "aws_ami_ids"` - Return Attributes

The `aws_ami_ids` data source returns **only a list of AMI ID strings** - no other details.

### Access Pattern
```hcl
data.aws_ami_ids.example.ids
```

### Returned Attribute

| Attribute | Type | Description |
|-----------|------|-------------|
| `ids` | `list(string)` | List of AMI IDs, sorted by creation time (newest first by default, unless `sort_ascending = true`) |

### Structure
```hcl
ids = [
  "ami-1234567890abcdef0",
  "ami-0987654321fedcba0",
  "ami-abcdef1234567890"
]
```

### Example Usage in Terraform

```hcl
data "aws_ami_ids" "example" {
  owners = ["422228628991"]
  
  filter {
    name   = "tag-key"
    values = ["Ec2ImageBuilderArn"]
  }
}

# Access the list of IDs
output "ami_id_list" {
  value = data.aws_ami_ids.example.ids
}

# Get first AMI ID
output "first_ami_id" {
  value = data.aws_ami_ids.example.ids[0]
}

# Count of AMIs
output "ami_count" {
  value = length(data.aws_ami_ids.example.ids)
}

# Use with for_each to get details
data "aws_ami" "details" {
  for_each = toset(data.aws_ami_ids.example.ids)
  
  filter {
    name   = "image-id"
    values = [each.value]
  }
  owners = ["422228628991"]
}
```

---

## Comparison: What Each Returns

| Feature | `aws_ami` | `aws_ami_ids` |
|---------|-----------|---------------|
| **Returns** | Single AMI object with full details | List of AMI ID strings only |
| **Data Type** | Object with 50+ attributes | `list(string)` |
| **Use Case** | Need AMI details (tags, architecture, etc.) | Quick list of IDs, then lookup details later |
| **Performance** | Slower (full API response) | Faster (IDs only) |
| **Multiple Results** | Fails if 0 or 2+ (unless `most_recent = true`) | Returns all matching IDs |
| **Common Pattern** | Direct lookup or with `count` | Used with `for_each` to get details |

---

## Important Notes

⚠️ **Not All Attributes Always Available:**
> "Some values are not always set and may not be available for interpolation."
> 
> Use `try()` or check for null values when accessing optional attributes.

**Example:**
```hcl
# Safe access pattern
root_snapshot = try(data.aws_ami.example.root_snapshot_id, null)

# Safe tag access
name_tag = try(
  lookup({ for tag in data.aws_ami.example.tags : tag.key => tag.value }, "Name", ""),
  ""
)
```

---

## Your Code Patterns

### Pattern 1: Direct AMI Lookup
```hcl
data "aws_ami" "selected_ami" {
  # ... filters ...
}

# Returns: Single AMI object
# Access: data.aws_ami.selected_ami.id
```

### Pattern 2: List IDs, Then Get Details
```hcl
data "aws_ami_ids" "windows_2022_all" {
  # ... filters ...
}

# Returns: ["ami-123", "ami-456", ...]

data "aws_ami" "windows_2022_candidates" {
  for_each = toset(data.aws_ami_ids.windows_2022_all.ids)
  # ... lookup each ID ...
}

# Returns: { "ami-123" => {...}, "ami-456" => {...} }
# Access: data.aws_ami.windows_2022_candidates["ami-123"].tags
```

### Pattern 3: Conditional Lookup
```hcl
data "aws_ami" "windows_2022_latest" {
  count = local.highest_version_build_ami_id != null ? 1 : 0
  # ... filters ...
}

# Returns: Single AMI if count = 1, nothing if count = 0
# Access: data.aws_ami.windows_2022_latest[0].id (if exists)
```



