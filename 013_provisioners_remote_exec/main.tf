terraform {
  /*
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "terraform-vikram"

    workspaces {
      name = "provisioners"
    }
  }
  */
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.15.0"
    }
  }
}

resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "MyServer security group"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
    self = false },
    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
    self = false }
  ]
  egress = [
    {
      description      = "outgoing traffict"
      to_port          = 0
      from_port        = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

data "aws_vpc" "main" {
  id = "vpc-01f862d7a7598b9e1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUoukShYVoFc0eOCBBMjAY0hemQSt5Jt+oVvjSb0PChn45msNnuhchso+TM0Skfi9RUdVMbQl5KIiNVRA9oqY6doElNTwl9MNpKi75ZWHjel4VbJimSiU6q4kVCAnm8U4gMzcCytuuOe2qduEQf4ltWYX3vS4DhZm8m4Gatn3IPdSTU+e1EsVN36NWCyBt+wadZp3qZVqAnOuUKsTmEsZO8QFWbjeK3RO5Ozo+YvLCf27DL6GbrEf+gqBA1sXgkBMDXwFZ5ExuVpJMXjpNoPGzeHqDLNBrMViYLEcSUzRjUwdVv7PMUxHORRlI7DM1dIO8plGdTnzhCauOawRbuzWqNmPE7PquvrvT0JcfDJFSVTNW+OFhD84+fV5KwTz5GxPUzAzloK5KL+2lhpf9ZL1k5dTP1QeBTzwb/8IowGpZ8zELazafik/XYeb5FsOHc+2SWQ4RVhMgPaKm2UPxYLN7onlA8j408G4dk471q31iQnRTcuU4v4YgzO6lCrT3bus= vikram@vikrams-MacBook-Air.local"
}

resource "aws_instance" "my_server" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg_my_server.id]
  user_data              = templatefile("${path.module}/userdata.yaml", {})

  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ip.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${self.private_ip} >> /home/ubuntu/private_ip.txt"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file("/Users/vikram/.ssh/terraform")
    }
  }
  tags = {
    "Name" = "Myserver"
  }
}

provider "aws" {
  region = "us-east-1"
}

output "public_ip" {
  value = aws_instance.my_server.public_ip
}
