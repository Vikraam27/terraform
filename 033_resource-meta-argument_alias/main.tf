terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
provider "aws" {
  region = "us-west-1"
  alias = "west"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
resource "aws_instance" "my_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  tags = {
    Name = "Server-my"
  }
}

resource "aws_instance" "my_server-west" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  provider = aws.west
  tags = {
    Name = "Server-my"
  }
}
output "public_ip" {
  value = aws_instance.my_server[*].public_ip
}
