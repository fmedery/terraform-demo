## AWS account where the infra will be build
provider "aws" {
  profile = "perso"
  region  = "ca-central-1"
}

## AWS account where the route 53 DNS zone is hosted
# provider "azurerm" {}

# resource "azurerm_resource_group" "resource_group" {
#   name = "terraform"
#   location = "Canada East"
# }

variable "resource_group_name" {
  default = "terraform-demo"
}

variable "nbr" {}
