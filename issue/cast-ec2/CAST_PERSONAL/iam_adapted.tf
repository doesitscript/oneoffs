# IAM Role for CAST EC2 instance
resource "aws_iam_role" "cast_role" {
  name = "${var.project_name}-${var.environment}-role-${data.aws_region.current.name}"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-role"
  })
}

# IAM Policy Attachments
resource "aws_iam_role_policy_attachment" "ssm_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.cast_role.name
}

# CloudWatch Logs Policy
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "${var.project_name}-${var.environment}-cloudwatch-policy-${data.aws_region.current.name}"
  description = "Policy for CloudWatch Logs access for ${var.project_name} instance"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = "arn:aws:logs:*:*:log-group:/aws/${var.project_name}/*"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-cloudwatch-policy"
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
  role       = aws_iam_role.cast_role.name
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "cast_profile" {
  name = "${var.project_name}-${var.environment}-profile-${data.aws_region.current.name}"
  role = aws_iam_role.cast_role.name

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-profile"
  })
}

