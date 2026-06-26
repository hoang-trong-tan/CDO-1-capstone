variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tf_state_bucket" {
  description = "Bucket S3 lưu trữ tfstate của aws-foundation"
  type        = string
}

variable "tf_aws_foundation_key" {
  description = "Đường dẫn file state của aws-foundation trong bucket"
  type        = string
  default     = "sandbox/infra1/aws-foundation/terraform.tfstate"
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
