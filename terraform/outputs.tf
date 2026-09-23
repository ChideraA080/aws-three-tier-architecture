# -------------------------
# Network Outputs
# -------------------------

output "vpc_id" {
  description = "ID of the project VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = aws_subnet.database[*].id
}

# -------------------------
# Load Balancer Outputs
# -------------------------

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

# -------------------------
# EC2 Outputs
# -------------------------

output "web_instance_ids" {
  description = "IDs of the Nginx web servers"
  value       = aws_instance.web[*].id
}

output "app_instance_ids" {
  description = "IDs of the Node.js application servers"
  value       = aws_instance.app[*].id
}

# -------------------------
# Database Outputs
# -------------------------

output "rds_endpoint" {
  description = "Endpoint of the PostgreSQL database"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_port" {
  description = "Port used by the PostgreSQL database"
  value       = aws_db_instance.postgres.port
}

output "db_secret_arn" {
  description = "ARN of the database credentials secret"
  value       = aws_secretsmanager_secret.db.arn
}