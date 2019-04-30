terraform {
  required_version = ">= 0.11.10" # introduction of Local Values configuration language feature

  backend "atlas" {
    name    = "CPPIB/edl-centralized-logging-nonprod"
    address = "https://terraform.cppib.ca"
  }
}

provider "vault" {
  address = "https://vault.cppib.ca"
}

// AWS credentials from Vault
data "vault_aws_access_credentials" "sts-creds" {
  backend = "aws"
  role    = "edl-dev1"
  type    = "sts"
}

//  Setup the core provider information.
provider "aws" {
  region = "${var.region}"

  access_key = "${data.vault_aws_access_credentials.sts-creds.access_key}"
  secret_key = "${data.vault_aws_access_credentials.sts-creds.secret_key}"
  token      = "${data.vault_aws_access_credentials.sts-creds.security_token}"
}

data "terraform_remote_state" "edl-etl-workflow" {
  backend = "atlas"

  config {
    name    = "CPPIB/edl-etl-workflow-dev1"
    address = "https://terraform.cppib.ca"
  }
}

data "terraform_remote_state" "elasticsearch" {
  backend = "atlas"

  config {
    name    = "CPPIB/edl-elasticsearch-nonprod"
    address = "https://terraform.cppib.ca"
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
