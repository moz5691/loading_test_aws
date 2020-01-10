variable "env_name" {
  default = "locust"
}

variable "region" {
  description = "The region to apply these templates to (e.g. us-east-1)"
  default     = "us-east-1"
}

variable "number_of_workers" {
  description = "Number of worker nodes"
  default = 3
}

variable "worker_instance_type" {
  default = "t2.micro"
}

variable "master_instance_type" {
  default = "t2.micro"
}

variable "ami" {
  default = "ami-00eb20669e0990cb4"
}

variable "locust_command" {
  default = "/usr/local/bin/locust -f /home/ec2-user/locustfile.py --host=http://example.com"
}