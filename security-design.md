# Security Design

## 1. Network Security

The application is deployed inside an AWS VPC with public, private, and database subnets across two Availability Zones.

The database subnets do not have a direct route to the internet.

The Nginx and Node.js EC2 instances are deployed in private subnets and do not have public IP addresses.

The Application Load Balancer is deployed in the public subnets and is the entry point for external application traffic.

## 2. Security Groups and Allowed Ports

Each application tier has its own security group.

### ALB Security Group

The ALB accepts:

- TCP port 80 from the internet for HTTP traffic.
- TCP port 443 from the internet for HTTPS traffic.

The ALB can send traffic to the web tier.

### Web Security Group

The Nginx web servers accept:

- TCP port 80 only from the ALB security group.

The web servers are not directly accessible from the internet.

### Application Security Group

The Node.js application servers accept:

- TCP port 3000 only from the web security group.

The application servers are not directly accessible from the internet.

### Database Security Group

The PostgreSQL database accepts:

- TCP port 5432 only from the application security group.

The database is not directly accessible from the internet.

## 3. Traffic Flow

The allowed application traffic follows this path:

```text
Internet
   |
   | HTTP/HTTPS
   v
Application Load Balancer
   |
   | TCP 80
   v
Nginx Web Tier
   |
   | TCP 3000
   v
Node.js Application Tier
   |
   | TCP 5432
   v
RDS PostgreSQL

This limits communication between tiers to only the ports required by the application.

4. Private Subnet Internet Access

The private EC2 instances can access the internet for required outbound activities through a NAT Gateway.

The traffic path is:

Private EC2
    |
    v
Private Route Table
    |
    v
NAT Gateway
    |
    v
Internet Gateway
    |
    v
Internet

The NAT Gateway allows outbound connections without giving the private EC2 instances public IP addresses.

5. Database Security

RDS PostgreSQL is configured with:

publicly_accessible = false
Multi-AZ deployment
Storage encryption enabled
Database subnet group spanning two Availability Zones
Security group allowing PostgreSQL traffic only from the application tier

The database is therefore isolated from direct internet access.

6. Database Credentials

Database credentials are not hardcoded in the Terraform configuration.

Terraform generates a random database password and stores the credentials in AWS Secrets Manager.

The Terraform configuration uses the generated password when creating the RDS instance.

Terraform state files are excluded from Git using .gitignore because Terraform state can contain sensitive infrastructure information.

The database credentials should not be committed to GitHub.

7. Encryption

RDS storage encryption is enabled to protect database data at rest.

For application traffic, HTTPS/TLS should be used for encrypted communication between users and the Application Load Balancer.

Database connections should use PostgreSQL SSL/TLS where supported by the application configuration.

8. Least Privilege

The security groups follow a least-privilege approach.

Only the required traffic between application tiers is allowed:

Source	Destination	Port	Purpose
Internet	ALB	80	HTTP
Internet	ALB	443	HTTPS
ALB	Web	80	Nginx
Web	Application	3000	Node.js
Application	Database	5432	PostgreSQL

There is no direct internet access to the Nginx servers, Node.js servers, or RDS database.

9. Security Summary

The architecture uses multiple security layers:

VPC network isolation
Public and private subnets
Isolated database subnets
Security groups for each tier
Private EC2 instances
NAT Gateway for controlled outbound access
Non-public RDS database
RDS encryption at rest
Secrets Manager for database credentials
Multi-AZ deployment for availability
