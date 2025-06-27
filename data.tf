# Assume Role for EC2
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# S3 Read Policy
data "aws_iam_policy_document" "s3_read_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = [
      format("arn:aws:s3:::%s", var.logs_bucket_name),
      format("arn:aws:s3:::%s/*", var.logs_bucket_name)
    ]
  }
}

# S3 Write Policy
data "aws_iam_policy_document" "s3_write_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:CreateBucket"
    ]
    resources = [
      format("arn:aws:s3:::%s", var.logs_bucket_name),
      format("arn:aws:s3:::%s/*", var.logs_bucket_name)
    ]
  }
}
