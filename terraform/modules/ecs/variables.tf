variable "cluster_name" { type = string }
variable "service_name" { type = string }
variable "name_prefix" { type = string }
variable "common_tags" { type = map(string) }
variable "image_url" { type = string }
variable "container_name" { type = string }
variable "container_port" {
  type    = number
  default = 8080
}
variable "cpu" {
  type    = string
  default = "256"
}
variable "memory" {
  type    = string
  default = "512"
}
variable "desired_count" {
  type    = number
  default = 2
}
variable "private_subnet_ids" { type = list(string) }
variable "ecs_sg_id" { type = string }
variable "target_group_arn" { type = string }
variable "execution_role_arn" { type = string }
variable "task_role_arn" { type = string }
variable "region" { type = string }
variable "db_host" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_secret_arn" { type = string }
variable "weather_api_key_arn" { type = string }
variable "log_group_name" { type = string }
