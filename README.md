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

## DNS root zone resolution

Due to TLS certificates requiring DNS validation there is a manual step needed when creating a dev/staging/prod environment for the first time.  Terraform will create the route53 zone and provide the nameserver records that need to be manually updated/added to the domain registration.  This can be done while terraform is trying to validate the certificate as the default timeout is 45 minutes.  Once added it takes a few minutes for it to being resolving correctly.

This does not need performed in sandbox as there is logic in sandbox to utilize the *.internal dns zones, based on the is_sandbox variable.

The following steps are used to update name servers:

1. Log into AWS console with an account that has ALM administrator privleges
2. Navidate to Route53 Registered Domains - https://console.aws.amazon.com/route53/home#DomainListing:
3. Click on the appropriate domain
4. In the top right, click "Add or edit name servers" and add the nameservers that are in the NS record of the appropriate route53 zone

## Selecting a workspace

Terraform workspaces are stored in the state S3 bucket.  A workspace name can be set to any name to deploy a set of resources without affecting any other resources inside of terraform.  In the sandbox VPC, a workspace named `sandbox` is likely already availible.

```
terraform workspace new foo-workspace # create a new workspace if it doesn't already exist
terraform workspace use foo-workspace

```

### Deploying or Updating

Note: many of the terraform deployments include configuring ec2 instances via ssh after they are deployed. In order for remote configuration to succeed, the cloud key needs to be in an ssh agent attached to the current session.  In OSX an ssh agent may be initialized on your terminal by default.

```bash
eval "$(ssh-agent)"

ssh-add ~/.ssh/cloud_key_id_rsa
```

#### Shared Sandbox

```bash
terraform plan -out sandbox.plan -var-file variables/sandbox.tfvars

terraform apply sandbox.plan
```

#### Isolated Sandbox (env only)

Until we can automate this, here are the minimal things (without renaming/adding resources, etc.) you need to do to make your own env. Note that the `vpc_cidr` and `vpc_*_subnets` need to match up.

```bash
cd env
tf-init --sandbox -w my-own-personal-sandbox
terraform plan \
  --var-file=variables/sandbox.tfvars \
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
