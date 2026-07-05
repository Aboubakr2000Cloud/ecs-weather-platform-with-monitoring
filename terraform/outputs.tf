# ALB
output "alb_url" {
  value = "http://${module.alb.alb_dns_name}"
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

# RDS
output "db_host" {
  value = module.rds.db_host
}

output "db_name" {
  value = module.rds.db_name
}

# Networking
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

# ALB Target Group
output "target_group_arn" {
  value = module.alb.target_group_arn
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task.arn
}

output "ecr_repo_url" {
  value = module.ecr.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "log_group_name" {
  value = module.ecs.log_group_name
}

output "task_definition_family" {
  value = module.ecs.task_definition_family
}

output "container_name" {
  value = var.container_name
}

output "monitoring_dashboard" {
  description = "CloudWatch monitoring dashboard"
  value       = module.monitoring.dashboard_name
}

output "monitoring_dashboard_arn" {
  description = "CloudWatch monitoring dashboard ARN"
  value       = module.monitoring.dashboard_arn
}

output "alerts_sns_topic" {
  description = "SNS topic for monitoring alerts"
  value       = module.monitoring.sns_topic_arn
}

output "budget_name" {
  description = "Monthly AWS budget"
  value       = module.monitoring.budget_name
}
