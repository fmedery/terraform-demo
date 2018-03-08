## Creation du group de securite pour les serveurs

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

  # # permet ping
  # ingress {
  #   from_port   = 8
  #   to_port     = 0
  #   protocol    = "icmp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

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
