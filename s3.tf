resource "aws_s3_bucket" "logs_bucket" {
  bucket = var.logs_bucket_name

  force_destroy = true

  tags = {
    Name = "${var.environment}-logs"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "log_expiry" {
  bucket = aws_s3_bucket.logs_bucket.id

  rule {
    id     = "delete-logs-after-7-days"
    status = "Enabled"

    filter {
      prefix = ""  # Applies to all objects
    }

    expiration {
      days = 7
    }
  }
}
  