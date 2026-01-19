terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


resource "aws_s3_bucket" "s3-bucket" {
  bucket = var.aws_s3_bucket_name

  tags = {
    Name = "Bmilli's Bucket"
    Enviroment = "Dev"
  }
}