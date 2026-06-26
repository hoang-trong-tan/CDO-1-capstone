module "observability" {
  source = "../../infra/modules/observability"

  cluster_name          = data.terraform_remote_state.aws_foundation.outputs.cluster_name
  cluster_endpoint      = data.terraform_remote_state.aws_foundation.outputs.cluster_endpoint
  oidc_provider_arn     = data.terraform_remote_state.aws_foundation.outputs.oidc_provider_arn
  kms_observability_arn = data.terraform_remote_state.aws_foundation.outputs.kms_observability_arn
  tags                  = local.common_tags
}
