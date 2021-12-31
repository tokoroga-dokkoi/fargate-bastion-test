module "network" {
  source = "terraform-aws-modules/vpc/aws"

  name = "fargate-bastion-sample"
  cidr = "10.0.0.0/16"

  azs = [
    "ap-northeast-1a",
    "ap-northeast-1c"
  ]

  public_subnets = [
    "10.0.0.0/24",
    "10.0.1.0/24"
  ]

  private_subnets = [
    "10.0.10.0/24",
    "10.0.11.0/24"
  ]

  enable_nat_gateway = false
  single_nat_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true
}
