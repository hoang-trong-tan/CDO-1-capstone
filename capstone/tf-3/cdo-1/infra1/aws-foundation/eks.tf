module "eks" {
  source = "../../../../infra/modules/eks"

  vpc_id                  = module.networking.vpc_id
  private_subnet_ids      = module.networking.private_subnet_ids
  sg_eks_workload_id      = module.security.sg_eks_workload_id
  sg_eks_control_plane_id = module.security.sg_eks_control_plane_id
  kms_infra_arn           = module.security.kms_infra_arn
  tags                    = local.common_tags
}
