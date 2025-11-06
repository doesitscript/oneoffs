aws ec2 describe-images --image-ids ami-051537eaae7545f75 > newest-q_Images.json

aws ec2 describe-images --image-ids ami-051537eaae7545f75 --region us-east-2 --query 'Images[0]' --output json > newest-q_Images.json
aws ec2 describe-images --image-ids ami-051537eaae7545f75 --region us-east-2 --query 'Images[0]'

aws ec2 describe-images --image-ids ami-051537eaae7545f75 --region us-east-2 > newest_q_Images.json


422228628991/amidistribution-2025-10-31T17-22-51.766Z