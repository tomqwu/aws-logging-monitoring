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
