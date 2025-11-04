aws imagebuilder list-image-pipeline-images --image-pipeline-arn \"arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2022\" --region us-east-2 --profile SharedServices_imagemanagement_422228628991_admin --query 'imageSummaryList[?imageStatus==\`AVAILABLE\`].{ARN:arn,Version:version}' --output json"
  echo ""
  echo "Output:"
  aws imagebuilder list-image-pipeline-images \
    --image-pipeline-arn "arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2022" \
    --region us-east-2 \
    --profile SharedServices_imagemanagement_422228628991_admin \
    --query 'imageSummaryList[?imageStatus==`AVAILABLE`].{ARN:arn,Version:version}' \
    --output jsonaws imagebuilder list-image-pipeline-images --image-pipeline-arn \"arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2022\" --region us-east-2 --profile SharedServices_imagemanagement_422228628991_admin --query 'imageSummaryList[?imageStatus==\`AVAILABLE\`].{ARN:arn,Version:version}' --output json"
  echo ""
  echo "Output:"
  aws imagebuilder list-image-pipeline-images \
    --image-pipeline-arn "arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2022" \
    --region us-east-2 \
    --profile SharedServices_imagemanagement_422228628991_admin \
    --query 'imageSummaryList[?imageStatus==`AVAILABLE`].{ARN:arn,Version:version}' \
    --output json