### Locust Load Testing 

Usage
===

Before start:
* Edit the `locustfile.py`.  Refer https://locust.io for detail.
* Edit the configuration in `variables.tf`. 
* Run `terraform init` to initialize terraform environment.
* Run `terraform plan` to check the plan.
* Run `terraform apply` to deploy it on AWS.
* It should print out the addresses for Locust GUI and slave nodes, and PEM key for SSH to EC2 instances.
* Note that the same PEM key is shared for all EC2 instances (a master and slaves).

After you have finished:
* Stop any running tests.
* Run `terraform destroy`

Note
===

* SSH key pair is self generated when you start terraform 
and its key pair is stored (unencrypted) in your local memory.  This should be acceptable as this is intended for loading test in development environment. 
* If you see an error for duplicated SSH key pair error, you may change `env_name` in `variables.tf`. It is likely the same name of key-pair already exists in AWS.
* AMI type can be adjusted depending on the workload.  Recommend that master instance is bigger size than slave instances.
