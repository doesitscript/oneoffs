# initial
<!-- i-054443c7dc4253556 -->
MLLXLJJ2XVFJ:~ a805120$ export AWS_PROFILE=CASTSoftware_dev_925774240130_admin && aws ssm create-document   --name "Custom-SessionManagerRunShell"   --document-type "Session"   --content '{
    "schemaVersion": "1.0",
    "description": "Custom SSM Session",
    "sessionType": "Standard_Stream",
    "inputs": {
      "idleSessionTimeout": "60",
      "maxSessionDuration": "120"
    }
  }' 2>/dev/null || aws ssm update-document   --name "Custom-SessionManagerRunShell"   --document-version "\$LATEST"   --content '{
    "schemaVersion": "1.0",
    "description": "Custom SSM Session",
    "sessionType": "Standard_Stream",
    "inputs": {
      "idleSessionTimeout": "60",
      "maxSessionDuration": "120"
    }
  }' && aws ssm start-session --target i-0a04cb53a9e6a2348

###
export AWS_PROFILE=CASTSoftware_dev_925774240130_admin
aws ssm start-session \
  --target i-054443c7dc4253556 \
  --region us-east-2 \
  --document-name Custom-SessionManagerRunShell