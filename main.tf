# AWS provider -
provider "aws" {
  region = var.region
  shared_credentials_file = "$HOME/.aws/credentials"
  profile = "default"
}

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
  worker_instance_type = "t2.micro"
  ami                  = "ami-00eb20669e0990cb4"
  locust_command       = "/usr/local/bin/locust -f /home/ec2-user/locustfile.py --host=http://example.com"
  number_of_workers    = var.number_of_workers
}
