# AWS Three-Tier Architecture

## Architecture Overview

The application is deployed in one AWS VPC across two Availability Zones.

```text
                         INTERNET
                             |
                             v
                  +----------------------+
                  | Application Load     |
                  | Balancer (ALB)       |
                  | HTTP/HTTPS            |
                  +----------+-----------+
                             |
              +--------------+--------------+
              |                             |
              v                             v
       PUBLIC SUBNET AZ-1           PUBLIC SUBNET AZ-2
              |                             |
           NAT GW                         ALB
              |                             
              +--------------+--------------+
                             |
                             v
                  PRIVATE SUBNETS
              +--------------------------+
              |                          |
              |   WEB TIER - NGINX       |
              |                          |
              |  Nginx EC2 - AZ-1        |
              |  Nginx EC2 - AZ-2        |
              +------------+-------------+
                           |
                           | Port 3000
                           v
                  APPLICATION TIER
              +--------------------------+
              |                          |
              |  Node.js EC2 - AZ-1      |
              |  Node.js EC2 - AZ-2      |
              |                          |
              +------------+-------------+
                           |
                           | Port 5432
                           v
                  DATABASE SUBNETS
                    (ISOLATED)
              +--------------------------+
              |                          |
              |   RDS PostgreSQL         |
              |   Multi-AZ enabled       |
              |                          |
              +--------------------------+

Private EC2 outbound traffic:

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


Network Structure
VPC
CIDR: 10.0.0.0/16
Two Availability Zones
Public Subnets
10.0.1.0/24 - AZ-1
10.0.2.0/24 - AZ-2
Used by the Application Load Balancer
NAT Gateway is deployed in a public subnet
Private Subnets
10.0.11.0/24 - AZ-1
10.0.12.0/24 - AZ-2
Used by Nginx and Node.js EC2 instances
No direct inbound internet access
Database Subnets
10.0.21.0/24 - AZ-1
10.0.22.0/24 - AZ-2
Used by RDS PostgreSQL
No direct internet route
Traffic Flow
Internet
   |
   v
ALB
   |
   | HTTP :80
   v
Nginx Web Tier
   |
   | TCP :3000
   v
Node.js Application Tier
   |
   | TCP :5432
   v
RDS PostgreSQL
High Availability

The architecture is distributed across two Availability Zones.

The ALB is deployed across both public subnets.

Nginx and Node.js servers are deployed across the private subnets.

RDS PostgreSQL uses Multi-AZ deployment.

Security Boundaries

Each tier has its own security group:

ALB-SG
WEB-SG
APP-SG
DB-SG

Traffic is restricted between tiers using security-group rules.
