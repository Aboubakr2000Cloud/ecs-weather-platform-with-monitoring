output "alb_sg_id" { value = aws_security_group.alb.id }
output "rds_sg_id" { value = aws_security_group.rds.id }
output "ecs_sg_id" { value = aws_security_group.ecs_task.id }

