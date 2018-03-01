## AWS account where the infra will be build
provider "aws" {
  alias   = "aws"
  profile = "perso"
  region  = "ca-central-1"
}

## AWS account where the route 53 DNS zone is hosted
provider "azurerm" {}

resource "azurerm_resource_group" "resource_group" {
  name = "terraform"
  location = "Canada East"
}

















# variable "env" {}
# variable "nbr" {}
# variable "instance" {}

/*
## command for demo
watch awless --aws-profile=localdev --aws-region=us-west-2  list instances --filter name=demo,state=running --sort name

## QA
terraform plan -var 'nbr=2' -var 'env=qa' -var 'instance=t2.large' -state qa/terraform.tfstate
terraform apply -var 'nbr=2' -var 'env=qa' -var 'instance=t2.large' -state qa/terraform.tfstate

terraform plan -var 'nbr=10' -var 'env=qa' -var 'instance=t2.large' -state qa/terraform.tfstate
terraform apply -var 'nbr=10' -var 'env=qa' -var 'instance=t2.large' -state qa/terraform.tfstate


terraform destroy  -var 'nbr=2' -var 'env=qa' -var 'instance=t2.large'  -state qa/terraform.tfstate


## PROD


<<<<<<< HEAD:localdev/devops/demo-fmedery/00_definition.tf
terraform plan -var 'nbr=10' -var 'env=prod' -var 'instance=t2.large' -state prod/terraform.tfstate
terraform apply -var 'nbr=10' -var 'env=prod' -var 'instance=t2.large' -state prod/terraform.tfstate
=======
terraform apply -var 'nbr=10' -var 'instance=t2.large'
>>>>>>> 93bc5869c8ba9c06b7e5b0371054524be1ea967b:localdev/devops/demo-fmedery/qa/00_definition.tf


terraform destroy -state prod/terraform.tfstate


*/
