# trust policy for cloudwatch logs
resource "aws_iam_role" "cwl" {
  name = "CPPIB-${var.app_name}-${var.env_name}-cwl"
  path = "/"

  assume_role_policy = "${data.aws_iam_policy_document.cwl-assume.json}"
}

data "aws_iam_policy_document" "cwl-assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "logs.${var.region}.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "cwl" {
  role       = "${aws_iam_role.cwl.name}"
  policy_arn = "${aws_iam_policy.cwl.arn}"
}

resource "aws_iam_policy" "cwl" {
  name   = "CPPIB-${var.app_name}-${var.env_name}-cwl"
  policy = "${data.aws_iam_policy_document.cwl.json}"
}

data "aws_iam_policy_document" "cwl" {
  statement {
    effect = "Allow"

    actions = [
      "kinesis:PutRecord",
    ]

    resources = [
      "${aws_kinesis_stream.stream.arn}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]

    resources = [
      "${aws_iam_role.cwl.arn}",
    ]
  }
}
