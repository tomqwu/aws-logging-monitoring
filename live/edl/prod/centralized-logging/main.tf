module "logging" {
  source = "../../../modules/centralized-logging"

  vpc = "${var.vpc}"

  env_name = "${var.env_name}"

  app_name = "${var.app_name}"

  kinesis_shard_count = "${var.kinesis_shard_count}"

  kinesis_retention_period = "${var.kinesis_retention_period}"

  destination_policy_identifiers = "${var.destination_policy_identifiers}"

  es_endpoint = "${data.terraform_remote_state.elasticsearch.endpoint}"

  lambda_s3_key = "${var.lambda_s3_key}"
}

module "route53" {
  source = "../../../modules/route53"

  providers = {
    aws = "aws.shared-services"
  }

  zone_id = "${var.zone_id}"

  alias = "${var.app_name}-${var.env_name}"

  record_name = "${data.terraform_remote_state.elasticsearch.endpoint}"
}
