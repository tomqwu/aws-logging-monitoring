variable "vpc" {}

variable "domain" {
  default = "tf-test"
}

variable "instance_type" {
  default = "m4.large.elasticsearch"
}

variable "env_name" {}

variable "app_name" {}

variable "es_version" {
  default = 6.5
}

variable "instance_count" {
  default = "4"
}

variable "ebs_volume_size" {
  default = 100
}

variable "master_instance_type" {
  default = "r5.large.elasticsearch"
}

variable "dedicated_master_enabled" {
  default = true
}

variable "dedicated_master_count" {
  default = 3
}

variable "ingress_sg_cidrs" {
  type    = "list"
  default = []
}
