output "cw_logs_dest_arn" {
  value = "${module.logging.cw_logs_dest_arn}"
}

output "route53_fqdn" {
  value = "${module.route53.fqdn}"
}
