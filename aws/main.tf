terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
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
	owners = ["099720109477"] 
	filter {
		name = "name"
		values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22*"]	
	}

}

resource "aws_instance" "test-server" {
	ami = data.aws_ami.name.id
	instance_type = "t2.micro"

	tags =  {
		Name =  "test-server"
	}
}
