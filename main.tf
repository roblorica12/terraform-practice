terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "terraform-practice"
}

variable "bucket_name" {
  default = "rob-terraform-practice-2026"
}

resource "aws_s3_bucket" "my_first_bucket" {
  bucket = var.bucket_name
}