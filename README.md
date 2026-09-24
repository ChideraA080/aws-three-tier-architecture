# AWS Three-Tier Architecture with Terraform

## Project Overview

This project demonstrates a highly available three-tier web application architecture on AWS, provisioned using Terraform.

The architecture separates the application into three layers:

* **Web Tier:** Nginx running on EC2
* **Application Tier:** Node.js running on EC2
* **Database Tier:** PostgreSQL running on Amazon RDS

The infrastructure is deployed across two Availability Zones to improve availability and uses private subnets for the web, application, and database resources.

## Architecture

```text
                         INTERNET
                             |
                             v
                    +----------------+
                    |      ALB       |
                    | Public Subnets |
                    +-------+--------+
                            |
                            | HTTP :80
                            v
              +---------------------------+
              |       WEB TIER             |
              |      Nginx on EC2          |
              |                            |
              |     AZ-1       AZ-2        |
              +-------+---------+----------+
                      |         |
                      | TCP 3000|
                      v         v
              +---------------------------+
              |    APPLICATION TIER        |
              |      Node.js on EC2        |
              |                            |
              |     AZ-1       AZ-2        |
              +-------------+--------------+
                            |
                            | TCP 5432
                            v
              +---------------------------+
              |       DATABASE TIER        |
              |     PostgreSQL on RDS      |
              |       Multi-AZ             |
              +---------------------------+

                 PRIVATE SUBNET OUTBOUND
                            |
                            v
                       NAT Gateway
                            |
                            v
                     Internet Gateway
                            |
                            v
                         Internet
```

## AWS Resources

The Terraform configuration provisions:

* VPC
* Internet Gateway
* Public subnets across two Availability Zones
* Private subnets across two Availability Zones
* Isolated database subnets across two Availability Zones
* Public and private route tables
* NAT Gateway
* Elastic IP for NAT Gateway
* Application Load Balancer
* ALB target group and listener
* Two Nginx web EC2 instances
* Two Node.js application EC2 instances
* Amazon RDS PostgreSQL
* RDS Multi-AZ deployment
* Security groups for each application tier
* AWS Secrets Manager secret for database credentials

## Network Design

### VPC

CIDR:

```text
10.0.0.0/16
```

### Public Subnets

```text
10.0.1.0/24  - Availability Zone 1
10.0.2.0/24  - Availability Zone 2
```

The Application Load Balancer is deployed across the public subnets.

The NAT Gateway is deployed in one of the public subnets to provide outbound internet access for private resources.

### Private Subnets

```text
10.0.11.0/24 - Availability Zone 1
10.0.12.0/24 - Availability Zone 2
```

The Nginx and Node.js EC2 instances are deployed in these subnets.

The instances do not have public IP addresses.

### Database Subnets

```text
10.0.21.0/24 - Availability Zone 1
10.0.22.0/24 - Availability Zone 2
```

The RDS PostgreSQL database uses these isolated subnets.

The database subnets do not have a direct route to the internet.

## Traffic Flow

Application traffic follows this path:

```text
Internet
   |
   v
Application Load Balancer
   |
   | Port 80
   v
Nginx Web Tier
   |
   | Port 3000
   v
Node.js Application Tier
   |
   | Port 5432
   v
PostgreSQL Database
```

Private EC2 instances use the NAT Gateway for required outbound internet access.

## Security Design

Each tier has its own security group.

| Source   | Destination | Port | Purpose    |
| -------- | ----------- | ---: | ---------- |
| Internet | ALB         |   80 | HTTP       |
| ALB      | Web Tier    |   80 | Nginx      |
| Web Tier | App Tier    | 3000 | Node.js    |
| App Tier | Database    | 5432 | PostgreSQL |

The web, application, and database servers are not directly exposed to the internet.

The database accepts PostgreSQL traffic only from the application security group.

See [`security-design.md`](./security-design.md) for the detailed security design.

## Database Credentials

Database credentials are generated using Terraform and stored in AWS Secrets Manager.

The database password is not hardcoded in the Terraform configuration.

Terraform state files are excluded from Git using `.gitignore` because Terraform state can contain sensitive information.

## High Availability

The architecture uses two Availability Zones.

* ALB spans two public subnets.
* Nginx runs on two EC2 instances across two Availability Zones.
* Node.js runs on two EC2 instances across two Availability Zones.
* RDS PostgreSQL is configured with Multi-AZ.
* Database subnets exist in both Availability Zones.

## Infrastructure as Code

Terraform is used to provision and manage the AWS infrastructure.

### Terraform Structure

```text
terraform/
├── provider.tf
├── variables.tf
├── networking.tf
├── security-groups.tf
├── alb.tf
├── ec2.tf
├── rds.tf
└── outputs.tf
```

## Terraform Variables

The configuration uses variables for:

* AWS region
* Environment
* Project name
* EC2 instance type
* RDS instance class
* EC2 key pair

Default AWS region:

```text
us-east-1
```

Default EC2 instance type:

```text
t3.micro
```

Default RDS instance class:

```text
db.t3.micro
```

## Deployment

Clone the repository:

```bash
git clone https://github.com/ChideraA080/aws-three-tier-architecture.git
cd aws-three-tier-architecture/terraform
```

Initialize Terraform:

```bash
terraform init
```

Format the Terraform files:

```bash
terraform fmt
```

Validate the configuration:

```bash
terraform validate
```

Review the infrastructure plan:

```bash
terraform plan
```

Deploy the infrastructure:

```bash
terraform apply
```

View the Application Load Balancer DNS name:

```bash
terraform output alb_dns_name
```

Test the application:

```bash
curl http://$(terraform output -raw alb_dns_name)
```

## Verification

The infrastructure deployment completed successfully with Terraform.

The expected application flow is:

```text
Internet
   ↓
ALB
   ↓
Nginx
   ↓
Node.js
   ↓
RDS PostgreSQL
```

The ALB is the only public entry point. The EC2 web and application servers remain in private subnets.

## Project Documentation

* [`architecture-diagram.md`](./architecture-diagram.md) - Architecture and network layout
* [`security-design.md`](./security-design.md) - Security controls, ports, credentials, encryption, and least privilege
* [`terraform/`](./terraform/) - Terraform infrastructure configuration

## Cleanup

AWS resources can incur charges while running.

After completing testing and submission, destroy the infrastructure when it is no longer required:

```bash
cd terraform
terraform destroy
```

Confirm the destruction when Terraform asks for confirmation.

## Technologies Used

* AWS
* Terraform
* Amazon VPC
* EC2
* Application Load Balancer
* NAT Gateway
* Amazon RDS PostgreSQL
* AWS Secrets Manager
* Nginx
* Node.js
* Linux
* Git & GitHub
