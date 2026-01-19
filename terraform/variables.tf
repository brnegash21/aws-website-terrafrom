# -------------------------------
# Variable Definitions
# -------------------------------

# S3 bucket name variable
variable "s3_bucket_name" {
  # description: human-readable explanation of the variable
  description = "The name of the S3 bucket used to host the static website"

  # type: enforces the value type expected for this variable
  # string: must be a string value
  type = string

  # default: value used if no override is provided
  default = "bmilli-embassy"
}

# Index document variable
variable "index_doc" {
  # description: explains the purpose of the variable
  description = "Default file served at the root of the static website"

  # type: expected variable type
  type = string

  # default: file served when accessing the root URL
  default = "index.html"
}

# Error document variable
variable "error_doc" {
  # description: explains when this file is used
  description = "File served when a website error occurs (e.g. 404)"

  # type: expected variable type
  type = string

  # default: error page filename
  default = "index.html"
}
