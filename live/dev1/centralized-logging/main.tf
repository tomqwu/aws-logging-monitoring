module "logging" {
  source = "../../../modules/centralized-logging"

  vpc = "${var.vpc}"

  env_name = "${var.env_name}"

  app_name = "${var.app_name}"

  kinesis_shard_count = "${var.kinesis_shard_count}"

  kinesis_retention_period = "${var.kinesis_retention_period}"
}
