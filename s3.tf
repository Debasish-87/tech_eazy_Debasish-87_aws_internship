resource "aws_s3_bucket" "logs_bucket" {
  bucket = var.logs_bucket_name

  tags = {
    Name = "${var.environment}-logs"
  }

  force_destroy = true  
}

resource "aws_s3_bucket_lifecycle_configuration" "log_expiry" {
  bucket = aws_s3_bucket.logs_bucket.id

  rule {
    id     = "delete-logs-after-7-days"
    status = "Enabled"

    filter {
      prefix = ""  
    }

    expiration {
      days = 7
    }
  }
}

