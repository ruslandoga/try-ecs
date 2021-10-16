terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-north-1"
}

variable "docker_image" {
  type    = string
  default = "ruslandoga/test-ecs:02525f71b1e6a8ce0bde7948fabda6da3bd1021b"
}

data "aws_caller_identity" "current" {}
