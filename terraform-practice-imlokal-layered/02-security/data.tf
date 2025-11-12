data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket         = var.backend_bucket
    key            = "01-network/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = var.backend_lock_table
  }
}
