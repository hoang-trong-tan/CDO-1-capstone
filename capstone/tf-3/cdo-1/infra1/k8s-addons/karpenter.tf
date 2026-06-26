module "karpenter" {
  source = "../../infra/modules/karpenter"

  cluster_name       = data.terraform_remote_state.aws_foundation.outputs.cluster_name
  oidc_provider_arn  = data.terraform_remote_state.aws_foundation.outputs.oidc_provider_arn
  private_subnet_ids = data.terraform_remote_state.aws_foundation.outputs.private_subnet_ids
  sg_eks_workload_id = data.terraform_remote_state.aws_foundation.outputs.sg_eks_workload_id
  node_iam_role_arn  = data.terraform_remote_state.aws_foundation.outputs.node_iam_role_arn
  node_iam_role_name = data.terraform_remote_state.aws_foundation.outputs.node_iam_role_name
  tags               = local.common_tags
}
