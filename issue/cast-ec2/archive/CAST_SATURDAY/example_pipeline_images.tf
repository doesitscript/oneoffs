# Example: Get Images from Image Builder Pipeline using external data source
# This uses the same API as: aws imagebuilder list-image-pipeline-images

data "aws_region" "current" {}

variable "pipeline_arn" {
  description = "ARN of the Image Builder pipeline"
  type        = string
  default     = "arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/winserver2022"
}

# Use external data source to call AWS CLI list-image-pipeline-images
data "external" "pipeline_images" {
  program = ["bash", "-c", <<-EOT
    set -e
    RESULT=$(aws imagebuilder list-image-pipeline-images \
      --image-pipeline-arn "${var.pipeline_arn}" \
      --region "${data.aws_region.current.name}" \
      --output json)
    
    # External data source requires single-line JSON output
    echo "$RESULT" | jq -c '.'
  EOT
  ]
}

# Parse the JSON response
locals {
  pipeline_images_raw = jsondecode(data.external.pipeline_images.result.imageSummaryList)

  # Extract useful information
  pipeline_images = [
    for img in local.pipeline_images_raw : {
      arn         = img.arn
      name        = img.name
      version     = img.version
      platform    = img.platform
      status      = img.state.status
      dateCreated = img.dateCreated
      owner       = img.owner
      # Extract AMI ID if available
      ami_id = try(img.outputResources.amis[0].image, null)
    }
  ]

  # Get latest image (first in list, typically sorted by date)
  latest_image_arn = try(local.pipeline_images[0].arn, null)
  latest_ami_id    = try(local.pipeline_images[0].ami_id, null)
}

# Optional: Get full details of latest image using Image Builder data source
data "aws_imagebuilder_image" "latest" {
  count = local.latest_image_arn != null ? 1 : 0
  arn   = local.latest_image_arn
}

# Outputs
output "pipeline_images" {
  description = "List of all images from the pipeline"
  value       = local.pipeline_images
}

output "latest_image_arn" {
  description = "ARN of the latest image"
  value       = local.latest_image_arn
}

output "latest_ami_id" {
  description = "AMI ID of the latest image"
  value       = local.latest_ami_id
}


