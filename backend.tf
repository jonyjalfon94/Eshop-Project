terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 0.13"
  
  backend "s3" {
    bucket = "eshop-backend-bucket2"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
