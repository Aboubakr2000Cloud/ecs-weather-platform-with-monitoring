locals {
  name_prefix = "ecs-weather-platform-${var.environment}"
  common_tags = {
    Project     = "ecs-weather-platform"
    Environment = var.environment
    ManagedBy   = "terraform"
    Week        = "18"
    Owner       = "Abou"
  }
}


