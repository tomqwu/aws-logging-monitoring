# logging-monitoring-tf

This stack creates the following
1. AWS Elasticsearch
1. Kinesis
1. Lambda as cosnsumer for Kinesis
1. Cloudwatch Log Destination as cross account endpoint


## How to subscribe to log destination
```
resource "aws_cloudwatch_log_subscription_filter" "sqsmessages" {
  count = "${var.enable_cloudwatch_log_subscription ? 1 : 0}"
  
  name            = "cw_logs_sub_filter-sqsmessages"
  log_group_name  = "/aws/lambda/${var.app_name}_${var.env_name}_ReadSQSMessages"
  filter_pattern  = ""
  destination_arn = "${var.cloudwatch_logs_dest_arn}"
  distribution    = "ByLogStream"
}
```
