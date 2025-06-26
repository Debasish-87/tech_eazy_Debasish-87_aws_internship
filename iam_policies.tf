##############################################
# S3 READ-WRITE POLICY (for EC2 & other roles)
##############################################

data "aws_iam_policy_document" "s3_rw_policy" {
  statement {
    sid     = "S3ReadWriteAccessForEnvironment"
    effect  = "Allow"

    actions = [
      "s3:GetObject",          #  Read files
      "s3:ListBucket",         #  List files in bucket
      "s3:PutObject",          #  Write/upload logs
      "s3:PutObjectAcl"        #  Optional: Set permissions (useful for public-read etc.)
    ]

    resources = [
      #  Needed for listing top-level directory
      "arn:aws:s3:::${var.logs_bucket_name}",

      #  Read/Write access to logs and status paths
      "arn:aws:s3:::${var.logs_bucket_name}/logs/${terraform.workspace}/*",
      "arn:aws:s3:::${var.logs_bucket_name}/status/${terraform.workspace}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_rw_policy" {
  name   = "${terraform.workspace}_s3_rw_policy"
  policy = data.aws_iam_policy_document.s3_rw_policy.json
}


data "aws_instance" "dev_instance" {
  count = local.is_dev ? 0 : 1
  filter {
    name   = "tag:Name"
    values = ["dev-app-instance"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }


}
