resource "aws_kinesis_stream" "stream" {
  name             = "${var.app_name}-${var.env_name}"
  shard_count      = "${var.kinesis_shard_count}"
  retention_period = "${var.kinesis_retention_period}"

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = {
    Name = "${var.app_name}-${var.env_name}"
  }
}

resource "aws_lambda_event_source_mapping" "streams" {
  event_source_arn  = "${aws_kinesis_stream.stream.arn}"
  function_name     = "${aws_lambda_function.cw-kinesis-es.arn}"
  starting_position = "LATEST"
  batch_size        = 100
}
