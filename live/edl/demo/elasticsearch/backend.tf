terraform {
  required_version = ">= 0.11.10" # introduction of Local Values configuration language feature

  backend "atlas" {
    name    = "demo/demo-elasticsearch-nonprod"
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
