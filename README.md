This assignment can setup highly available AWS ECS environment in Singapore Region.Here we use simple FizzBuzz docker image which is publicly available.This ECS cluster has 2 instance with encrypted storage and it has autoscaling capability and load balancer will check the health of the ecs instance regularly.Cluster create two task in each instance.

Requirement:

* git

* Terraform

* AWS account with an access-key (user must have full ECS EC2 and IAM permission)

How to implement

* clone the repository

* move the the directory

* run terraform init

* run terraform apply

* provide access key details in the command line


Note:You can use tfvar file option in terraform to pass the values when it's creation time.

To See the output. use the Load Balancer DNS.




