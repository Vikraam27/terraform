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
  instance_type = "t2.micro"
}

resource "aws_s3_bucket" "bukcet" {
  bucket     = "294309j508u0k-depends-on"
  depends_on = [aws_instance.my_server]
}

output "public_ip" {
  value = aws_instance.my_server.public_ip
}
