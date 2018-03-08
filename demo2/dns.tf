# on va chercher l'information ID de la ressource deja créee
data "aws_route53_zone" "dns_zone" {
  name = "${var.dns_zone}"
}

# on crée un A record par serveur Azure et AWS
resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.dns_zone.zone_id}"
  name    = "demo2.${data.aws_route53_zone.dns_zone.name}"
  type    = "A"
  ttl     = "60"

  records = [
    "${split(",", join(",", aws_instance.serveurs.*.public_ip))}",
    "${split(",", join(",", azurerm_public_ip.public_ip.*.ip_address))}",
  ]
}
