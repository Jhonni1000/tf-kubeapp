variable "vpc_name" {
    type = string
    description = "VPC name for EKS"
    default = "eks-vpc"
}

variable "vpc_cidr_block" {
    type = string
    description = "VPC CIDR block"
    default = "10.0.0.0/16"
}