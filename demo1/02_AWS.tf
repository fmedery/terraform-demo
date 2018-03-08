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

  records = ["${azurerm_public_ip.public_ip.ip_address}"]
}
