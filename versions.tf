terraform {
  required_version = ">= 1.0.0"

  required_providers {
    ssh = {
      source = "loafoe/ssh"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}