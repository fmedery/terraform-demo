## EC2 secyrity group
resource "aws_security_group" "ec2_security_group" {
  provider = "aws.localdev"
  name     = "ec2"
  vpc_id   = ""

  # Allow all from self
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # Allow SSH from the office
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["173.231.109.240/29"]
  }

  # All TCP 80 from ELB only
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.lb_security_group.id}"]
  }

  # allow all to ALL
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Create EC2
resource "aws_instance" "ec2_server" {
  provider = "aws.localdev"

  ## number of servers
  count = "${var.nbr}"

  ## Centos 7.x image
  ami = "ami-1272f872"

  ## us-west-2a
  subnet_id                   = "subnet-ea42209c"
  associate_public_ip_address = true

  tags {
    Name = "terraform-demo-${format("%03d", count.index + 1)}"
  }

  instance_type          = "${var.instance}"
  key_name               = "terraform"
  vpc_security_group_ids = ["${aws_security_group.ec2_security_group.id}"]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }

  connection {
    type = "ssh"
    user = "ec2-user"
  }

  provisioner "file" {
    source      = "scripts/salt_bootstrap_centos7.sh"
    destination = "/tmp/salt_bootstrap_centos7.sh"
  }

  ### Add the server to salt-master
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/salt_bootstrap_centos7.sh",
      "sudo /tmp/salt_bootstrap_centos7.sh demo-fmedery-www${format("%03d", count.index + 1)}-${var.env}",
      "sudo /bin/salt-call --local grains.append env ${var.env}",
      "sudo /bin/salt-call state.apply",
    ]
  }

  ## Remove the server from salt-master when the resource is destroyed
  provisioner "remote-exec" {
    when = "destroy"

    connection {
      type = "ssh"
      user = "terraform"
    }

    inline = [
      "sudo salt-key -y -d demo-fmedery-www${format("%03d", count.index + 1)}-${var.env}",
    ]
  }
}

## ELB security group
