provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

variable "aws_profile" {}
variable "aws_region" {}
variable "nbr" {}
variable "ssh_key_name" {}
variable "resource_group_name" {}
variable "dns_zone" {}
