terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

data "aws_ami" "name" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22*"]
  }

}

resource "aws_instance" "test-server" {
  ami                    = data.aws_ami.name.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  count                  = 2

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World 3" > index.html
              nohup python3 -m http.server 8080 &
              EOF

  tags = {
    Name = "test-server"
  }
}

resource "aws_security_group" "security_group" {
  name = "security-group"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_launch_configuration" "launch_configuration" {
  instance_type   = "t2.micro"
  image_id        = data.aws_ami.name.id
  security_groups = [aws_security_group.security_group.id]

}

variable "server_port" {
  description = "Port for security group"
  default     = 8080
  type        = number

}

output "public_ip_1" {
  value = aws_instance.test-server[0].public_ip
}

output "public_ip_2" {
  value = aws_instance.test-server[1].public_ip
}
