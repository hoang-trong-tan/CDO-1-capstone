variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix dùng cho resource name"
  type        = string
  default     = "tf3-cdo1-sandbox"
}

locals {
  common_tags = {
    Project   = "self-heal-platform"
    TaskForce = "tf-3"
    Team      = "cdo-1"
    Env       = "sandbox"
    ManagedBy = "terraform"
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
}
