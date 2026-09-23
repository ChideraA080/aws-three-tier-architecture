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

              cat > /etc/nginx/sites-available/default <<'NGINX'
              server {
                  listen 80 default_server;
                  listen [::]:80 default_server;

                  location / {
                      proxy_pass http://${aws_instance.app[count.index].private_ip}:3000;
                      proxy_http_version 1.1;
                      proxy_set_header Host $host;
                      proxy_set_header X-Real-IP $remote_addr;
                      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                      proxy_set_header X-Forwarded-Proto $scheme;
                  }
              }
              NGINX

              systemctl enable nginx
              systemctl restart nginx
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

              mkdir -p /opt/app

              cat > /opt/app/server.js <<'NODE'
              const http = require('http');

              const server = http.createServer((req, res) => {
                res.writeHead(200, {'Content-Type': 'text/plain'});
                res.end('Node.js application server is running');
              });

              server.listen(3000, '0.0.0.0', () => {
                console.log('Node.js server running on port 3000');
              });
              NODE

              cat > /etc/systemd/system/node-app.service <<'SERVICE'
              [Unit]
              Description=Node.js Application
              After=network.target

              [Service]
              ExecStart=/usr/bin/node /opt/app/server.js
              Restart=always
              User=root
              WorkingDirectory=/opt/app

              [Install]
              WantedBy=multi-user.target
              SERVICE

              systemctl daemon-reload
              systemctl enable node-app
              systemctl start node-app
              EOF

  tags = {
    Name        = "${var.project_name}-app-${count.index + 1}"
    Environment = var.environment
    Tier        = "application"
  }
}