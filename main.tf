module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name               = var.env_name
  cidr               = "10.0.0.0/16"
  azs                = ["us-east-1a", "us-east-1b"]
  public_subnets     = ["10.0.101.0/24"]
  enable_dns_support = true
}

module "nodes" {
  source               = "./tfmodules/nodes"
  name                 = var.env_name
  subnet_id            = element(module.vpc.public_subnets, 0)
  vpc_id               = module.vpc.vpc_id
  worker_instance_type = var.worker_instance_type
  master_instance_type = var.master_instance_type
  ami                  = var.ami
  locust_command       = var.locust_command
  number_of_workers    = var.number_of_workers
}
