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

resource "aws_security_group" "es" {
  name        = "${var.vpc}-elasticsearch-${var.domain}"
  description = "Managed by Terraform"
  vpc_id      = "${data.aws_vpc.selected.id}"

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "${data.aws_vpc.selected.cidr_blocks}",
    ]
  }
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${var.domain}"
  elasticsearch_version = "6.5"

  cluster_config {
    instance_type = "m4.large.elasticsearch"
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

  depends_on = [
    "aws_iam_service_linked_role.es",
  ]
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
