Fill in terraform.tfvars with your domain (your-domain.com), key_pair_name, S3 URLs, and ssh_cidr.

Ensure your AWS credentials are available (env AWS_PROFILE or AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY).

Run:
terraform init
terraform plan -out tfplan
terraform apply "tfplan"


Important security / production notes (short)

Do not store DB password in plain text — use AWS Secrets Manager and reference via Terraform.

Lock down ssh_cidr to your IP only.

Replace skip_final_snapshot = true with false for production and manage backups/retention.

Consider ALB HTTPS listeners (443) with ACM in ap-south-1 if you want end-to-end TLS.

Use CloudFront caching rules & WAF if needed.