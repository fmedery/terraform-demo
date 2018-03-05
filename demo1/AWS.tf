#
## CREATION DU VIRTUAL PRIVATE NETWORK
#
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags {
    resource_group_name = "${var.resource_group_name}"
  }
}

## CREATION des RESEAUX -> AZ

resource "aws_subnet" "ca-central-1a" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ca-central-1a"
  map_public_ip_on_launch = true

  tags {
    resource_group_name = "${var.resource_group_name}"
  }
}

resource "aws_subnet" "ca-central-1b" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ca-central-1b"
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

#
## Creation du group de securite pour les serveurs
#
resource "aws_security_group" "security_group" {
  vpc_id = "${aws_vpc.vpc.id}"

  # Permet aux serveurs de se parler entre eux sur tous les ports
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # Permet de se connecter aux servers via SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # permet de se connecter via HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # permet ping
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ## permet aux serveurs de se connecter vers l'exterieur
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    resource_group_name = "${var.resource_group_name}"
  }
}

#
## SERVEUR
#

## RECUPERATION DE ID de AMI ubuntu latest

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

## SERVEURS

resource "aws_instance" "serveurs" {
  count = "${var.nbr}"

  vpc_security_group_ids = ["${aws_security_group.security_group.id}"]
  subnet_id              = "${aws_subnet.ca-central-1a.id}"

  associate_public_ip_address = true
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  key_name                    = "${var.ssh_key_name}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }

  tags {
    resource_group_name = "${var.resource_group_name}"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
  }

  # Copies the myapp.conf file to /etc/myapp.conf
  provisioner "file" {
    source      = "scripts/aws.sh"
    destination = "/tmp/aws.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/aws.sh",
      "/tmp/aws.sh demo1",
    ]
  }
}

###
# DNS
###
data "aws_route53_zone" "dns_zone" {
  name = "${var.dns_zone}"
}

resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.dns_zone.zone_id}"
  name    = "demo1.${data.aws_route53_zone.dns_zone.name}"
  type    = "A"
  ttl     = "60"

  records = ["${aws_instance.serveurs.public_ip}"]
}
