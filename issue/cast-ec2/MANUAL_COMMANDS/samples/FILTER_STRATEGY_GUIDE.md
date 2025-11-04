# AMI Filter Strategy Guide

## Understanding the Difference: `name` vs `tag:Name`

### Two Different Fields:

1. **`name` filter** = AMI's **intrinsic name property**
   - This is what you see in AWS Console as the AMI name
   - From Image Builder: `image.name = "WinServer2022"`
   - Case-sensitive, exact match (unless using wildcards)

2. **`tag:Name` filter** = Custom **tag** with key "Name"
   - This is a tag applied to the AMI
   - From Image Builder: `amiDistributionConfiguration.amiTags.Name = "GoldenAMI"`
   - Different from the intrinsic name!

### Your Current Problem:

Looking at your console output:
- **AMI intrinsic name**: `"WinServer2022"` ✅
- **AMI tag Name**: `"GoldenAMI"` (if applied by Image Builder)

Your filters require **ALL** to match:
```hcl
filter {
  name   = "tag:Name"
  values = ["GoldenAMI"]  # Must have this tag
}

filter {
  name   = "name"
  values = ["WinServer2022"]  # AND must have this exact name
}
```

**Problem:** If the AMI doesn't have BOTH, it won't match!

---

## Solution Options:

### Option 1: Filter by Intrinsic Name Only (Most Reliable)

If you know the AMI name pattern, use this:

```hcl
data "aws_ami" "selected_ami" {
  most_recent = true
  owners      = [local.owner]  # "422228628991"

  filter {
    name   = "name"
    values = ["*WinServer2022*"]  # Wildcard for flexibility
  }

  filter {
    name   = "state"
    values = ["available"]
  }
  
  # Optional: Add platform filter for safety
  filter {
    name   = "platform-details"
    values = ["Windows"]
  }
}
```

**Pros:**
- Uses the AMI's intrinsic name (always present)
- More reliable - doesn't depend on tags being applied
- Wildcards make it flexible

**Cons:**
- Less specific if multiple AMIs match the name pattern

---

### Option 2: Filter by Tag Only (If Tag is Always Applied)

```hcl
data "aws_ami" "selected_ami" {
  most_recent = true
  owners      = [local.owner]

  filter {
    name   = "tag:Name"
    values = ["GoldenAMI"]  # Image Builder tag
  }

  filter {
    name   = "state"
    values = ["available"]
  }
  
  # Optional: Add name filter as backup
  filter {
    name   = "name"
    values = ["*WinServer2022*"]
  }
}
```

**Pros:**
- More specific if "GoldenAMI" tag is unique
- Tags can be more meaningful than names

**Cons:**
- Will fail if Image Builder doesn't apply the tag
- Tags might not be applied during testing

---

### Option 3: Use OR Logic (Filter by Either)

Since you can't do OR between filters, use multiple filters with the same criteria:

```hcl
data "aws_ami" "selected_ami" {
  most_recent = true
  owners      = [local.owner]

  # Match by tag if available
  filter {
    name   = "tag:Name"
    values = ["GoldenAMI"]
  }

  # OR match by name pattern
  filter {
    name   = "name"
    values = ["*WinServer2022*", "*winserver2022*"]  # Case variations
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
```

**Note:** This still requires ALL filters to match (AND logic). Each filter can have multiple values (OR within that filter).

---

## Recommended Fix for Your Code:

### Fix the Circular Dependency First!

**Remove line 37 reference to `data.aws_ami.selected_ami.id`** (it references itself!)

```hcl
locals {
  platform = "WinServer2022"
  amiTag_Name = "GoldenAMI"
  owner = "422228628991"
  
  # DON'T reference the data source here - it causes circular dependency!
  # ami_id_latest = data.aws_ami.selected_ami.id  # ← Remove this!
}

data "aws_ami" "selected_ami" {
  most_recent = true
  owners      = [local.owner]

  # Option A: Use wildcard name filter (recommended)
  filter {
    name   = "name"
    values = ["*${local.platform}*"]  # "*WinServer2022*"
  }

  filter {
    name   = "state"
    values = ["available"]
  }
  
  # Optional: Add tag filter if you know it exists
  # filter {
  #   name   = "tag:Name"
  #   values = [local.amiTag_Name]  # "GoldenAMI"
  # }
}

# THEN reference it after definition
locals {
  ami_id_latest = data.aws_ami.selected_ami.id  # ← Move here or use directly
}
```

---

## Debugging Steps:

### 1. Check What AMIs Actually Exist

Run AWS CLI to see what's available:
```bash
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=state,Values=available" \
  --query 'Images[*].[ImageId,Name,Tags]' \
  --output table
```

### 2. Check for Tag vs Name

```bash
# Check for tag
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=tag:Name,Values=GoldenAMI" \
  --query 'Images[*].[ImageId,Name]'

# Check for name pattern
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=name,Values=*WinServer2022*" \
  --query 'Images[*].[ImageId,Name,Tags]'
```

### 3. Use More Permissive Filters First

Start with just the name filter, then add tag filter if needed:

```hcl
data "aws_ami" "selected_ami" {
  most_recent = true
  owners      = [local.owner]

  # Start simple
  filter {
    name   = "name"
    values = ["*WinServer2022*"]  # Wildcard - more flexible
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
```

Then check if it works. If yes, add the tag filter back.

---

## Why Your Current Code Fails:

1. **Circular dependency**: `local.ami_id_latest` references `data.aws_ami.selected_ami.id` on line 37, but then line 53 uses `local.ami_id_latest` in the filter
2. **Too many required matches**: Both `tag:Name = "GoldenAMI"` AND `name = "WinServer2022"` must match
3. **Exact match on name**: You're using `name = "WinServer2022"` (exact), but might need wildcard `"*WinServer2022*"`

---

## Quick Fix (Start Here):

```hcl
data "aws_ami" "selected_ami" {
  most_recent = true
  owners      = [local.owner]

  # Use wildcard for name (more flexible)
  filter {
    name   = "name"
    values = ["*${local.platform}*"]  # "*WinServer2022*"
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  # Comment out tag filter temporarily to test
  # filter {
  #   name   = "tag:Name"
  #   values = [local.amiTag_Name]
  # }
  
  # REMOVE THIS - circular dependency!
  # filter {
  #   name   = "tag:Ec2ImageBuilderArn"
  #   values = [local.ami_id_latest]  # ← This is wrong!
  # }
}
```

