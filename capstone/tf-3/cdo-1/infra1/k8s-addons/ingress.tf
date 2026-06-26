module "ingress" {
  source = "../../infra/modules/ingress"

  cluster_name       = data.terraform_remote_state.aws_foundation.outputs.cluster_name
  cluster_endpoint   = data.terraform_remote_state.aws_foundation.outputs.cluster_endpoint
  oidc_provider_arn  = data.terraform_remote_state.aws_foundation.outputs.oidc_provider_arn
  vpc_id             = data.terraform_remote_state.aws_foundation.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.aws_foundation.outputs.private_subnet_ids
  sg_alb_internal_id = data.terraform_remote_state.aws_foundation.outputs.sg_alb_internal_id
  tags               = local.common_tags
}
