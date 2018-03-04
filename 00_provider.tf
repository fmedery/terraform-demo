provider "aws" {
  profile = "perso"
  region  = "ca-central-1"
}

provider "azurerm" {}

variable "rg" {
  default = "fmedery-poc"
}

variable "nbr" {}
variable "ssh_public_key" {}
variable "ssh_key_name" {}
variable "resource_group_name" {}
