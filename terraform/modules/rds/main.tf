# ── DB SUBNET GROUP ─────────────────────────────────────────────────────
resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
}

# ── DB INSTANCE ─────────────────────────────────────────────────────────
resource "aws_db_instance" "this" {
  identifier        = "${var.name_prefix}-db"
  engine            = "mysql"
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password # from TF_VAR_db_password env var

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_sg_id]

  multi_az            = false
  publicly_accessible = false

  final_snapshot_identifier = "${var.name_prefix}-final-snapshot"
  skip_final_snapshot       = true
  backup_retention_period   = 1

  deletion_protection = false
  storage_encrypted   = true

  tags = {
    Name = "${var.name_prefix}-db"
  }
}
