module "security" {
  source = "../../../../infra/modules/security"

  vpc_id   = module.networking.vpc_id
  vpc_cidr = module.networking.vpc_cidr
  tags     = local.common_tags
}
