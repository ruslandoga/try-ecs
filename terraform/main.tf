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
  region = "eu-north-1"
}

provider "aws" {
  alias  = "asia"
  region = "ap-southeast-1"
}

provider "aws" {
  alias  = "us"
  region = "us-west-1"
}
