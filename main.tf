terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
    backend "s3" {
    bucket = "rob-terraform-state-2026"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = "us-east-1"
}

variable "bucket_name" {
  default = "rob-terraform-practice-2026"
}

resource "aws_s3_bucket" "my_first_bucket" {
  bucket = var.bucket_name
}