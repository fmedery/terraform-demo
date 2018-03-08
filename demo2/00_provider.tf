# Configuration des IAAS
# AWS
provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

# Azure
provider "azurerm" {
  client_id       = "${var.azure_client_id}"
  client_secret   = "${var.azure_client_secret}"
  tenant_id       = "${var.azure_tenant_id}"
  subscription_id = "${var.azure_subscription_id}"
}

# variables

variable "aws_profile" {}
variable "aws_region" {}
variable "ssh_public_key" {}
variable "dns_zone" {}
variable "rg" {}
variable "nbr" {}
variable "resource_group_name" {}
variable "ssh_key_name" {}
variable "aws_bastion_host" {}
variable "aws_bastion_port" {}
variable "aws_bastion_user" {}
variable "aws_bastion_private_key" {}
variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_tenant_id" {}
variable "azure_subscription_id" {}
