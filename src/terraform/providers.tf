terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.37.1"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

terraform {
  backend "s3" {
    bucket = "tf-statefile-19999"
    key    = "dev/eks-cluster/terraform.tfstate"
    region = "eu-north-1"
  }
}