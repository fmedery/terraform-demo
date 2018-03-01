## ELB security group
resource "aws_security_group" "lb_security_group" {
  provider = "aws.localdev"
  name     = "terraform-demo-elb"
  vpc_id   = ""

  # Allow all from self
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # Allow TCP 80 from all
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow ALL to ALL
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## ELB
resource "aws_elb" "lb" {
  provider        = "aws.localdev"
  name            = "terraform-demo-elb"
  security_groups = ["${aws_security_group.lb_security_group.id}"]

  ## us-west-2a
  subnets  = ["subnet-ea42209c"]
  internal = false

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
    target              = "HTTP:80/elb-status"
    interval            = 5
  }

  instances                   = ["${aws_instance.ec2_server.*.id}"]
  cross_zone_load_balancing   = false
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "terraform-demo"
  }
}
