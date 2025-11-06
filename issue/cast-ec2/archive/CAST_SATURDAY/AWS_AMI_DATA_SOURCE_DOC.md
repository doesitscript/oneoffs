# `data "aws_ami"` - Complete Documentation

From Terraform AWS Provider Documentation (via Terraform MCP Server)

---

## Overview

**Purpose:** Get detailed information about a **single** Amazon Machine Image (AMI) matching specified criteria.

**Returns:** Full AMI object with 50+ attributes (id, arn, name, tags, architecture, etc.)

**Critical Behavior:**
- ⚠️ **Fails if 0 matches** - No AMI found
- ⚠️ **Fails if 2+ matches** - Unless `most_recent = true` is set
- ✅ **Works if 1 match** - Returns that AMI
- ✅ **Works if 2+ matches with `most_recent = true`** - Returns the most recently created one

---

## Syntax

```hcl
data "aws_ami" "example" {
  # Arguments
  region             = "us-east-2"        # Optional
  owners             = ["422228628991"]   # Recommended
  most_recent        = true               # Recommended if multiple might match
  executable_users   = ["self"]           # Optional
  include_deprecated = false              # Optional
  allow_unsafe_filter = false             # Optional
  name_regex         = "^myami-[0-9]{3}"  # Optional

  # Filters (multiple filters = AND logic)
  filter {
    name   = "name"
    values = ["myami-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
```

---

## Arguments

### `region` (Optional)
- **Type:** `string`
- **Default:** Provider's configured region
- **Description:** Region where AMI search is performed
- **Example:** `"us-east-2"`

### `owners` (Optional but Recommended)
- **Type:** `list(string)`
- **Description:** List of AMI owners to limit search
- **Valid Values:**
  - AWS account ID: `"422228628991"`
  - `"self"` - Current account
  - AWS owner aliases: `"amazon"`, `"aws-marketplace"`, `"microsoft"`
- **Example:** `["422228628991"]` or `["self", "amazon"]`
- **Security Note:** Always specify to prevent using unauthorized AMIs

### `most_recent` (Optional)
- **Type:** `bool`
- **Default:** `false`
- **Description:** If multiple AMIs match, use the most recently created one
- **Recommendation:** Set to `true` if your filters might match multiple AMIs

### `filter` (Optional, Multiple Allowed)
- **Type:** Block
- **Description:** Filter criteria for AMI search
- **Logic:** Multiple filters use **AND** logic (all must match)
- **Multiple values:** Within one filter use **OR** logic (any can match)

**Common Filter Keys:**
- `name` - AMI name (supports wildcards: `"*WinServer2022*"`)
- `tag:<key>` - Custom tag (e.g., `tag:Name` matches tag key "Name")
- `tag-key` - Tag key exists (value ignored)
- `tag-value` - Tag value exists (across all tags)
- `state` - AMI state (`"available"`, `"pending"`, `"failed"`, `"deregistered"`)
- `platform-details` - OS platform (`"Windows"`, `"Linux/UNIX"`, etc.)
- `platform` - Legacy platform filter (`"windows"`, lowercase, no hyphen)
- `image-id` - Specific AMI ID
- `owner-id` - AWS account ID of owner
- `architecture` - CPU architecture (`"x86_64"`, `"arm64"`, `"i386"`)
- `virtualization-type` - Virtualization type (`"hvm"`, `"paravirtual"`)
- `root-device-type` - Root device type (`"ebs"`, `"instance-store"`)
- `ena-support` - Enhanced networking (`"true"`, `"false"`)

**Filter Examples:**
```hcl
# Filter by AMI name (with wildcard)
filter {
  name   = "name"
  values = ["*WinServer2022*"]
}

# Filter by custom tag
filter {
  name   = "tag:Name"
  values = ["GoldenAMI"]
}

# Filter by tag key existence
filter {
  name   = "tag-key"
  values = ["Ec2ImageBuilderArn"]
}

# Multiple values (OR logic)
filter {
  name   = "platform-details"
  values = ["Windows", "Linux/UNIX"]
}
```

### `name_regex` (Optional)
- **Type:** `string`
- **Description:** Regex pattern applied to AMI name **after** AWS API returns results
- **Performance:** Applied locally, can be slow on large result sets
- **Example:** `"^myami-[0-9]{3}"`
- **Note:** Prefer using `name` filter with wildcards instead

### `executable_users` (Optional)
- **Type:** `list(string)`
- **Description:** Limit search to AMIs with explicit launch permissions for these users
- **Valid Values:** AWS account ID or `"self"`

### `include_deprecated` (Optional)
- **Type:** `bool`
- **Default:** `false`
- **Description:** Include deprecated AMIs in search results

### `allow_unsafe_filter` (Optional)
- **Type:** `bool`
- **Default:** `false`
- **Description:** Allow unsafe filter values
- **Security Warning:** With `most_recent = true`, a third party could introduce a new AMI that matches and gets selected
- **Recommendation:** Use `owners` filter instead for security

---

## Returned Attributes

The data source returns a single AMI object with the following attributes:

### Core Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | `string` | AMI ID (e.g., `"ami-1234567890abcdef0"`) |
| `arn` | `string` | Full ARN of the AMI |
| `image_id` | `string` | Same as `id` |
| `name` | `string` | AMI name (from `image.name` in Image Builder) |
| `description` | `string` | AMI description |
| `state` | `string` | Current state (`"available"`, `"pending"`, etc.) |

### Identity Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `owner_id` | `string` | AWS account ID of AMI owner |
| `image_owner_alias` | `string` | Owner alias (`"amazon"`, `"self"`, or account ID) |
| `image_location` | `string` | Location of the AMI |
| `image_type` | `string` | Type of image |

### Platform Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `platform` | `string` | `"Windows"` for Windows AMIs, blank otherwise |
| `platform_details` | `string` | Platform details (e.g., `"Windows"`, `"Linux/UNIX"`) |
| `architecture` | `string` | CPU architecture (`"x86_64"`, `"arm64"`, `"i386"`) |
| `os_version` | `string` | OS version (e.g., `"Microsoft Windows Server 2022"`) |

### Technical Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `virtualization_type` | `string` | `"hvm"` or `"paravirtual"` |
| `hypervisor` | `string` | Hypervisor type (`"xen"`, `"nitro"`, `"kvm"`) |
| `boot_mode` | `string` | Boot mode of the image |
| `ena_support` | `bool` | Enhanced networking with ENA enabled |
| `sriov_net_support` | `string` | Enhanced networking support |
| `imds_support` | `string` | IMDS support mode (`"v2.0"` if IMDSv2 enforced) |
| `tpm_support` | `string` | NitroTPM support (`"v2.0"` if enabled) |

### Storage Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `root_device_name` | `string` | Root device name (e.g., `"/dev/sda1"`) |
| `root_device_type` | `string` | `"ebs"` or `"instance-store"` |
| `root_snapshot_id` | `string` | Snapshot ID for root device (EBS only) |
| `block_device_mappings` | `set(object)` | Block device mappings (see below) |

### Date/Time Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `creation_date` | `string` | Creation date/time (ISO 8601 format) |
| `deprecation_time` | `string` | Deprecation date/time |
| `last_launched_time` | `string` | Last launch time (ISO 8601, 24-hour delay) |

### Tag Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `tags` | `set(object)` | Set of tag objects with `key` and `value` properties |

**Tag Access Pattern:**
```hcl
# Convert tags to map
{ for tag in data.aws_ami.example.tags : tag.key => tag.value }

# Access specific tag
lookup({ for tag in data.aws_ami.example.tags : tag.key => tag.value }, "Name", "")
```

### Other Attributes

- `kernel_id` - Kernel ID (if any)
- `ramdisk_id` - RAM disk ID (if any)
- `product_codes` - Product codes
- `public` - `bool` - Public launch permissions
- `usage_operation` - Billing code operation
- `state_reason` - State change reason (object with `code` and `message`)
- `uefi_data` - UEFI variable store (base64)

---

## Filter Reference

Full filter options available at: [AWS CLI describe-images reference](http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html)

---

## Examples

### Example 1: Basic Usage
```hcl
data "aws_ami" "windows" {
  most_recent = true
  owners      = ["422228628991"]

  filter {
    name   = "name"
    values = ["*WinServer2022*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

output "ami_id" {
  value = data.aws_ami.windows.id
}
```

### Example 2: Filter by Tag
```hcl
data "aws_ami" "golden" {
  most_recent = true
  owners      = ["422228628991"]

  filter {
    name   = "tag:Name"
    values = ["GoldenAMI"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
```

### Example 3: Multiple Filters (AND Logic)
```hcl
data "aws_ami" "specific" {
  most_recent = true
  owners      = ["422228628991"]

  filter {
    name   = "name"
    values = ["*WinServer2022*"]
  }

  filter {
    name   = "tag:Name"
    values = ["GoldenAMI"]
  }

  filter {
    name   = "platform-details"
    values = ["Windows"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
```

### Example 4: Access Returned Attributes
```hcl
data "aws_ami" "example" {
  # ... filters ...
}

# Access attributes
output "ami_details" {
  value = {
    id            = data.aws_ami.example.id
    name          = data.aws_ami.example.name
    creation_date = data.aws_ami.example.creation_date
    tags          = { for tag in data.aws_ami.example.tags : tag.key => tag.value }
  }
}
```

---

## Important Notes

1. **Single Match Required:** Terraform fails if 0 or 2+ matches (unless `most_recent = true`)

2. **Filter Logic:**
   - Multiple filters = AND (all must match)
   - Multiple values in one filter = OR (any can match)
   - Case-sensitive (for tags and names)

3. **Region Scope:** Searches only in specified region (or provider default)

4. **Performance:** `name_regex` applied locally after AWS API call (can be slow)

5. **Security:** Always use `owners` filter to prevent unauthorized AMI usage

6. **Some Attributes Optional:** Not all attributes are always available - use `try()` for safe access

---

## Common Issues

### Issue: "No results found"
**Cause:** Filters too restrictive, AMI doesn't exist, or wrong region
**Solution:** Verify filters, check AWS Console, ensure correct region

### Issue: "Multiple results found"
**Cause:** Filters match multiple AMIs
**Solution:** Add `most_recent = true` or make filters more specific

### Issue: Circular Dependency
**Cause:** Referencing data source result in its own filter
**Solution:** Move variable definition after data source, or remove the circular reference

---

## Timeouts

- `read` - Default: `20m` (20 minutes)


