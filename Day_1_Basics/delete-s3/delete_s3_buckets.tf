provider "aws" {
  region = "ap-south-2"
}

locals {
  buckets = [
    "tramfrontends3bucket",
    "tramordersservices3bucket",
    "tramuserservices3bucket"
  ]
}

resource "aws_s3_bucket" "buckets_to_delete" {
  for_each = toset(local.buckets)

  bucket        = each.value
  force_destroy = true  # Deletes even if bucket contains objects
}

output "buckets_to_delete" {
  value = local.buckets
}
