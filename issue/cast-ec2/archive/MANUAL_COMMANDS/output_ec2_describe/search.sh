export AWS_PROFILE="CASTSoftware_dev_925774240130_admin"

# NOTE: Removing tag filter because AMIs don't have tags applied yet
# The name pattern filter should be sufficient to match Image Builder AMIs
aws ec2 describe-images \
  --owners 422228628991 \
  --region us-east-2 \
  --filters \
    "Name=name,Values=amidistribution-*" \
    "Name=state,Values=available" \
  --query 'sort_by(Images, &CreationDate)[-1]' \
  --output json > describe_images.json
aws ec2 describe-images \
  --owners "422228628991" \
  --region "us-east-2" \
  --filters "Name=platform,Values=windows" \
  --query 'Images[*]' | \
  jq '[.[] | select(.Tags[]? | select(.Key=="Ec2ImageBuilderArn" and (.Value | contains("winserver2022"))))] | sort_by(.CreationDate) | reverse | .[0]'