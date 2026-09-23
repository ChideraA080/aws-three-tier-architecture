# -------------------------
# Database Credentials
# -------------------------

resource "random_password" "db" {
  length  = 24
  special = true
}

resource "aws_secretsmanager_secret" "db" {
  name = "${var.project_name}-db-credentials"

  tags = {
    Name        = "${var.project_name}-db-credentials"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = "appadmin"
    password = random_password.db.result
  })
}

# -------------------------
# RDS Subnet Group
# -------------------------

resource "aws_db_subnet_group" "main" {
  name = "${var.project_name}-db-subnet-group"

  subnet_ids = aws_subnet.database[*].id

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Environment = var.environment
  }
}

# -------------------------
# RDS PostgreSQL
# -------------------------

resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-postgres"

  engine         = "postgres"
  engine_version = "17"

  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "appdb"
  username = "appadmin"
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible = false

  multi_az = true

  storage_encrypted = true

  backup_retention_period = 7

  skip_final_snapshot = true

  tags = {
    Name        = "${var.project_name}-postgres"
    Environment = var.environment
    Tier        = "database"
  }
}