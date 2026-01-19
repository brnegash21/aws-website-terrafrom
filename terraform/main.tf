# ============================================================
# main.tf
# Requirement: include the FULL anatomy of how to build/write
# each block + correct, valid Terraform references.
# ============================================================


# ============================================================
# TERRAFORM BLOCK
# ============================================================
# -------------------------------
# Block Syntax:
# terraform {
#   <TERRAFORM_ARGUMENT> = <VALUE>
#
#   required_providers {
#     <PROVIDER_LOCAL_NAME> = {
#       source  = "<NAMESPACE>/<PROVIDER>"
#       version = "<VERSION_CONSTRAINT>"
#     }
#   }
# }
#
# Anatomy:
# - terraform: block keyword
# - required_version: terraform argument (Terraform CLI constraint)
# - required_providers: nested block (provider requirements)
# - aws: provider local name (how you refer to provider config blocks)
# - source: provider registry address
# - version: version constraint
# -------------------------------
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


# ============================================================
# REFERENCE ANATOMY CHEAT SHEET (VALID TERRAFORM)
# ============================================================
# -------------------------------
# 1) Referencing a RESOURCE ATTRIBUTE
# Syntax: <RESOURCE_TYPE>.<RESOURCE_NAME>.<ATTRIBUTE>
# Example: aws_s3_bucket.s3.id
# - aws_s3_bucket: resource type
# - s3: resource name (label; local name used for reference)
# - id: attribute
#
# 2) Referencing a VARIABLE
# Syntax: var.<VARIABLE_NAME>
# Example: var.s3_bucket_name
# - var: variable namespace
# - s3_bucket_name: variable name
#
# 3) Referencing a LOCAL
# Syntax: local.<LOCAL_NAME>
# Example: local.common_tags
# - local: locals namespace
# - common_tags: local name
#
# Notes on INVALID examples (fixed):
# - var.aws_instance.web.region  invalid: var.* is only variables; resources are not under var.*
# - aws_s3_bucket.s3-bucket.bucket invalid: resource name labels cannot contain hyphens
# -------------------------------


# ============================================================
# RESOURCE BLOCK ANATOMY (GENERAL)
# ============================================================
# -------------------------------
# Resource Syntax:
# resource "<PROVIDER>_<RESOURCE_TYPE>" "<RESOURCE_NAME>" {
#   <ARGUMENT> = <VALUE>
# }
#
# Anatomy:
# - resource: block keyword
# - "<PROVIDER>_<RESOURCE_TYPE>": resource type
#   - provider: aws
#   - resource kind: s3_bucket, s3_bucket_policy, etc.
# - "<RESOURCE_NAME>": resource name (label; local reference name; must be letters/numbers/underscores)
# - <ARGUMENT>: configurable field for the resource
# - <VALUE>: literal/expression (var.*, local.*, resource refs, functions)
# -------------------------------


# ============================================================
# S3 BUCKET RESOURCE
# ============================================================
resource "aws_s3_bucket" "s3" {
  # bucket: argument (S3 bucket name)
  # var: variable namespace
  # s3_bucket_name: variable name defined in variables.tf
  bucket = var.s3_bucket_name

  # tags: argument (map of string)
  # Map syntax: { <KEY> = <VALUE>, ... }
  tags = {
    key = "Dev"
  }
}

# Reference Example (resource attribute):
# Syntax: <RESOURCE_TYPE>.<RESOURCE_NAME>.<ATTRIBUTE>
# aws_s3_bucket.s3.id
# - aws_s3_bucket: resource type
# - s3: resource name
# - id: attribute


# ============================================================
# S3 WEBSITE CONFIGURATION
# ============================================================
# Enables static website hosting for the bucket.
# Website endpoint format:
# http://<bucket-name>.s3-website-<region>.amazonaws.com
resource "aws_s3_bucket_website_configuration" "s3_website_config" {
  # bucket: argument (expects bucket name)
  #
  # Resource Reference Syntax: <RESOURCE_TYPE>.<RESOURCE_NAME>.<ATTRIBUTE>
  # aws_s3_bucket.s3.id
  # - aws_s3_bucket: resource type
  # - s3: resource name
  # - id: attribute (bucket name/id for AWS provider)
  bucket = aws_s3_bucket.s3.id

  index_document {
    # suffix: argument inside index_document block
    # (default file served at root)
    suffix = "index.html"
    # If you want this variable-driven:
    # suffix = var.index_doc
    # - var: variable namespace
    # - index_doc: variable name
  }

  error_document {
    # key: argument inside error_document block
    key = var.error_doc
    # If you want this variable-driven:
    # key = var.error_doc
  }
}


# ============================================================
# PUBLIC ACCESS BLOCK (ALLOW PUBLIC WEBSITE ACCESS)
# ============================================================
# NOTE:
# - Resource name labels cannot contain hyphens, so we use underscores.
resource "aws_s3_bucket_public_access_block" "s3_public_access_block" {
  # bucket: argument (expects bucket name)
  #
  # Resource Reference Syntax: <RESOURCE_TYPE>.<RESOURCE_NAME>.<ATTRIBUTE>
  # aws_s3_bucket.s3.id
  # - aws_s3_bucket: resource type
  # - s3: resource name
  # - id: attribute
  bucket = var.s3_bucket_name.id

  # These four flags control account/bucket-level blocking of public access.
  # For static website hosting with public reads, these are often set to false.
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# ============================================================
# BUCKET POLICY (ALLOW PUBLIC READ OF OBJECTS)
# ============================================================
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  # bucket: argument (expects bucket name)
  bucket = aws_s3_bucket.s3.id

  # policy: argument (JSON string)
  # jsonencode(...): Terraform function to convert HCL object -> JSON string
  policy = jsonencode({
    # Version: JSON key required by AWS IAM policy grammar
    Version = "2012-10-17"

    # Statement: list of policy statements
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"

        # Resource: ARN for all objects in the bucket
        # String interpolation: "${ ... }"
        #
        # Resource Reference Syntax: <RESOURCE_TYPE>.<RESOURCE_NAME>.<ATTRIBUTE>
        # aws_s3_bucket.s3.arn
        # - aws_s3_bucket: resource type
        # - s3: resource name
        # - arn: attribute
        Resource = "${aws_s3_bucket.s3.arn}/*"
      }
    ]
  })

  # depends_on: meta-argument to force ordering when needed
  # Syntax: depends_on = [ <RESOURCE_TYPE>.<RESOURCE_NAME>, ... ]
  #
  # aws_s3_bucket.s3
  # - aws_s3_bucket: resource type
  # - s3: resource name
  depends_on = [aws_s3_bucket.s3]
}
