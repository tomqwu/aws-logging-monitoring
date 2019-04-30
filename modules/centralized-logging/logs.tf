resource "aws_cloudwatch_log_destination" "destination" {
  name       = "${var.app_name}-${var.env_name}-destination"
  role_arn   = "${aws_iam_role.cwl.arn}"
  target_arn = "${aws_kinesis_stream.stream.arn}"
}

data "aws_iam_policy_document" "destination_policy" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "${var.destination_policy_identifiers}",
      ]
    }

    actions = [
      "logs:PutSubscriptionFilter",
    ]

    resources = [
      "${aws_cloudwatch_log_destination.destination.arn}",
    ]
  }
}

resource "aws_cloudwatch_log_destination_policy" "destination_policy" {
  destination_name = "${aws_cloudwatch_log_destination.destination.name}"
  access_policy    = "${data.aws_iam_policy_document.destination_policy.json}"
}
