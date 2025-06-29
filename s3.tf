resource "aws_s3_bucket" "log_s3_bucket" {
  count = var.stage =="dev" ? 1:0
  bucket = var.log_s3_bucket_name
  force_destroy = true

  tags = {
    Name = "LogBucket"
    stage = var.stage
  }
}

resource "aws_s3_bucket_public_access_block" "log_bucket" {
 count = var.stage =="dev" ? 1:0
 bucket = aws_s3_bucket.log_s3_bucket[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "log_lifecycle" {
  count = var.stage =="dev" ? 1:0
  bucket = aws_s3_bucket.log_s3_bucket[0].id

  rule {
    id     = "delete_logs_after_7_days"
    status = "Enabled"

    expiration {
      days = 7
    }

    filter {}
  }
}

# Reuse in prod if already created in dev
data "aws_s3_bucket" "log_s3_bucket" {
  count = var.stage =="prod" ? 1:0
  bucket = var.log_s3_bucket_name
}