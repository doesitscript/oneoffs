# Terraform Data Source to Find Latest AMI from Image Builder WinServer2022
# Based on: imagebuilder.json output showing Image Builder configuration
#
# Image Builder Details:
# - Image Builder Image Name: "WinServer2022"
# - AMI Tags Applied: "Name": "GoldenAMI"
# - Owner Account: 422228628991
# - Regions: us-east-2, us-west-2

# For us-east-2 region
data "aws_ami" "winserver2022_latest" {
  most_recent = true
  owners      = ["422228628991"]
  region      = "us-east-2" # Required since Image Builder distributes to multiple regions

  # Filter by the tag applied during Image Builder distribution
  # The amiTags from Image Builder become actual EC2 AMI tags
  filter {
    name   = "tag:Name"
    values = ["GoldenAMI"]
  }

  # Optional: Filter by AMI name pattern (Image Builder creates names like: amidistribution-TIMESTAMP)
  # The actual AMI name from your JSON: "amidistribution-2025-10-31T16-02-47.054Z"
  filter {
    name   = "name"
    values = ["amidistribution-*"] # Matches the Image Builder AMI name pattern
  }

  # Standard filter to ensure AMI is available
  filter {
    name   = "state"
    values = ["available"]
  }
}

# Alternative Minimal Version (just tag + owner, relies on most_recent)
data "aws_ami" "winserver2022_minimal" {
  most_recent = true
  owners      = ["422228628991"]
  region      = "us-east-2"

  filter {
    name   = "tag:Name"
    values = ["GoldenAMI"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Use the AMI in an instance:
resource "aws_instance" "example" {
  ami           = data.aws_ami.winserver2022_latest.id
  instance_type = "t3.medium"

  tags = {
    Name        = "cast-ec2-instance"
    SourceImage = data.aws_ami.winserver2022_latest.name
    ImageTag    = data.aws_ami.winserver2022_latest.tags["Name"]
  }
}

# Output to verify
output "ami_id" {
  value = data.aws_ami.winserver2022_latest.id
}

output "ami_name" {
  value = data.aws_ami.winserver2022_latest.name
}

output "ami_tags" {
  value = data.aws_ami.winserver2022_latest.tags
}

output "ami_creation_date" {
  value = data.aws_ami.winserver2022_latest.creation_date
}


