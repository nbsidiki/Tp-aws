# Create an S3 bucket
resource "aws_s3_bucket" "demo_bucket" {
  bucket = var.s3_bucket_name
}

# Enable versioning for the bucket
resource "aws_s3_bucket_versioning" "demo_bucket_versioning" {
  bucket = aws_s3_bucket.demo_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Upload a file to the bucket
resource "aws_s3_object" "demo_object" {
  bucket = aws_s3_bucket.demo_bucket.id
  key    = "hello-world.txt"
  source = "./test-file.txt"
  etag   = filemd5("./test-file.txt")
}

# Disable S3 Block Public Access to allow public read policy
resource "aws_s3_bucket_public_access_block" "demo_bucket_pab" {
  bucket = aws_s3_bucket.demo_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Add bucket policy to allow public read access
resource "aws_s3_bucket_policy" "demo_bucket_policy" {
  bucket = aws_s3_bucket.demo_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PublicReadGetObject"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.demo_bucket.arn}/*"
      }
    ]
  })

  # Ensure public access block is disabled first
  depends_on = [aws_s3_bucket_public_access_block.demo_bucket_pab]
}