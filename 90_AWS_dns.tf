# resource "aws_route53_record" "dns-record" {
#   provider = "aws.newprod"
#   zone_id  = "Z4DM0GCCSW9NU"
#   name     = "demo-fmedery-${var.env}.us-west-"
#   type     = "A"
#
#   alias {
#     name                   = "${aws_elb.lb.dns_name}"
#     zone_id                = "${aws_elb.lb.zone_id}"
#     evaluate_target_health = false
#   }
# }
