aws secretsmanager describe-secret \
  --secret-id arn:aws:secretsmanager:us-east-2:422228628991:secret:BreadDomainSecret-CORPDEV \
  --query KmsKeyId --output text