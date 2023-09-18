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

resource "aws_instance" "my_server" {
  ami           = "ami-053b0d53c279acc90"
  for_each = {
    nano= "t2.nano",
    micro = "t2.micro",
    small = "t2.small"
  }
    instance_type = each.value

  tags = {
    Name = "Server-${each.key}"
  }
}


output "public_ip" {
  value = values(aws_instance.my_server)[*].public_ip
}
