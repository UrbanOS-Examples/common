## Repository with common libraries, common infrastructure code etc.

At this point it contains Terraform code for setting up a VPC along with subnets, NAT gateways and so on.

### VPC Setup
This repository contains Terraform code to setup VPC's consistently across environments. This repository will be monitored by the Continuous Delivery Pipeline and it will apply the changes automatically. Until the Delivery Pipeline is deployed, a VPC can be setup manually by executing the following commands:

```
cd src\terraform\aws\vpc
# if this is the first time running Terraform initialize it first
terraform init
terraform workspace select ENVIRONMENT_NAME
#to see what changes will be applied
terraform plan -var-file=variables/ENVIRONMENT_NAME.tfvars
#to apply the changes
terraform apply -var-file=variables/ENVIRONMENT_NAME.tfvars
```

To simplify these commands, there is a wrapper script in tf.sh that takes a valid workspace name as the first parameter followed by whatever parameters need to be passed to Terraform itself. Using this script the above commands become:

```
cd src\terraform\aws\vpc
# if this is the first time running Terraform initialize it first
terraform init
../../../../tf.sh ENVIRONMENT_NAME plan
../../../../tf.sh ENVIRONMENT_NAME apply
```

The Terraform code creates the following resources in AWS:
* a VPC that has the name specified in the tfvars file
* public, private and protected subnet in each availability zone. The subnets were setup following recommendations from the following papers: [Practical VPC Design]( https://medium.com/aws-activate-startup-blog/practical-vpc-design-8412e1a18dcc) and [Building a Modular and Scalable Virtual Network Architecture with Amazon VPC](https://docs.aws.amazon.com/quickstart/latest/vpc/architecture.html)
* Associated Routing tables for each of the subnets. The public subnet is associated with an internet Gateway while the private and protected subnets are associated with NAT Gateways
* Ability to create a single NAT gateway for the entire VPC or a NAT Gateway per Availability Zone. Creating a NAT Gateway per Availability Zone ensures High Availability but is more expensive to run (around $400/NAT Gateway instance). It is recommended to only use multiple NAT Gateways in Production.
* VPN Gateway that is attached to the VPC
* S3 and DynamoDB endpoints that are attached to each subnet routing table. This ensures that traffic to S3 and DynamoDB stays within Amazon network vs going out on the Internet.

### Composable Terraform state

Terraform needs to keep track of its state in order to provision the environment. The following article provides details why State is important  https://www.terraform.io/docs/state/purpose.html

Smart Columbus Operating System consists of multiple components and some of these components need to be reused across projects. For example a Microservice will be rebuilt from scratch every time, but Kafka or a VPC need to be reused across projects. In fact destroying Kafka or the VPC and recreating it every time a micro-service is deployed will have very bad consequences.

In order to create composable and maintainable Terraform state we need to consider the following aspects:
* simple way of only changing what is specific to a given environment. For example when deploying a micro-service we want a small instance in Staging and a large in Production. Everything else is the same.
* ability to refer to pre-existing resources. For example we need to be able to say spin up an EC2 instance in the private subnet for each Availability Zone.

The first problem can be solved by extracting the differences between environments in its own variables files. Using the VPC as an example we have a variables directory and for each of the supported environments we have a tfvars file. The state for each environment is stored in its own workspace.

The second problem can be solved by using Terraform remote state. If a component needs data from another component, it needs to declare the dependency as a remote state.

In addition in order to persist the state and share it across environments, projects and developers we need to use a remote backend. Initially we are going to use S3 as a remote backend. All environments will use the same bucket and will have a structure similar with the following:

* Terraform state
  * VPC
    * Management
    * Development
    * Sandbox
    * Staging
    * Production
  * CI/CD Pipeline
    * Management
  * Kafka
    * Development
    * Staging
    * Production
  * Microservice x
    * Development
    * Staging
    * Production
