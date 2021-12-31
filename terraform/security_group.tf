module "bastion_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "bastion-test-sg"
  description = "Bastion Test Security Group"
  vpc_id      = module.network.vpc_id

  egress_rules = [
    "all-all"
  ]
}

module "rds_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "rds-test-sg"
  description = "Bastion Test RDS Security Group"
  vpc_id      = module.network.vpc_id

  ingress_with_source_security_group_id = [
    {
      description              = "Allow Mysql from bastion"
      rule                     = "mysql-tcp"
      source_security_group_id = module.bastion_sg.security_group_id
    }
  ]

  egress_rules = [
    "all-all"
  ]
}
