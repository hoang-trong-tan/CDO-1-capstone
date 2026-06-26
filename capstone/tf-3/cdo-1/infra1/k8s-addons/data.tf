data "terraform_remote_state" "aws_foundation" {
  backend = "s3"
  config = {
    bucket = var.tf_state_bucket
    key    = var.tf_aws_foundation_key
    region = var.aws_region
  }
}
