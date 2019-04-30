output "endpoint" {
  value = "${module.elasticsearch.endpoint}"
}

output "kibana_endpoint" {
  value = "${module.elasticsearch.kibana_endpoint}"
}
