output "cw_logs_dest_arn" {
    value = "${aws_cloudwatch_log_destination.destination.arn}"
}
