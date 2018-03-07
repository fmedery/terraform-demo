# provider "aws" {
#   profile = "${var.aws_profile}"
#   region  = "${var.aws_region}"
# }
#
# provider "azurerm" {}
#
# variable "rg" {}
# variable "aws_profile" {}
# variable "aws_region" {}
# variable "nbr" {}
# variable "ssh_public_key" {}
# variable "ssh_key_name" {}
# variable "resource_group_name" {}
# variable "dns_zone" {}
#
#
# provider "aws" {
#   profile = "${var.aws_profile}"
#   region  = "${var.aws_region}"
# }

provider "azurerm" {
  client_id       = "${var.azure_client_id}"
  client_secret   = "${var.azure_client_secret}"
  tenant_id       = "${var.azure_tenant_id}"
  subscription_id = "${var.azure_subscription_id}"
}

variable "aws_profile" {}
variable "aws_region" {}
variable "ssh_public_key" {}
variable "dns_zone" {}
variable "rg" {}
variable "nbr" {}

variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_tenant_id" {}
variable "azure_subscription_id" {}
