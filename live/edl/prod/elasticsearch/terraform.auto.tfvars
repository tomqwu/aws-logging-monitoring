vpc = "cppib-edl-prod"

instance_type = "m4.large.elasticsearch"

env_name = "prod"

app_name = "edl-es"

ingress_sg_cidrs = [
  "10.34.0.0/16",  # 15qy     DO NOT CHANGE
  "10.35.0.0/16",  # 1q       DO NOT CHANGE
  "10.81.32.0/20", # db2 vpc  DO NOT CHANGE
]
