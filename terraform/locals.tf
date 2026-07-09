locals {
  name_prefix    = "weather-monitoring-${var.environment}"
  monitor_prefix = "wm-${var.environment}"
  common_tags = {
    Project     = "ecs-weather-platform-with-monitoring"
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "Abou"
  }
}


