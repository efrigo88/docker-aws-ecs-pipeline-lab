# S3 bucket for processed data
resource "aws_s3_bucket" "processed-pipeline-data" {
  bucket = var.s3_bucket_name
}

# S3 bucket for scripts
resource "aws_s3_bucket" "scripts" {
  bucket = "${var.s3_bucket_name}-scripts"
}

# Upload init script to S3
resource "aws_s3_object" "init_script" {
  bucket = aws_s3_bucket.scripts.id
  key    = "init-script.sh"
  source = "${path.module}/../scripts/init-script.sh"
  etag   = filemd5("${path.module}/../scripts/init-script.sh")
}
