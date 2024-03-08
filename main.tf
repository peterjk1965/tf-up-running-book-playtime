terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
#SET tHE REGION
provider "aws" {
  region = "us-east-2"  
}

#CREATE EC2 Instance
resource "aws_instance" "example" {
  ami                    = "ami-0f5daaa3a7fb3378b"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]#tell instance to use security group

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello World!" > index.html
              nohup busybox httpd -f -p ${var.server_port} & #use variable for port
              EOF
  tags = {
    Name = "terraform-example"
  }
}
#CREATE SECURITY GROUP
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.server_port #use variable for port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["69.136.168.38/32"]
  }
}
#CREATE VARIABLE FOR PORTS
variable "server_port" {
  description = "Port used for http requests"
  type        = number
  default     = 8080
}
#OUTPUT THE PUBLIC IP
output "public_ip" {
  value        = aws_instance.example.public_ip #get the instance public ip
  description  = "Public ip address"
}