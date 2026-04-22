# Generate SSH key
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create key pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.key.public_key_openssh
}

# Store private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "${path.module}/deployer-key.pem"
  file_permission = "0600"
}

## Get most recent AMI for an ECS-optimized Amazon Linux 2 instance
data "aws_ami" "amazon_linux_2" {
  most_recent = true
 
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
 
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
 
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
 
  owners = ["amazon"]
}

  
# Create EC2 instance with Nginx
resource "aws_instance" "web" {
  ami             = data.aws_ami.amazon_linux_2.id
  instance_type   = var.ec2_instance_type
  security_groups = [aws_security_group.web.name]
  key_name        = aws_key_pair.deployer.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Install and configure Nginx
              yum update -y
              amazon-linux-extras install -y nginx1
              systemctl start nginx
              systemctl enable nginx
              
              # Create a simple webpage
              echo "<h1>Hello from Terraform and LocalStack!</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = var.ec2_instance_name
    Role = "web"
  }
}

# Create EC2 instance for database server
resource "aws_instance" "db" {
  ami             = data.aws_ami.amazon_linux_2.id
  instance_type   = var.ec2_instance_type
  security_groups = [aws_security_group.web.name]
  key_name        = aws_key_pair.deployer.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Install MariaDB server
              yum update -y
              yum install -y mariadb-server
              systemctl start mariadb
              systemctl enable mariadb
              EOF

  tags = {
    Name = var.db_instance_name
    Role = "database"
  }
}
