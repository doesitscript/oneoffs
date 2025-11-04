
# Selector for MPV2 refactor to dynamic filters for OSYYYY and Platform (winserver2025, linux, etc.)
data "aws_ami" "selected_ami" {

  most_recent = true

  owners = [local.owner]

  # Filter by custom tag (if Image Builder applies it)
  filter {
    name   = "tag:Name"
    values = [local.amiTag_Name] # "GoldenAMI"
  }

  # Filter by AMI intrinsic name (from image.name in Image Builder)
  # Using wildcard for flexibility - matches "WinServer2022" or "WinServer2022-something"
  filter {
    name   = "name"
    values = ["*${local.platform}*"] # "*WinServer2022*" - case-sensitive but wildcard helps
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
