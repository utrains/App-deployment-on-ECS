
# ~~~~~~~~~~~~~~~~ Configure the Network ~~~~~~~~~~~~~~~~~~~~~ 
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name             = var.project_name
  cidr             = var.VPC_cidr
  azs              = ["${var.AZ1}", "${var.AZ2}"]
  private_subnets  = ["${var.subnet_priv1_cidr}", "${var.subnet_priv2_cidr}"]
  public_subnets   = ["${var.subnet_pub1_cidr}", "${var.subnet_pub2_cidr}"]

  # One NAT gateway per subnet and a single NAT for all of them
  enable_nat_gateway = true
  single_nat_gateway = true

  # Enable DNS support and hostnames in the VPC
  enable_dns_support   = true
  enable_dns_hostnames = true

  private_subnet_tags = {
    Tier = "Private"
  }
  public_subnet_tags = {
    Tier = "Public"
  }
  tags = {
    Project = "${var.project_name}"
  }
}
