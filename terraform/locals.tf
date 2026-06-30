locals {
  name_prefix = "ecs-weather-platform--cicd${var.environment}"
  common_tags = {
    Project     = "ecs-weather-platform-cicd"
    Environment = var.environment
    ManagedBy   = "terraform"
    Week        = "19"
    Owner       = "Abou"
  }
}


