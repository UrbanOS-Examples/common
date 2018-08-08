# The Terraform Scripts


A collection of terraform scripts to be run by the continuous integration/continuous delivery mechanism to deploy, maintain, and update the various environments in the Smart Columbus Operating System.  These scripts can be run by developers in a Sandbox subaccount to prove out new scripts before entrusting them to automated deployment.

## Running Terraform

The following is a series of shell snippets for running terraform scripts in the sandbox environment.  The snippets assume that the working directory is one of the config directories, not the root of this repository.

### Initializing

On first use of a set of terraform scripts, terraform must first be initialized so that plugins and modules can be fetched, and the S3 backend can be configured.  The Terraform scripts are configured to reference the `sandbox` profile by default, and Terraform should correctly recognize the AWS profile configuration on initialization.

Backend configurations are stored in the [backends](backends/) directory.
Use the `--backend-config` flag to specify the file path to the conf file.

```bash
cd env
terraform init --backend-config=../backends/sandbox-alm.conf
```

All projects share the same two backends: the one in sandbox-alm and the one in alm.

## Selecting a workspace

Terraform workspaces are stored in the state S3 bucket.  A workspace name can be set to any name to deploy a set of resources without affecting any other resources inside of terraform.  In the sandbox VPC, a workspace named `sandbox` is likely already availible.

```
terraform workspace new foo-workspace # create a new workspace if it doesn't already exist
terraform workspace use foo-workspace

```

### Deploying or Updating

#### Shared Sandbox
```bash
terraform plan -out sandbox.plan -var-file variables/sandbox.tfvars

terraform apply sandbox.plan
```

#### Isolated Sandbox (env only)
Until we can automate this, here are the minimal things (without renaming/adding resources, etc.) you need to do to make your own env. Note that the `vpc_cidr` and `vpc_*_subnets` need to match up.
```bash
cd env
terraform init --backend-config=backends/sandbox.conf
terraform workspace new my-own-personal-sandbox
terraform workspace select my-own-personal-sandbox
terraform plan \
  --var-file=variables/sandbox.tfvars \
  --var="vpc_cidr=" \
  --out=update.plan
terraform apply update.plan
```

### Destroying

```bash
terraform plan -out sandbox.plan -var-file variables/sandbox.tfvars -destroy

terraform apply sandbox.plan
```

## The Configs

- [Bootstrap](bootstrap/README.md) - bootstrap scripts for creating the Terraform state S3 bucket and DynamoDB table
- [ALM-durable](alm-durable/README.md) - Persistance for the ALM network: file systems, elastic container repositories, etc.
- [ALM](alm/README.md) - deploy and configure an Application Lifecycle Management VPC
- [Users](users/README.md) - create users and assign roles in the various AWS subaccounts
- [Env](env/README.md) - Deploys application environments

Some of these projects have implicit dependencies on others because we need to manage their lifecycles separately.
For example, the Jenkins file system has a longer lifespan than the ALM network.
We never want to delete that file system, so it is managed by a separate terraform state.

All projects rely on the Terraform state bucket and lock table being created first (Bootstrap).
Env has a dependency on ALM existing so that it can create the VPC peering our CI system needs to gain access to the system.

```

              +-------------+
              |             |
              |  Bootstrap  |
        +----->  (tf state) <-----+
        |     |             |     |
        |     +-------------+     |
        |                         |
+-------+------+                  |
|              |                  |
|  ALM-Durable |                  |
|              |                  |
+-------^------+                  |
        |                         |
        |                         |
+-------+------+          +-------+------+
|              |          |              |
|     ALM      <----------+     ENV      |
|              |          |              |
+--------------+          +--------------+

```
