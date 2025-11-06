"Name": "amidistribution-2025-10-31T17-22-51.766Z",
"SourceInstanceId": "i-0b2148ea286dfd14d",
"SourceImageId": "ami-058cdf62ba6d6cd64",
"ImageId": "ami-051537eaae7545f75",
"ImageLocation": "422228628991/


AWS_PROFILE=SharedServices_imagemanagement_422228628991_admin
AWS_REGION=us-east-2
AMI=ami-051537eaae7545f75

aws ec2 describe-images \
  --image-ids "$AMI" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'Images[0].Tags'

[
    {
        "Key": "Name",
        "Value": "GoldenAMI"
    },
    {
        "Key": "CreatedBy",
        "Value": "EC2 Image Builder"
    },
    {
        "Key": "Ec2ImageBuilderArn",
        "Value": "arn:aws:imagebuilder:us-east-2:422228628991:image/winserver2025/1.0.3/17"
    }
]