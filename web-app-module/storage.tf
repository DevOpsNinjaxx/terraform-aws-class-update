resource "aws_s3_bucket" "web-app-bucket" {
  bucket = var.bucket
}

resource "aws_s3_bucket_server_side_encryption_configuration" "web-app-bucket-encyption" {
  bucket = aws_s3_bucket.web-app-bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}