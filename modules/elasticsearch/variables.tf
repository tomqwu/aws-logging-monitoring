variable "vpc" {}

variable "domain" {
  default = "tf-test"
}

variable "instance_type" {
  default = "r5.large.elasticsearch"
}

variable "env_name" {}

variable "app_name" {}
