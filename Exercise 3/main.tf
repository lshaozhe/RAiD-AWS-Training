module "network" {
  source = "./modules/network"
}

module "ec2" {
  source = "./modules/ec2"

  vpc_id            = module.network.vpc_id
  private_subnet_id = module.network.private_subnet_id
}

module "alb" {
  source = "./modules/alb"

  vpc_id           = module.network.vpc_id
  public_subnet_id = module.network.public_subnet_id
}