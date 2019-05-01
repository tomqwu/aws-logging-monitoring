vpc = "cppib-edl-dev1"

env_name = "nonprod"

app_name = "edl-centralized-logging"

destination_policy_identifiers = [
  "525341175865", # edl-dev1
  "439102842022", # edl-dev2
  "233592520724", # edl-dev3
  "782132744008", # edl-uat
]

lambda_s3_key = "cloudwatch-kinesis-es-lambda/main_v1.0.0.zip"
