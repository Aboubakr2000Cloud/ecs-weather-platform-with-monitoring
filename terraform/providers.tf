terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {} # values from backends/dev.hcl
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "ecs-weather-platform"
      Environment = var.environment
      ManagedBy   = "terraform"
      Week        = "18"
    }
  }
}
