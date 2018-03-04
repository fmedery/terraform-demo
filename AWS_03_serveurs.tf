## Load balancer

resource "aws_elb" "load_balancer" {
  name            = "${var.resource_group_name}"
  security_groups = ["${aws_security_group.security_group.id}"]

  subnets = [
    "${aws_subnet.ca-central-1a.id}",
    "${aws_subnet.ca-central-1b.id}",
  ]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing = true

  instances = ["${aws_instance.serveurs.*.id}"]

  tags {
    resource_group_name = "${var.resource_group_name}"
  }
}

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
    user = "${var.ssh_user}"
  }

  # Copies the myapp.conf file to /etc/myapp.conf
  provisioner "file" {
    source      = "scripts/aws.sh"
    destination = "/tmp/aws.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/aws.sh",
      "/tmp/aws.sh",
    ]
  }
}
