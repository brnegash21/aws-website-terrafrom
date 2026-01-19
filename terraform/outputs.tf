# ============================================================
# OUTPUT BLOCK ANATOMY (GENERAL)
# ============================================================
# -------------------------------
# Output Syntax:
# output "<OUTPUT_NAME>" {
#   value       = <EXPRESSION>
#   description = "<OPTIONAL_DESCRIPTION>"
#   sensitive   = <OPTIONAL_BOOL>
# }
#
# Anatomy:
# - output: block keyword
# - "<OUTPUT_NAME>": output name (used by terraform output / module callers)
# - value: expression whose result is exposed
# - description: human-readable documentation (optional but recommended)
# - sensitive: hides value from CLI output if true
# -------------------------------


# ============================================================
# OUTPUT: S3 BUCKET NAME
# ============================================================
output "bucket_name" {
  # value: expression returned by this output
  #
  # Variable Reference Syntax: var.<VARIABLE_NAME>
  # var.s3_bucket_name
  # - var: variable namespace
  # - s3_bucket_name: variable name
  value = var.s3_bucket_name

  description = "Name of the S3 bucket hosting the static website"
}


# ============================================================
# OUTPUT: S3 BUCKET ARN
# ============================================================
output "bucket_arn" {
  # Resource Reference Syntax: <RESOURCE_TYPE>.<RESOURCE_NAME>.<ATTRIBUTE>
  # aws_s3_bucket.s3.arn
  # - aws_s3_bucket: resource type
  # - s3: resource name
  # - arn: attribute
  value = aws_s3_bucket.s3.arn

  description = "ARN of the S3 bucket"
}


# ============================================================
# OUTPUT: S3 WEBSITE ENDPOINT (AWS-COMPUTED)
# ============================================================
output "website_endpoint" {
  # Resource Reference Syntax:
  # aws_s3_bucket_website_configuration.s3_website_config.website_endpoint
  #
  # Breakdown:
  # - aws_s3_bucket_website_configuration: resource type
  # - s3_website_config: resource name
  # - website_endpoint: attribute (computed by AWS)
  value = aws_s3_bucket_website_configuration.s3_website_config.website_endpoint

  description = "AWS-generated S3 static website endpoint"
}


# ============================================================
# OUTPUT: FULL WEBSITE URL (HTTP)
# ============================================================
output "website_url" {
  # String interpolation syntax:
  # "http://${ <EXPRESSION> }"
  #
  # Embedded Resource Reference:
  # aws_s3_bucket_website_configuration.s3_website_config.website_endpoint
  value = "http://${aws_s3_bucket_website_configuration.s3_website_config.website_endpoint}"

  description = "Full HTTP URL for the S3 static website"
}


# ============================================================
# OUTPUT: REGIONAL S3 DOMAIN NAME (NON-WEBSITE)
# ============================================================
output "bucket_regional_domain_name" {
  # Resource Reference Syntax:
  # aws_s3_bucket.s3.bucket_regional_domain_name
  value = aws_s3_bucket.s3.bucket_regional_domain_name

  description = "Regional S3 domain name (not the website endpoint)"
}


# ============================================================
# OUTPUT: ALL WEBSITE-RELATED INFO (OBJECT OUTPUT)
# ============================================================
output "website_info" {
  # value: object constructed from multiple references
  value = {
    # bucket_name: variable reference
    bucket_name = var.s3_bucket_name

    # bucket_arn: resource attribute reference
    bucket_arn = aws_s3_bucket.s3.arn

    # website_endpoint: resource attribute reference
    website_endpoint = aws_s3_bucket_website_configuration.s3_website_config.website_endpoint

    # website_url: interpolated string
    website_url = "http://${aws_s3_bucket_website_configuration.s3_website_config.website_endpoint}"
  }

  description = "Consolidated object containing all S3 website-related values"
}
