module "elasticsearch" {
  source = "../../../modules/elasticsearch"

  vpc = "${var.vpc}"

  instance_type = "${var.instance_type}"

  domain = "${var.app_name}-${var.env_name}"

  env_name = "${var.env_name}"

  app_name = "${var.app_name}"
}
