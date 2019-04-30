resource "aws_route53_record" "default" {
  zone_id = "${var.zone_id}"
  name    = "${var.alias}-log"
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
    weight = 10
  }

  set_identifier = "${var.alias}"
  records        = ["${var.record_name}"]
}
