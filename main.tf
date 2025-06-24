provider "aws" {
  region = var.region
}

resource "aws_instance" "amazon_linux_vm" {
  ami                    = var.ami_amazon_linux
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = "c8.local"
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname c8.local
              EOF
}

resource "aws_instance" "ubuntu_vm" {
  ami                    = var.ami_ubuntu
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = "u21.local"
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname u21.local
              EOF
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/hosts"

  content = <<-EOT
    [frontend]
    c8.local ansible_host=${aws_instance.amazon_linux_vm.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=/var/lib/jenkins/jenkins.pem

    [backend]
    u21.local ansible_host=${aws_instance.ubuntu_vm.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/var/lib/jenkins/jenkins.pem
  EOT
}
