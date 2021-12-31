output "network" {
  description = "network設定"
  value       = module.network
}

output "bastion_ecr_repo_url" {
  description = "Bastion用ECRリポジトリURL"
  value       = aws_ecr_repository.bastion.repository_url
}

output "bastion_ecr_repo_id" {
  description = "Bastion用ECR"
  value       = aws_ecr_repository.bastion.id
}

output "bastion_sg" {
  description = "Bastion用SecurityGroup"
  value       = module.bastion_sg
}

output "rds_sg" {
  description = "RDS用SecurityGroup"
  value       = module.rds_sg
}

output "example_parameter_group_arn" {
  value = aws_db_parameter_group.example.arn
}
output "example_parameter_group_id" {
  value = aws_db_parameter_group.example.id
}

output "example_cluster_parameter_group_arn" {
  value = aws_rds_cluster_parameter_group.example.arn
}
output "example_cluster_parameter_group_id" {
  value = aws_rds_cluster_parameter_group.example.id
}

output "aurora_cluster" {
  value = module.aurora_cluster
  sensitive = true
}

output "ecs_task_role" {
  value = module.bastion_task_role
}

output "ecs_bastion_ssm_pass_role" {
  value = module.bastion_ssm_pass_role
}
