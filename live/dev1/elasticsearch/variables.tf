variable "env_name" {}

variable "app_name" {}

variable "vpc" {}

variable "instance_type" {
  default = "r5.large.elasticsearch"
}

variable "region" {
  default = "us-east-1"
}

variable "es_version" {
  default = 6.5
}

variable "ingress_sg_cidrs" {
  default = []
}
