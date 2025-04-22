resource "aws_s3_bucket" "processed-pipeline-data" {
  bucket = var.s3_bucket_name
}
