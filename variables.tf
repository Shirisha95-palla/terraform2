variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  default = "jenkins"
}

variable "ami_amazon_linux" {
  default = "ami-0f3f13f145e66a0a3" # Amazon Linux 2023
}

variable "ami_ubuntu" {
  default = "ami-020cba7c55df1f615" # Ubuntu 24.04
}

variable "instance_type" {
  default = "t2.micro"
}

variable "pem_path" {
  description = "Absolute path to the private key file used for SSH"
  type        = string
  default     = "/var/lib/jenkins/jenkins.pem"
}
