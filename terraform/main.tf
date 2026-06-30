# ── VPC ──────────────────────────────────────────────────────────
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  name_prefix          = local.name_prefix
  common_tags          = local.common_tags
}

# ── Security Groups ───────────────────────────────────────────────
module "security_groups" {
  source = "./modules/security_groups"

  vpc_id      = module.vpc.vpc_id
  name_prefix = local.name_prefix
  common_tags = local.common_tags
}

# ── ALB ───────────────────────────────────────────────────────────
module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security_groups.alb_sg_id
  name_prefix       = local.name_prefix
  common_tags       = local.common_tags
}

# ── RDS ───────────────────────────────────────────────────────────
module "rds" {
  source = "./modules/rds"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id          = module.security_groups.rds_sg_id
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  db_instance_class  = var.db_instance_class
  name_prefix        = local.name_prefix
  common_tags        = local.common_tags
}

# ── ECR ───────────────────────────────────────────────────────────
module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.repository_name
  name_prefix     = local.name_prefix
  common_tags     = local.common_tags
}

# ── ECS ───────────────────────────────────────────────────────────
module "ecs" {
  source = "./modules/ecs"

  cluster_name        = "${local.name_prefix}-cluster"
  service_name        = var.service_name
  container_name      = var.container_name
  name_prefix         = local.name_prefix
  common_tags         = local.common_tags
  image_url           = "${module.ecr.repository_url}:bootstrap"
  private_subnet_ids  = module.vpc.private_subnet_ids
  ecs_sg_id           = module.security_groups.ecs_sg_id
  target_group_arn    = module.alb.target_group_arn
  execution_role_arn  = aws_iam_role.ecs_execution.arn
  task_role_arn       = aws_iam_role.ecs_task.arn
  region              = var.region
  db_host             = module.rds.db_host
  db_name             = var.db_name
  db_username         = var.db_username
  db_secret_arn       = aws_secretsmanager_secret_version.db_password.arn
  weather_api_key_arn = aws_secretsmanager_secret_version.weather_api_key.arn
  log_group_name      = "/ecs/${local.name_prefix}"
  desired_count       = var.ecs_desired_count
}

