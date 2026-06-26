variable "aws_region" {
  description = "AWS region (được truyền từ biến Github Actions qua env TF_VAR_aws_region)"
  type        = string
}

variable "environment" {
  description = "Tên môi trường"
  type        = string
  default     = "sandbox"
}
