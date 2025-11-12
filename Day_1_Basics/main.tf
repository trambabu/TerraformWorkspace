terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.0"
    }
  }
}

data "external" "s3_buckets" {
  program = [
    "powershell",
    "-Command",
    "$b = aws s3api list-buckets --query 'Buckets[].Name' --output json; $result = @{'buckets' = ($b | Out-String)}; $result | ConvertTo-Json -Compress"
  ]
}

output "s3_bucket_names" {
  value = jsondecode(data.external.s3_buckets.result["buckets"])
}
