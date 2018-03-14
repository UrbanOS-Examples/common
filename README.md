### Repository with common stuff such as common libraries, common infrastructure code etc.

At this point it contains Terraform code for things that do not need to be created multiple times.
Examples are: VPC, subnets and routing tables.

TODO
* Research the following:
    * Use S3 to share state remotely. It needs to be encrypted and to support locking. To support this it needs to have both the S3 bucket and a DynamoDB table defined. In addition Bucket Versioning needs to be enabled. More info can be found at https://www.terraform.io/docs/backends/types/s3.html
    * Using workspaces to isolate changes across environments https://www.terraform.io/docs/state/workspaces.html
    * Using remote state as a mechanism of sharing data between modules
* Define the following:
  * VPC
  * subnets
  * Routing tables
* Write tests with inspec. What am I going to test exactly? One thing I know is I don't want mirror tests i.e. test that simply repeat what the code is saying. I've seen plenty of those and those provide negative value.
* Define directory structure. I am not very thrilled with the structure I defined so far.
* What are good practices for sharing remote state in a team? Only Jenkins should update/changes stuff
* How are we going to handle terraform scripts that span environments? E.g. we have a script that is using shared remote state but is making changes to staging.
* At what stage to I need to introduce Vault/Consul for secrets management?
