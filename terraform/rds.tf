locals {
  parameter_list = [
    {
      name = "character_set_client"
      value = "utf8mb4"
      apply_method = "immediate"
    },
    {
      name = "character_set_connection"
      value = "utf8mb4"
      apply_method = "immediate"
    },
    {
      name = "character_set_database"
      value = "utf8mb4"
      apply_method = "immediate"
    },
    {
      name = "character_set_filesystem"
      value = "utf8mb4"
      apply_method = "immediate"
    },
    {
      name = "character_set_results"
      value = "utf8mb4"
      apply_method = "immediate"
    },
    {
      name = "character_set_server"
      value = "utf8mb4"
      apply_method = "immediate"
    },
    {
      name = "collation_connection"
      value = "utf8mb4_general_ci"
      apply_method = "immediate"
    },
    {
      name = "collation_server"
      value = "utf8mb4_general_ci"
      apply_method = "immediate"
    },
    {
      name = "time_zone"
      value = "Asia/Tokyo"
      apply_method = "immediate"
    }
  ]
}


module "aurora_cluster" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name = "bastion-test-mysql"
  engine = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.01.0"
  instance_class = "db.t4g.medium"
  instances = {
    one = {}
  }

  vpc_id = module.network.vpc_id
  subnets = module.network.private_subnets

  db_parameter_group_name = aws_db_parameter_group.example.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.example.id

  create_security_group = false
  vpc_security_group_ids = [
    module.rds_sg.security_group_id
  ]

  create_monitoring_role = true
  monitoring_interval = 10 // sec

  create_random_password = false
  master_username = "admin"
  master_password = "password" // password is changed after create via management console

  storage_encrypted = true

  skip_final_snapshot = true

}

resource "aws_db_parameter_group" "example" {
  name        = "aurora-db-80-parameter-group"
  family      = "aurora-mysql8.0"
  description = "aurora-db-80-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "example" {
  name        = "aurora-80-cluster-parameter-group"
  family      = "aurora-mysql8.0"
  description = "aurora-80-cluster-parameter-group"

  dynamic "parameter" {
    for_each = local.parameter_list

    content {
      name = parameter.value.name
      value = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }
}

data "aws_iam_policy" "enhanced_monitoring_policy" {
  name = "AmazonRDSEnhancedMonitoringRole"
}

module "rds_enhanced_monitoring_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.3"

  trusted_role_services = [
    "monitoring.rds.amazonaws.com"
  ]

  create_role = true
  role_name = "rds-enhanced-monitoring-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    data.aws_iam_policy.enhanced_monitoring_policy.arn
  ]
}
