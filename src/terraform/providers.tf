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

data "aws_eks_cluster_auth" "my_cluster" {
  name = aws_eks_cluster.eks_dev_cluster.name
}

provider "kubernetes" {
  host = aws_eks_cluster.eks_dev_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_dev_cluster.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.my_cluster.token
}

terraform {
  backend "s3" {
    bucket = "tf-statefile-19999"
    key    = "dev/eks-cluster/terraform.tfstate"
    region = "eu-north-1"
  }
}