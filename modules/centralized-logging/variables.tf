variable "vpc" {
  description = "vpc name"
}

variable "region" {
  default = "us-east-1"
}

variable "env_name" {}

variable "app_name" {}

###########################
# Kinesis
###########################

variable "kinesis_shard_count" {
  default = 1
}

variable "kinesis_retention_period" {
  default = 48
}

variable "destination_policy_identifiers" {
  default = []
  type    = "list"
}

###########################
# Lambda
###########################
variable "lambda_s3_bucket" {
  default = "cppib-terraform-lambda-artifacts"
}

variable "lambda_s3_key" {
  default = "cloudwatch-kinesis-es-lambda/main.zip"
}

variable "es_endpoint" {
  default = "elasticsearch endpoint"
}
