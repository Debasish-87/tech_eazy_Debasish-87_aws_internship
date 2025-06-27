resource "aws_iam_role" "role_a_readonly" {
  count = var.stage =="dev" ? 1:0
  name = "readonly_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "readonly_policy" {
  count = var.stage =="dev" ? 1:0
  name        = "readonly_s3_policy"
  description = "Allows read-only access to S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = ["arn:aws:s3:::${var.log_s3_bucket_name}",
                    "arn:aws:s3:::${var.log_s3_bucket_name}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "readonly_attach" {
  count = var.stage =="dev" ? 1:0
  role       = aws_iam_role.role_a_readonly[0].name
  policy_arn = aws_iam_policy.readonly_policy[0].arn
}


resource "aws_iam_role" "role_b_uploader" {
  count = var.stage =="dev" ? 1:0
  name = "uploadonly_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "uploadonly_policy" {
  count = var.stage =="dev" ? 1:0
  name        = "uploadonly_s3_policy"
  description = "Allows write-only access to S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:CreateBucket",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = ["arn:aws:s3:::${var.log_s3_bucket_name}", 
                    "arn:aws:s3:::${var.log_s3_bucket_name}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "uploadonly_attach" {
  count = var.stage =="dev" ? 1:0
  role       = aws_iam_role.role_b_uploader[0].name
  policy_arn = aws_iam_policy.uploadonly_policy[0].arn
}

data "aws_iam_role" "role_b_uploader" {
  count = var.stage =="prod" ? 1:0
  name = "uploadonly_s3_role"
}