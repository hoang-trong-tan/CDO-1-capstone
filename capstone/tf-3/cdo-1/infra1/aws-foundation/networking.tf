module "networking" {
  source = "../../../../infra/modules/networking"

  sg_vpc_endpoint_id = module.security.sg_vpc_endpoint_id
  tags               = local.common_tags
}
