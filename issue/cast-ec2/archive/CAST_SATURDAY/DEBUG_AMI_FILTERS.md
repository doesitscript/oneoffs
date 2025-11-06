# Debugging Empty AMI Filter Results

## Issue: Empty JSON Result

Your command returned empty, which means **no AMI matches ALL your filters** (filters use AND logic).

---

## Step 1: Check What AMIs Actually Exist

Start broad, then narrow down:

```bash
# 1. Check ALL AMIs owned by the account
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --query 'Images[*].[ImageId, Name, CreationDate]' \
  --output table

# 2. Check AMIs by name pattern only
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=name,Values=amidistribution-*" \
  --query 'Images[*].[ImageId, Name, CreationDate]' \
  --output table

# 3. Check AMIs by tag key only (not value)
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=tag-key,Values=Name" \
  --query 'Images[*].[ImageId, Name, Tags]' \
  --output json | jq '.'

# 4. Check ALL tags on AMIs
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=name,Values=amidistribution-*" \
  --query 'Images[*].[ImageId, Name, Tags]' \
  --output json | jq '.'
```

---

## Step 2: Verify Tag Exists

Check if the `Name` tag with value `GoldenAMI` actually exists:

```bash
# Check for tag value (across all tags)
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=tag-value,Values=GoldenAMI" \
  --query 'Images[*].[ImageId, Name, Tags]' \
  --output json | jq '.'

# Check specific tag key-value pair
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=tag:Name,Values=GoldenAMI" \
  --query 'Images[*].[ImageId, Name, Tags]' \
  --output json | jq '.'
```

---

## Step 3: Check Name Pattern

Verify the name pattern matches:

```bash
# List all AMI names
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --query 'Images[*].Name' \
  --output json | jq 'unique'

# Check for name pattern (case-sensitive!)
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=name,Values=amidistribution-*" \
  --query 'Images[*].[ImageId, Name]' \
  --output table

# Try different patterns
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=name,Values=*amidistribution*" \
  --query 'Images[*].[ImageId, Name]' \
  --output table
```

---

## Step 4: Combine Filters One by One

Test filters individually to see which one is causing the issue:

```bash
# Test 1: Owner + State only
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=state,Values=available" \
  --query 'length(Images)' \
  --output text
# If this returns 0, there are no available AMIs at all!

# Test 2: Owner + Name pattern
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=name,Values=amidistribution-*" "Name=state,Values=available" \
  --query 'Images[*].[ImageId, Name]' \
  --output table

# Test 3: Owner + Tag (no name filter)
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=tag:Name,Values=GoldenAMI" "Name=state,Values=available" \
  --query 'Images[*].[ImageId, Name, Tags]' \
  --output json | jq '.'
```

---

## Step 5: Check Region and Owner

Verify you're in the right region and account:

```bash
# Verify region
aws configure get region

# Verify profile/account
aws sts get-caller-identity

# List AMIs in different regions
for region in us-east-2 us-west-2 us-east-1; do
  echo "=== $region ==="
  aws ec2 describe-images \
    --owners 422228628991 \
    --region $region \
    --query 'length(Images)' \
    --output text
done
```

---

## Step 6: View All Tags on AMIs

See what tags actually exist:

```bash
# Get all tags from all AMIs
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=state,Values=available" \
  --query 'Images[*].{ImageId:ImageId,Name:Name,Tags:Tags}' \
  --output json | jq '[.[] | {ImageId, Name, Tags: [.Tags[]? | {Key, Value}]}]'

# Or simpler - just see unique tag keys
aws ec2 describe-images \
  --owners 422228991 \
  --region us-east-2 \
  --filters "Name=state,Values=available" \
  --query 'Images[*].Tags[*].Key' \
  --output json | jq 'flatten | unique'
```

---

## Common Issues

### Issue 1: Tag Doesn't Exist
**Symptom:** Filter `tag:Name=GoldenAMI` returns nothing

**Solution:**
- Check if tag is actually applied to AMIs
- Image Builder might not have applied the tag yet
- Tag might have different case (e.g., `goldenami` vs `GoldenAMI`)

### Issue 2: Name Pattern Doesn't Match
**Symptom:** Filter `name=amidistribution-*` returns nothing

**Solution:**
- AMI names might be different (e.g., `WinServer2022` instead of `amidistribution-*`)
- Pattern is case-sensitive
- Try `*amidistribution*` or check actual names

### Issue 3: Wrong Region
**Symptom:** No AMIs found but you know they exist

**Solution:**
- AMIs are region-specific
- Check if AMIs exist in the region you're querying
- Image Builder might distribute to multiple regions

### Issue 4: Tag Applied but Not Yet Visible
**Symptom:** Tag exists in Image Builder config but not on AMI

**Solution:**
- Tags from `amiDistributionConfiguration.amiTags` might take time to appear
- Check AMI in AWS Console directly
- Verify Image Builder actually ran and distributed

---

## Working Debug Command

Try this comprehensive check:

```bash
export AWS_PROFILE="CASTSoftware_dev_925774240130_admin"

# Full diagnostic
echo "=== All Available AMIs ==="
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=state,Values=available" \
  --query 'Images[*].[ImageId, Name, CreationDate]' \
  --output table | head -20

echo ""
echo "=== AMIs with Name tag ==="
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=tag-key,Values=Name" "Name=state,Values=available" \
  --query 'Images[*].[ImageId, Name, Tags]' \
  --output json | jq '[.[] | {ImageId, Name, NameTag: (.Tags[]? | select(.Key=="Name") | .Value)}]'

echo ""
echo "=== AMIs matching name pattern ==="
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=name,Values=amidistribution-*" "Name=state,Values=available" \
  --query 'Images[*].[ImageId, Name]' \
  --output table

echo ""
echo "=== AMIs with Ec2ImageBuilderArn tag ==="
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=tag-key,Values=Ec2ImageBuilderArn" "Name=state,Values=available" \
  --query 'Images[*].[ImageId, Name, Tags]' \
  --output json | jq '[.[] | {ImageId, Name, ImageBuilderArn: (.Tags[]? | select(.Key=="Ec2ImageBuilderArn") | .Value)}]'
```

---

## Simplified Test Command

If you want to start simple:

```bash
# Just get ANY available AMI from this account
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters "Name=state,Values=available" \
  --query 'sort_by(Images, &CreationDate)[-1].[ImageId, Name, Tags]' \
  --output json | jq '.'
```

This will show you the latest AMI and its tags, so you can see what's actually there.


