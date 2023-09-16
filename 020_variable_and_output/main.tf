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

variable "instance_type" {
  type = string
  description = "The type of the instance"
  # it will be hide the while plan or apply
  sensitive = true
  validation {
    condition = can(regex("^t2.", var.instance_type))
    error_message = "the instance must be t2 type"
  }
}

resource "aws_instance" "my_server" {
  ami           = "ami-0a481e6d13af82399"
  instance_type = var.instance_type
}

output "public_ip" {
  value = aws_instance.my_server.public_ip
}
