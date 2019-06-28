terraform {
  required_version = ">= 0.11.10" # introduction of Local Values configuration language feature

  backend "atlas" {
    name    = "demo/demo-centralized-logging-nonprod"
    address = "https://terraform.demo.ca"
  }
}

provider "vault" {
  address = "https://vault.demo.ca"
}

// AWS credentials from Vault
data "vault_aws_access_credentials" "sts-creds" {
  backend = "aws"
  role    = "demo-demo"
  type    = "sts"
}

//  Setup the core provider information.
provider "aws" {
  region = "${var.region}"

  access_key = "${data.vault_aws_access_credentials.sts-creds.access_key}"
  secret_key = "${data.vault_aws_access_credentials.sts-creds.secret_key}"
  token      = "${data.vault_aws_access_credentials.sts-creds.security_token}"
}

data "terraform_remote_state" "demo-etl-workflow" {
  backend = "atlas"

  config {
    name    = "demo/demo-etl-workflow-demo"
    address = "https://terraform.demo.ca"
  }
}

data "terraform_remote_state" "elasticsearch" {
  backend = "atlas"

  config {
    name    = "demo/demo-elasticsearch-nonprod"
    address = "https://terraform.demo.ca"
  }
}

data "vault_aws_access_credentials" "sts-shared-services" {
  backend = "aws"
  role    = "shared-services-dev"
  type    = "sts"
}

provider "aws" {
  alias  = "shared-services"
  region = "${var.region}"

  token      = "${data.vault_aws_access_credentials.sts-shared-services.security_token}"
  access_key = "${data.vault_aws_access_credentials.sts-shared-services.access_key}"
  secret_key = "${data.vault_aws_access_credentials.sts-shared-services.secret_key}"
}
