module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = var.vpc_name
    cidr = var.vpc_cidr_block

    azs = ["eu-north-1a", "eu-north-1b"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

    enable_nat_gateway = true

    tags = {
        Environment = "dev"
        Managed_by = "OPAKI"
    }
}