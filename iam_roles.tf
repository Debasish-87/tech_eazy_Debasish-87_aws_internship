##########################
# IAM Trust Policy: EC2 can Assume Role
##########################
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

##########################
# IAM Policy Document: S3 Write Access (Dev-only)
##########################
data "aws_iam_policy_document" "s3_write_policy" {
  statement {
    sid    = "WriteAccessToLogs"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "arn:aws:s3:::${var.logs_bucket_name}/logs/${local.environment}/*",
      "arn:aws:s3:::${var.logs_bucket_name}/status/${local.environment}/*"
    ]
  }
}

##########################
# Create IAM Role (Only for Dev)
##########################
resource "aws_iam_role" "s3_write_role" {
  count              = local.is_dev ? 1 : 0
  name               = "${var.project_name}-s3-write-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name        = "${local.environment}-s3-write-role"
    Environment = local.environment
    Project     = var.project_name
  }
}

##########################
# Create IAM Policy (Dev Only)
##########################
resource "aws_iam_policy" "s3_write_policy" {
  count  = local.is_dev ? 1 : 0
  name   = "${var.project_name}-s3-write-policy"
  policy = data.aws_iam_policy_document.s3_write_policy.json
}

##########################
# Attach IAM Policy to Role (Dev Only)
##########################
resource "aws_iam_role_policy_attachment" "attach_write" {
  count      = local.is_dev ? 1 : 0
  role       = aws_iam_role.s3_write_role[0].name
  policy_arn = aws_iam_policy.s3_write_policy[0].arn
}

##########################
# IAM Instance Profile for EC2 (Dev Only)
##########################
resource "aws_iam_instance_profile" "ec2_profile" {
  count = local.is_dev ? 1 : 0
  name  = "${var.project_name}-ec2-profile"
  role  = aws_iam_role.s3_write_role[0].name

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [role]
  }

  tags = {
    Name        = "${local.environment}-ec2-profile"
    Environment = local.environment
    Project     = var.project_name
  }
}

##########################
# Lookup Shared IAM Instance Profile (Prod Only)
##########################
data "aws_iam_instance_profile" "shared_profile" {
  count = local.is_dev ? 0 : 1
  name  = "${var.project_name}-ec2-profile"
}

##########################
# Attach RW Policy to Existing Role (Prod Only)
##########################
resource "aws_iam_role_policy_attachment" "attach_rw_policy_prod" {
  count      = local.is_dev ? 0 : 1
  role       = data.aws_iam_instance_profile.shared_profile[0].role_name
  policy_arn = aws_iam_policy.s3_rw_policy.arn
}
