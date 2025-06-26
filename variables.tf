variable "region" {
  description = "AWS region to deploy instances"
  default     = "us-east-1"
}

variable "key_name" {
  description = "EC2 Key Pair Name"
  default     = "jenkins"
}

variable "security_group_id" {
  description = "Security Group ID"
  default     = "sg-0d7f8155c7d09c24d"
}

variable "ami_amazon_linux" {
  description = "Amazon Linux 2 AMI ID"
  default     = "ami-0f3f13f145e66a0a3"
}

variable "ami_ubuntu" {
  description = "Ubuntu 24.04 AMI ID"
  default     = "ami-020cba7c55df1f615"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}
