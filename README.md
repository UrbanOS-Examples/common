# The Terraform Scripts


A collection of terraform scripts to be run by the continuous integration/continuous delivery mechanism to deploy, maintain, and update the various environments in the Smart Columbus Operating System.  These scripts can be run by developers in a Sandbox subaccount to prove out new scripts before entrusting them to automated deployment.

## Running Terraform

The following is a series of shell snippets for running terraform scripts in the sandbox environment.  The snippets assume that the working directory is one of the config directories, not the root of this repository.
<<<<<<< Updated upstream

### Initializing

On first use of a set of terraform scripts, terraform must first be initialized so that plugins and modules can be fetched, and the S3 backend can be configured.  The Terraform scripts are configured to reference the `sandbox` profile by default, but Terraform does not recognize the AWS profile configuration on initialization.  Once Terraform is initialized, the `AWS_PROFILE` environment variable becomes redundant

```bash
export AWS_PROFILE=sandbox
terraform init
```

## Selecting a workspace

Terraform workspaces are stored in the state S3 bucket.  A workspace name can be set to any name to deploy a set of resources without affecting any other resources inside of terraform.  In the sandbox VPC, a workspace named `sandbox` is likely already availible.

```
terraform workspace new foo-workspace # create a new workspace if it doesn't already exist
terraform workspace use foo-workspace

```

### Deploying or Updating

```bash
terraform plan -out sandbox.plan -var-file variables/sandbox.tfvars

terraform apply sandbox.plan
```

### Destroying

```bash
terraform plan -out sandbox.plan -var-file variables/sandbox.tfvars -destroy

terraform apply sandbox.plan
```

## The Configs

- [Bootstrap](bootstrap/README.md) - bootstrap scripts for creating the Terraform state S3 bucket and DynamoDB table
- [ALM](alm/README.md) - deploy and configure an Application Lifecycle Management VPC
- [Nexus](nexus/README.md) (WIP) - deploy and configure a Nexus in an ALM VPC
- [Users](users/README.md) - create users and assign roles in the various AWS subaccounts