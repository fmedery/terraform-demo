## AWS account where the infra will be build
provider "aws" {
  profile = "perso"
  region  = "ca-central-1"
}

## AWS account where the route 53 DNS zone is hosted
provider "azurerm" {}

# resource "azurerm_resource_group" "resource_group" {
#   name = "terraform"
#   location = "Canada East"
# }

variable "resource_group_name" {
  default = "terraform-demo"
}

## AWS account where the route 53 DNS zone is hosted
provider "azurerm" {}

variable "rg" {
  default = "fmedery-poc"
}

# variable "nbr" {}

data "azurerm_subnet" "subnet" {
  name                 = "default"
  virtual_network_name = "fmedery-poc-vnet"
  resource_group_name  = "${var.rg}"
}

variable "nbr" {}
