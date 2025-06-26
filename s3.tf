# Create S3 Bucket only in 'default' or 'dev' Workspace
resource "aws_s3_bucket" "logs_bucket" {
  count         = local.is_dev ? 1 : 0
  bucket        = var.logs_bucket_name
  force_destroy = true

  tags = {
    Name        = "${local.environment}-logs"
    Environment = local.environment
    Project     = var.project_name
  }
}

# Reference Existing Bucket only in non-dev workspaces (e.g., prod)
data "aws_s3_bucket" "logs_bucket" {
  count  = local.is_dev ? 0 : 1
  bucket = var.logs_bucket_name
}

# Use Versioning only when bucket is created
resource "aws_s3_bucket_versioning" "versioning" {
  count  = local.is_dev ? 1 : 0
  bucket = aws_s3_bucket.logs_bucket[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# Use Encryption only when bucket is created
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  count  = local.is_dev ? 1 : 0
  bucket = aws_s3_bucket.logs_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle Rule only when bucket is created
resource "aws_s3_bucket_lifecycle_configuration" "log_expiry" {
  count  = local.is_dev ? 1 : 0
  bucket = aws_s3_bucket.logs_bucket[0].id

  rule {
    id     = "delete-${local.environment}-logs-after-7-days"
    status = "Enabled"

    filter {
      prefix = "logs/${local.environment}/"
    }

    expiration {
      days = 7
    }
  }
}
