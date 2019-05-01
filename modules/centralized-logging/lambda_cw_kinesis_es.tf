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

# lambda get-record from kinesis for cloudwatch logs
# cppib-terraform-lambda-artifacts/cloudwatch-kinesis-es-lambda/main.zip
resource "aws_lambda_function" "cw-kinesis-es" {
  s3_bucket = "${var.lambda_s3_bucket}"
  s3_key    = "${var.lambda_s3_key}"
  role      = "${aws_iam_role.cw-kinesis-es-lambda.arn}"
  runtime   = "nodejs8.10"

  function_name = "${var.app_name}_${var.env_name}_cw_kinesis_es"
  handler       = "kinesis_lambda_es.handler"

  timeout     = "90"
  memory_size = "128"

  vpc_config {
    subnet_ids         = ["${data.aws_subnet_ids.selected.ids}"]
    security_group_ids = ["${aws_security_group.cw-kinesis-es.id}"]
  }

  environment {
    variables = {
      ES_REGION   = "${var.region}"
      ES_ENDPOINT = "${var.es_endpoint}"
    }
  }
}

resource "aws_security_group" "cw-kinesis-es" {
  name        = "${var.app_name}-${var.env_name}-cw-kinesis-es-lambda"
  description = "Allow inbound traffic"
  vpc_id      = "${data.aws_vpc.selected.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.aws_vpc.selected.cidr_block}"]
  }

  tags {
    Name = "${var.app_name}-${var.env_name}-cw-kinesis-es-lambda"
  }
}

resource "aws_iam_role" "cw-kinesis-es-lambda" {
  name = "CPPIB-${var.app_name}-${var.env_name}-cw-kinesis-es-lambda"
  path = "/"

  assume_role_policy = "${data.aws_iam_policy_document.cw-kinesis-es-assume.json}"
}

data "aws_iam_policy_document" "cw-kinesis-es-assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cw-kinesis-es-lambda" {
  statement {
    effect = "Allow"

    actions = [
      "es:ESHttpPost",
      "es:ESHttpPut",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:DescribeStream",
      "kinesis:ListStreams",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "cw-kinesis-es-lambda" {
  name   = "CPPIB-${var.app_name}-${var.env_name}-cw-kinesis-es-lambda"
  policy = "${data.aws_iam_policy_document.cw-kinesis-es-lambda.json}"
}

resource "aws_iam_role_policy_attachment" "cw-kinesis-es-attach" {
  role       = "${aws_iam_role.cw-kinesis-es-lambda.name}"
  policy_arn = "${aws_iam_policy.cw-kinesis-es-lambda.arn}"
}
