# AWS AMI Filter Reference Guide

## Understanding aws_ami Filters for Terraform

Based on AWS EC2 `describe-images` API and Terraform `aws_ami` data source documentation, here's a comprehensive guide to filter keys and how to match your identified resources.

## Your Identified Value: `GoldenAMI`

**Tag Location in Image Builder:**
- Path: `image.distributionConfiguration.distributions[0].amiDistributionConfiguration.amiTags.Name`
- Value: `"GoldenAMI"`
- This becomes the AMI tag: `Name = "GoldenAMI"` when the AMI is created

---

## Filter Key Categories

### 1. TAG-BASED FILTERS (Your Primary Use Case)

#### `tag:<tag-key>` - Filter by specific tag key-value pair
**Use Case:** Match AMIs where a specific tag key has a specific value

```hcl
# Your current working filter:
filter {
  name   = "tag:Name"
  values = ["GoldenAMI"]  # Matches Name = "GoldenAMI"
}

# Examples from your codebase:
filter {
  name   = "tag:Ec2ImageBuilderArn"
  values = ["arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2022/1.0.3/2"]
}
```

**How it works:**
- Format: `tag:<tag-key>`
- Values: Array of tag values to match (case-sensitive)
- Matches: AMIs where `<tag-key>` equals any value in the array

---

#### `tag-key` - Filter by tag key existence
**Use Case:** Find AMIs that have a specific tag key (regardless of value)

```hcl
# Example from your codebase (line 68):
filter {
  name   = "tag-key"
  values = ["Ec2ImageBuilderArn"]  # Finds AMIs that HAVE this tag key
}
```

**How it works:**
- Values: Array of tag key names
- Matches: AMIs that have ANY of these tag keys (value doesn't matter)

---

#### `tag-value` - Filter by tag value across all tags
**Use Case:** Find AMIs where ANY tag has a specific value

```hcl
filter {
  name   = "tag-value"
  values = ["GoldenAMI"]  # Finds AMIs where ANY tag = "GoldenAMI"
}
```

**Note:** Less precise than `tag:Name` - use `tag:Name` instead when you know the key.

---

### 2. AMI IDENTIFICATION FILTERS

#### `image-id` - Filter by specific AMI IDs
**Use Case:** Lookup specific AMIs by their ID

```hcl
# Example from your codebase (line 87):
filter {
  name   = "image-id"
  values = ["ami-1234567890abcdef0"]
}
```

---

#### `name` - Filter by AMI name pattern
**Use Case:** Match AMIs by name using wildcards

```hcl
# Example from your codebase (line 53):
filter {
  name   = "name"
  values = ["*winserver2022*"]  # Wildcard matching
}
```

**Wildcard support:** Yes (`*` for any characters)

---

### 3. STATE & AVAILABILITY FILTERS

#### `state` - Filter by AMI state
**Use Case:** Only get available/pending AMIs

```hcl
# Example from your codebase (line 58, 73, 172):
filter {
  name   = "state"
  values = ["available"]  # Other values: "pending", "failed", "deregistered"
}
```

**Common values:**
- `"available"` - Ready to use
- `"pending"` - Being created
- `"failed"` - Creation failed
- `"deregistered"` - No longer available

---

### 4. PLATFORM & ARCHITECTURE FILTERS

#### `platform-details` - Filter by OS platform
**Use Case:** Match Windows vs Linux AMIs

```hcl
# Example from your codebase (line 79):
filter {
  name   = "platform-details"
  values = ["Windows"]  # Other: "Linux/UNIX", "Red Hat BYOL Linux", etc.
}
```

---

#### `platform` - Filter by platform (legacy)
```hcl
filter {
  name   = "platform"
  values = ["windows"]  # lowercase, no hyphen
}
```

---

#### `architecture` - Filter by CPU architecture
```hcl
filter {
  name   = "architecture"
  values = ["x86_64"]  # Other: "arm64", "i386"
}
```

---

#### `virtualization-type` - Filter by virtualization type
```hcl
filter {
  name   = "virtualization-type"
  values = ["hvm"]  # Other: "paravirtual"
}
```

---

### 5. OWNERSHIP FILTERS

#### `owner-id` - Filter by AWS account ID
**Use Case:** Match AMIs owned by specific accounts

```hcl
filter {
  name   = "owner-id"
  values = ["422228628991"]  # Your Image Builder account
}
```

**Note:** You're already using the `owners` argument (line 45), which is more efficient than this filter.

---

#### `owner-alias` - Filter by AWS owner alias
```hcl
filter {
  name   = "owner-alias"
  values = ["amazon", "aws-marketplace", "microsoft"]
}
```

---

### 6. STORAGE FILTERS

#### `root-device-type` - Filter by root device type
```hcl
filter {
  name   = "root-device-type"
  values = ["ebs"]  # Other: "instance-store"
}
```

---

#### `block-device-mapping.device-name` - Filter by block device mapping
```hcl
filter {
  name   = "block-device-mapping.device-name"
  values = ["/dev/sda1"]
}
```

---

#### `block-device-mapping.volume-type` - Filter by EBS volume type
```hcl
filter {
  name   = "block-device-mapping.volume-type"
  values = ["gp3", "gp2"]
}
```

---

### 7. IMAGE METADATA FILTERS

#### `description` - Filter by AMI description
```hcl
filter {
  name   = "description"
  values = ["*Windows Server 2022*"]  # Wildcard supported
}
```

---

#### `hypervisor` - Filter by hypervisor type
```hcl
filter {
  name   = "hypervisor"
  values = ["xen"]  # Other: "nitro", "kvm"
}
```

---

#### `ena-support` - Filter by ENA support
```hcl
filter {
  name   = "ena-support"
  values = ["true"]
}
```

---

#### `sriov-net-support` - Filter by SR-IOV support
```hcl
filter {
  name   = "sriov-net-support"
  values = ["simple"]
}
```

---

## Complete Filter Combination Example

Based on your identified resources, here's how to combine filters effectively:

```hcl
data "aws_ami" "selected_ami" {
  most_recent = true
  owners      = ["422228628991"]  # Image Builder account

  # Your identified tag value
  filter {
    name   = "tag:Name"
    values = ["GoldenAMI"]  # From amiDistributionConfiguration.amiTags.Name
  }

  # Platform filter
  filter {
    name   = "name"
    values = ["*winserver2022*"]  # Platform in AMI name
  }

  # State filter
  filter {
    name   = "state"
    values = ["available"]
  }

  # Optional: Additional platform filter
  filter {
    name   = "platform-details"
    values = ["Windows"]
  }

  # Optional: Architecture filter
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
```

---

## Filter Matching Logic

1. **AND Logic:** Multiple filters are combined with AND - ALL must match
2. **OR Logic within values:** Multiple values in the same filter use OR - any can match
3. **Wildcards:** Supported in `name`, `description`, and tag value filters
4. **Case Sensitivity:** Tag values are case-sensitive; platform filters may vary

---

## Your Specific Use Case: GoldenAMI Tag Matching

**What you know:**
- Tag exists at: `amiDistributionConfiguration.amiTags.Name = "GoldenAMI"`
- This tag is applied directly to the AMI resource by Image Builder

**Correct filter:**
```hcl
filter {
  name   = "tag:Name"           # Key: Name
  values = ["GoldenAMI"]        # Value: GoldenAMI (case-sensitive)
}
```

**Why this works:**
- Image Builder's `amiTags` are applied as regular EC2 AMI tags
- The `tag:<key>` filter syntax matches tag key-value pairs
- Your filter correctly matches: `Name = "GoldenAMI"`

---

## Filter Value Types Reference

| Filter Type | Value Format | Wildcards? | Case Sensitive? |
|------------|--------------|------------|-----------------|
| `tag:<key>` | String value | Yes (`*`) | Yes |
| `tag-key` | Tag key name | No | Yes |
| `tag-value` | Tag value | Yes (`*`) | Yes |
| `name` | AMI name | Yes (`*`) | Yes |
| `state` | Enum: "available", "pending", etc. | No | No |
| `platform-details` | Enum: "Windows", "Linux/UNIX" | No | Yes |
| `image-id` | AMI ID: "ami-xxxxx" | No | No |
| `owner-id` | AWS Account ID | No | No |

---

## Best Practices for Your Scenario

1. **Always filter by `owners`** - Limits scope and improves security (already doing this ✅)
2. **Combine `tag:Name` with `state`** - Ensures AMI is usable (already doing this ✅)
3. **Use `most_recent = true`** - Gets latest version (already doing this ✅)
4. **Add platform filters** - Reduces false matches (already doing this ✅)
5. **Consider using `tag-key` first** - If you need to find AMIs with a tag regardless of value

---

## Quick Reference: Your Current Filters

```hcl
# Primary AMI selector (lines 41-61)
filter {
  name   = "tag:Name"           # ✅ Correct for GoldenAMI
  values = ["GoldenAMI"]        # ✅ Your identified value
}

filter {
  name   = "name"               # AMI name pattern
  values = ["*winserver2022*"]  # Platform match
}

filter {
  name   = "state"              # Only available AMIs
  values = ["available"]
}
```

Your current configuration is correct and follows AWS/Terraform best practices! ✅


