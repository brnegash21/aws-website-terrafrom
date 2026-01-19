output "bucket_name" {
  value = var.s3_bucket_name
}

# S3 website endpoint URL
output "website_url" {
  value = "http://${aw}"
}