# About

The bootstrap terraform scripts are responsible for bootstrapping a new set of AWS subaccounts by creating the terraform state S3 bucket and DynamoDB lock table.  Bootstrap cannot store its state in the S3 bucket since it is responsible for creating the S3 bucket.  Because of this the terraform state must be stored in the git repository.  There are two environment where the bootstrap is deployed, the ALM and sandbox.  The state files are stored at `terraform.tfstate.d/{environment}/terraform.tfstate`.

# Initializing the workspace for an environment

In order to utilize the state file in the repo for a workspace, the workspace can be initialized in the following way
```
terraform workspace new -state terraform.tfstate.d/standbox/terraform.tfstate sandbox
terraform workspace use sandbox
```
Now all terraform command run in the sandbox workspace will manipulate the sandbox statefile

# Managing credentials

Each file in `variables/*.tfvars` declares a variable called `credentials_profile` which references a profile that should be defined defined in `~/.aws/credentials`.  To make life easier, a credentials profile called `sandbox` with admin access to scos-sandbox should be defined in your aws credentials file when trying to manipulate the sandbox state bucket, and a profile called `jenkins` with admin access to scos-alm when manipulating the ALM bucket.

# Recovering a broken or missing state file

If the tfstate file for the environment you're trying to manipulate appears to be broken or missing, the existing bucket and lock table can easily be imported into the tfstate file.  First, make sure you have your workspace and credentials setup correctly, then you can import the S3 bucket and DynamoDB table by executing the following

```
# example for importing sandbox tfstate from the real world
terraform import -var-file variables/sandbox.tfvars aws_s3_bucket.terraform-state scos-sandbox-terraform-state
terraform import -var-file variables/sandbox.tfvars aws_dynamodb_table.dynamodb-terraform-state-lock terraform_lock
```

If those complete successfully be sure to commit the new state file to make sure this doesn't have to be done again, and run a plan and apply to get everything up to date.