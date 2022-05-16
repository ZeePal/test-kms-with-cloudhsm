data "aws_region" "current" {}

# Create a vpc dedicated to this testing
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.12"

  name = "test-kms-with-cloudhsm"
  cidr = "10.0.0.0/16"

  azs = [
    "${data.aws_region.current.name}a",
    "${data.aws_region.current.name}b"
  ]

  enable_nat_gateway = false
  single_nat_gateway = false
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.10.0/24", "10.0.20.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true
}
