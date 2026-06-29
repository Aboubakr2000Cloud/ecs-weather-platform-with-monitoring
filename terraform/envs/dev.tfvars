environment          = "dev"
region               = "eu-west-1"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
azs                  = ["eu-west-1a", "eu-west-1b"]
db_instance_class    = "db.t3.micro"
db_name              = "weatherapp"
db_username          = "admin"

service_name    = "weather-app"
repository_name = "weather-app"
container_name  = "weather-app"


ecs_desired_count = 2

