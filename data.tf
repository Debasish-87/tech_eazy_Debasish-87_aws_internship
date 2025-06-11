data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_read_policy" {
  statement {
    actions = ["s3:ListBucket", "s3:GetObject"]
    resources = [
        "arn:aws:s3:::${var.logs_bucket_name}",
        "arn:aws:s3:::${var.logs_bucket_name}/*"
    ]
  }
}

data "aws_iam_policy_document" "s3_write_policy" {
  statement {
    actions = ["s3:PutObject", "s3:CreateBucket"]
    resources = [
        "arn:aws:s3:::${var.logs_bucket_name}",
        "arn:aws:s3:::${var.logs_bucket_name}/*"
    ]
  }
}
