# Terraform Data Sources Explained

This document explains each data source in `data.tf` using official Terraform AWS Provider documentation.

---

## 1. `data "aws_region" "current"` (Line 1)

**Purpose:** Gets the current AWS region where Terraform is running.

**Documentation Reference:** Standard Terraform AWS provider data source.

**Key Attributes:**
- `name` - The name of the region (e.g., `us-east-2`)
- `description` - Human-readable description of the region
- `endpoint` - The endpoint for the region

**Usage in your code:**
- Not directly used in this file, but commonly used for resource naming or region-specific configurations

**Example Output:**
```hcl
data.aws_region.current.name # Returns: "us-east-2"
```

---

## 2. `data "aws_vpc" "cast_vpc"` (Lines 5-10)

**Purpose:** Looks up an existing VPC by filtering on tags.

**Documentation Reference:** `aws_vpc` data source in Terraform AWS Provider.

**Your Configuration:**
```hcl
data "aws_vpc" "cast_vpc" {
  filter {
    name   = "tag:Name"
    values = ["cast*"]  # Wildcard matching
  }
}
```

**Key Arguments:**
- `filter` - One or more name/value pairs to filter VPCs
  - `tag:Name` - Filters by the Name tag with wildcard support

**Key Attributes Returned:**
- `id` - The ID of the VPC (used in line 15)
- `cidr_block` - The CIDR block of the VPC
- `tags` - Tags associated with the VPC
- `default` - Whether this is the default VPC

**Usage in your code:**
- `data.aws_vpc.cast_vpc.id` - Referenced in the `aws_subnets` data source (line 15)

**Important Notes:**
- **Requirement:** Terraform will fail if no VPC matches OR if multiple VPCs match
- Your wildcard `cast*` will match any VPC with a Name tag starting with "cast"
- Consider being more specific if you have multiple CAST VPCs

---

## 3. `data "aws_subnets" "cast_subnets"` (Lines 12-17)

**Purpose:** Gets a list of subnet IDs within a specific VPC.

**Documentation Reference:** `aws_subnets` data source in Terraform AWS Provider.

**Your Configuration:**
```hcl
data "aws_subnets" "cast_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.cast_vpc.id]  # References the VPC from above
  }
}
```

**Key Arguments:**
- `filter` - Filters subnets by various criteria
  - `vpc-id` - Filters subnets by VPC ID

**Key Attributes Returned:**
- `ids` - **List of subnet IDs** (used in line 21)
  - This is an array: `["subnet-123", "subnet-456", ...]`

**Usage in your code:**
- `data.aws_subnets.cast_subnets.ids[0]` - Gets the first subnet ID (line 21)
  - Stored in `local.cast_subnet_id`

**Important Notes:**
- Returns **ALL** subnets in the VPC (no additional filtering)
- You're taking the first one with `[0]` (see TODO comment on line 20)
- Consider adding filters for:
  - `tag:Name` - To get a specific subnet
  - `availability-zone` - To get subnets in a specific AZ
  - `state` - To exclude subnets being deleted

---

## 4. `data "aws_ami" "selected_ami"` (Lines 41-61)

**Purpose:** Gets detailed information about a **single** AMI matching the criteria.

**Documentation Reference:** `aws_ami` data source (Provider Doc ID: 10271218)

**Key Characteristics:**
- **Returns:** A single AMI object (fails if 0 or 2+ matches)
- **Use `most_recent = true`** to automatically select the latest when multiple match
- **Returns full AMI details:** tags, architecture, creation date, etc.

**Your Configuration:**
```hcl
data "aws_ami" "selected_ami" {
  most_recent = true                    # ✅ Select latest if multiple match
  
  owners = [local.owner]                # Account: 422228628991
  
  filter {
    name   = "tag:Name"
    values = [local.ami_tag_name]       # "GoldenAMI"
  }
  
  filter {
    name   = "name"
    values = ["*winserver2022*"]        # AMI name pattern
  }
  
  filter {
    name   = "state"
    values = ["available"]              # Only available AMIs
  }
}
```

**Key Arguments:**
- `most_recent` - If multiple AMIs match, use the most recently created one
- `owners` - **Required** - Limits search to specific AWS account(s)
- `filter` - Multiple filters combined with AND logic

**Key Attributes Returned:**
- `id` - The AMI ID (used in line 37: `local.ami_id_latest`)
- `arn` - The ARN of the AMI
- `name` - The name of the AMI
- `tags` - Map of tags (can access like `data.aws_ami.selected_ami.tags["Name"]`)
- `creation_date` - When the AMI was created
- `architecture` - CPU architecture (x86_64, arm64, etc.)
- `platform` - "Windows" or blank
- `state` - Current state
- **Many more attributes available**

**Usage in your code:**
- `data.aws_ami.selected_ami.id` → `local.ami_id_latest` (line 37)
- Used in `main.tf` line 69: `ami = var.ami_id != null ? var.ami_id : local.ami_id_latest`

**Important Notes:**
- ⚠️ **Will fail if no AMI matches** your filters
- ⚠️ **Will fail if multiple match** UNLESS `most_recent = true` is set (which you have ✅)
- Filters are combined with AND - all must match
- `owners` is recommended for security - prevents using unauthorized AMIs

**Filter Logic:**
1. Find AMIs owned by account `422228628991`
2. That have tag `Name = "GoldenAMI"`
3. With name containing `winserver2022`
4. That are in `available` state
5. Return the most recent one

---

## 5. `data "aws_ami_ids" "windows_2022_all"` (Lines 64-82)

**Purpose:** Gets a **list of AMI IDs** (not full AMI details) matching the criteria.

**Documentation Reference:** `aws_ami_ids` data source (Provider Doc ID: 10271219)

**Key Characteristics:**
- **Returns:** A list of AMI IDs (string array)
- **Does NOT return** full AMI details (no tags, no creation_date, etc.)
- **Useful for:** Getting multiple AMI IDs, then looking up details later
- **Does NOT fail** if multiple match (that's the point!)

**Your Configuration:**
```hcl
data "aws_ami_ids" "windows_2022_all" {
  owners = [local.owner]                # Account: 422228628991
  
  filter {
    name   = "tag-key"
    values = ["Ec2ImageBuilderArn"]     # AMIs that HAVE this tag key
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

**Key Arguments:**
- `owners` - **REQUIRED** - At least 1 value must be specified
- `filter` - Same filter options as `aws_ami`
- `sort_ascending` - Optional - Sort by creation time (default: false = descending)

**Key Attributes Returned:**
- `ids` - **List of AMI ID strings** (used in line 85)
  - Example: `["ami-123456", "ami-789012", "ami-345678"]`
  - Sorted by creation time (newest first by default)

**Usage in your code:**
- `data.aws_ami_ids.windows_2022_all.ids` - Used in `for_each` (line 85)
- Provides the list of AMI IDs to iterate over

**Filter Logic:**
1. Find AMIs owned by account `422228628991`
2. That have the tag key `Ec2ImageBuilderArn` (value doesn't matter)
3. That are Windows platform
4. That are in `available` state
5. Return all matching AMI IDs as a list

**Important Notes:**
- ⚠️ Returns **all matching AMIs** - could be many!
- Returns only IDs - no other details
- Used as a "first pass" to get candidates, then detailed lookups happen next

---

## 6. `data "aws_ami" "windows_2022_candidates"` (Lines 84-91)

**Purpose:** Gets detailed information about **multiple** AMIs using `for_each`.

**Documentation Reference:** `aws_ami` data source (same as #4) but used with `for_each`

**Key Characteristics:**
- Uses `for_each` to create **one data source per AMI ID**
- Each instance returns full AMI details
- Results are accessed as a map: `data.aws_ami.windows_2022_candidates[ami_id]`

**Your Configuration:**
```hcl
data "aws_ami" "windows_2022_candidates" {
  for_each = toset(data.aws_ami_ids.windows_2022_all.ids)  # Iterate over AMI IDs
  
  filter {
    name   = "image-id"
    values = [each.value]  # Lookup each specific AMI ID
  }
  
  owners = [local.owner]
}
```

**How `for_each` Works:**
- `toset(...)` - Converts the list to a set (unique values)
- `for_each` - Creates one `aws_ami` data source for each AMI ID
- `each.value` - The current AMI ID in the iteration
- Results accessible as: `data.aws_ami.windows_2022_candidates["ami-123456"]`

**Key Attributes (same as `aws_ami`):**
- Each AMI can be accessed: `data.aws_ami.windows_2022_candidates[ami_id]`
- Full details available: `.tags`, `.creation_date`, `.arn`, etc.

**Usage in your code:**
- Used in `local.ami_tag_values` (line 95) to extract tags from each AMI
- Iterates over all candidates to extract `Ec2ImageBuilderArn` tag values
- Used to filter and sort AMIs by version/build number

**Example Access Pattern:**
```hcl
# In your locals block (line 95-106):
for ami_id, ami_data in data.aws_ami.windows_2022_candidates : ami_id => {
  image_builder_arn = lookup(ami_data.tags, "Ec2ImageBuilderArn", "")
}
```

**Important Notes:**
- Creates **multiple data source lookups** - one per AMI
- Can be expensive if you have many AMIs
- Each lookup returns full AMI details (unlike `aws_ami_ids`)

---

## 7. `data "aws_ami" "windows_2022_latest"` (Lines 164-175)

**Purpose:** Gets the AMI with the highest version/build number (determined by complex logic).

**Documentation Reference:** `aws_ami` data source (same as #4) but used with `count`

**Key Characteristics:**
- Uses `count = 1` conditionally (only if `highest_version_build_ami_id != null`)
- Returns the AMI matching a specific Image Builder ARN
- This is the "final answer" - the latest versioned AMI

**Your Configuration:**
```hcl
data "aws_ami" "windows_2022_latest" {
  count = local.highest_version_build_ami_id != null ? 1 : 0  # Conditional creation
  
  filter {
    name   = "tag:Ec2ImageBuilderArn"
    values = [local.highest_version_build_arn]  # Specific ARN from complex logic
  }
  
  filter {
    name   = "state"
    values = ["available"]
  }
  
  owners = [local.owner]
}
```

**How the Logic Works:**
1. `data.aws_ami_ids.windows_2022_all` - Gets all Windows 2022 AMI IDs
2. `data.aws_ami.windows_2022_candidates` - Gets full details for each
3. `local.ami_tag_values` - Extracts Image Builder ARNs from tags
4. `local.ami_version_build_strings` - Parses version/build from ARNs
5. `local.ami_with_version_build` - Converts versions to numbers
6. `local.ami_sort_key` - Creates sortable version strings
7. `local.highest_version_build_arn` - Finds the highest version ARN
8. `local.highest_version_build_ami_id` - Extracts the AMI ID
9. **This data source** - Looks up the final AMI by ARN

**Key Arguments:**
- `count` - Conditional: only creates if AMI ID was found
- `filter` with `tag:Ec2ImageBuilderArn` - Filters by exact Image Builder ARN

**Key Attributes:**
- Access with `count`: `data.aws_ami.windows_2022_latest[0].id` (if count = 1)
- Returns full AMI details for the highest version

**Usage in your code:**
- Not directly used in visible code, but available as:
  - `data.aws_ami.windows_2022_latest[0].id` (if it exists)

**Important Notes:**
- ⚠️ May not exist if `highest_version_build_ami_id` is `null`
- Uses `count` instead of `for_each` (single resource, conditional)
- This represents the "best" AMI after version sorting logic

---

## Summary: Data Source Comparison

| Data Source | Returns | Multiple Results? | Use Case |
|------------|---------|-------------------|----------|
| `aws_ami` | Full AMI object | No (fails if 0 or 2+) | Get single AMI with all details |
| `aws_ami_ids` | List of AMI IDs only | Yes | Get list of AMI IDs quickly |
| `aws_ami` + `for_each` | Map of AMI objects | Yes | Get details for multiple AMIs |
| `aws_ami` + `count` | Single AMI object | Conditional | Conditional AMI lookup |

---

## Your Data Flow

```
1. aws_ami_ids.windows_2022_all
   ↓ (returns: ["ami-123", "ami-456", "ami-789"])
   
2. aws_ami.windows_2022_candidates (for_each)
   ↓ (returns: { "ami-123" => {...}, "ami-456" => {...} })
   
3. Complex local logic (sorting by version/build)
   ↓ (determines: highest_version_build_arn)
   
4. aws_ami.windows_2022_latest (count)
   ↓ (returns: Single AMI with highest version)
```

**Alternative Simple Path:**
```
aws_ami.selected_ami
↓ (returns: Single AMI matching "GoldenAMI" tag)
```

---

## Best Practices Observed

✅ **Security:**
- Always specify `owners` to limit search scope
- Prevents using unauthorized AMIs

✅ **Reliability:**
- Use `state = "available"` filter to avoid failed/pending AMIs
- Use `most_recent = true` when appropriate

✅ **Performance:**
- `aws_ami_ids` for quick ID lists
- Detailed lookups only when needed

✅ **Conditional Resources:**
- Using `count` for conditional AMI lookup
- Prevents errors when no AMI matches

---

## Recommendations

1. **Consider adding filters to `aws_subnets`:**
   ```hcl
   filter {
     name   = "tag:Name"
     values = ["cast-*-subnet-*"]
   }
   ```

2. **Add error handling for VPC lookup:**
   - If multiple VPCs match `cast*`, Terraform will fail
   - Consider more specific tag matching

3. **Monitor `aws_ami_ids` result size:**
   - If you have many AMIs, `for_each` can be slow
   - Consider additional filters to reduce candidate count



