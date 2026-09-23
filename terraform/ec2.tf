# Latest Ubuntu Server 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# -------------------------
# Web Tier - Nginx
# -------------------------

resource "aws_instance" "web" {
  count = 2

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private[count.index].id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.key_pair_name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              systemctl enable nginx
              systemctl start nginx
              EOF

  tags = {
    Name        = "${var.project_name}-web-${count.index + 1}"
    Environment = var.environment
    Tier        = "web"
  }
}

# -------------------------
# Application Tier - Node.js
# -------------------------

resource "aws_instance" "app" {
  count = 2

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private[count.index].id
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name               = var.key_pair_name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nodejs npm
              EOF

  tags = {
    Name        = "${var.project_name}-app-${count.index + 1}"
    Environment = var.environment
    Tier        = "application"
  }
}