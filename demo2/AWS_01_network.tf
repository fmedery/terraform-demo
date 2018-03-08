## CREATION DU VIRTUAL PRIVATE NETWORK
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags {
    resource_group_name = "${var.resource_group_name}"
  }
}

## CREATION d'un SOUS RESEAU

resource "aws_subnet" "ca-central-1a" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ca-central-1a"
  map_public_ip_on_launch = true

  tags {
    resource_group_name = "${var.resource_group_name}"
  }
}

## AWS INTERNET GATEWAY --> PERMET AU SERVEURS DE CONNECTER A INTERNET

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    resource_group_name = "${var.resource_group_name}"
  }
}

## connect les reseaux a aws_internet_gateway
data "aws_route_table" "selected" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route" "default_route" {
  route_table_id         = "${data.aws_route_table.selected.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.internet_gateway.id}"
}
