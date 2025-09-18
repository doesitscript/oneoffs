
# Optional: Data source to get current caller identity for verification
data "aws_caller_identity" "current" {}

# Optional: Output to verify the account and profile are working
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

# Example minimal resource - S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "cast-software-dev-example-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Example minimal resource - EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (us-east-1)
  instance_type = "t2.micro"

  tags = {
    Name = "cast-software-dev-example"
  }
}
