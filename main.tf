provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Route Table Association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance-sg"
  }
}

# Amazon Linux Instance
# Amazon Linux Instance
resource "aws_instance" "amazon_linux_vm" {
  ami                         = var.ami_amazon_linux
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true

   user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname c8.local
              EOF


  tags = {
    Name = "c8.local"
  }
}


# Ubuntu Instance
resource "aws_instance" "ubuntu_vm" {
  ami                         = var.ami_ubuntu
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true

 user_data = <<-EOF
            #!/bin/bash
            set -e

            hostnamectl set-hostname c8.local

            # Install Python 3.8
            amazon-linux-extras enable python3.8 -y
            yum clean metadata
            yum install -y python3.8 python3-pip

            # Create symlink
            alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2

            # Ensure SSH is enabled
            systemctl enable sshd
            systemctl start sshd
EOF

  tags = {
    Name = "u21.local"
  }
}

# Generate Ansible Hosts File
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/hosts"

  content = <<-EOT
    [frontend]
    c8.local ansible_host=${aws_instance.amazon_linux_vm.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=/root/.jenkins/jenkins.pem

    [backend]
    u21.local ansible_host=${aws_instance.ubuntu_vm.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/root/.jenkins/jenkins.pem
  EOT
}
