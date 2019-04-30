data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "selected" {
  tags {
    Name = "${var.vpc}"
  }
}

data "aws_subnet_ids" "selected" {
  vpc_id = "${data.aws_vpc.selected.id}"

  tags {
    Tier = "private"
  }
}

locals {
  merged_ingress_sg_cidrs = [
    "${data.aws_vpc.selected.cidr_block}",
    "${var.ingress_sg_cidrs}",
  ]
}

resource "aws_security_group" "es" {
  name        = "${var.vpc}-elasticsearch-${var.domain}"
  description = "Managed by Terraform"
  vpc_id      = "${data.aws_vpc.selected.id}"

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["${local.merged_ingress_sg_cidrs}"]
  }
}

# resource "aws_iam_service_linked_role" "es" {
#   aws_service_name = "es.amazonaws.com"
# }

resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${var.domain}"
  elasticsearch_version = "${var.es_version}"

  cluster_config {
    instance_type  = "${var.instance_type}"
    instance_count = "${var.instance_count}"

    dedicated_master_enabled = "${var.dedicated_master_enabled}"
    dedicated_master_type    = "${var.master_instance_type}"
    dedicated_master_count   = "${var.dedicated_master_count}"

    zone_awareness_enabled = true
  }

  vpc_options {
    subnet_ids = [
      "${data.aws_subnet_ids.selected.ids[0]}",
      "${data.aws_subnet_ids.selected.ids[1]}",
    ]

    security_group_ids = ["${aws_security_group.es.id}"]
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  node_to_node_encryption {
    enabled = false
  }

  encrypt_at_rest {
    enabled = true
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain}/*"
        }
    ]
}
CONFIG

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags {
    Domain = "${var.domain}"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.domain.arn}"
    log_type                 = "INDEX_SLOW_LOGS"
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = "${var.ebs_volume_size}"
  }

  #   depends_on = [
  #     "aws_iam_service_linked_role.es",
  #   ]
}

resource "aws_cloudwatch_log_group" "domain" {
  name = "elasticsearch-${var.domain}"
}

resource "aws_cloudwatch_log_resource_policy" "domain" {
  policy_name = "CPPIB-${var.app_name}-${var.env_name}-${var.domain}"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}
