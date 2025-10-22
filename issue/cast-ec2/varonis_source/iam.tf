# IAM Role
resource "aws_iam_role" "varonis_role" {
  name = "${local.name_prefix}-role-Production-${data.aws_region.current.name}"
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

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-role"
  })
}

# IAM Policy Attachments
resource "aws_iam_role_policy_attachment" "ssm_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.varonis_role.name
}

# CloudWatch Logs Policy
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "${local.name_prefix}-cloudwatch-policy-Production-${data.aws_region.current.name}"
  description = "Policy for CloudWatch Logs access for ${local.name_prefix} instance"

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
        Resource = "arn:aws:logs:*:*:log-group:/aws/${local.name_prefix}/*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-cloudwatch-policy"
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
  role       = aws_iam_role.varonis_role.name
}

# Cross-account secrets access policy
resource "aws_iam_policy" "secrets_access_policy" {
  name        = "${local.name_prefix}-secrets-policy-Production-${data.aws_region.current.name}"
  description = "Policy for cross-account secrets access to customer-image-mgmt"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "arn:aws:secretsmanager:*:422228628991:secret:BreadDomainSecret-CORP*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-secrets-policy"
  })
}

resource "aws_iam_role_policy_attachment" "secrets_access" {
  policy_arn = aws_iam_policy.secrets_access_policy.arn
  role       = aws_iam_role.varonis_role.name
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "varonis_profile" {
  name = "${local.name_prefix}-profile-Production-${data.aws_region.current.name}"
  role = aws_iam_role.varonis_role.name

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-profile"
  })
}
