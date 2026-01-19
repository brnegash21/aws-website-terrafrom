

variable "aws_s3_bucket_name" {
  description = "The name of the S3 bucket to host the static website"
  type        = string
  default = "bm-tf-static-website-bucket"

  
}