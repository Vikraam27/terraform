terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "terraform-vikram"

    workspaces {
      name = "getting-started"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }
  }
}

locals {
  project_name = "Vikram"
}

