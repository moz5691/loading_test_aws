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
