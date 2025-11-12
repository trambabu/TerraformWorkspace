RUNBOOK - Layered deployment

1) Generate SSH key locally:
   mkdir -p ~/.ssh
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_imlokal

2) Bootstrap backend state:
   cd 00-backend-bootstrap
   terraform init
   terraform apply -auto-approve

3) Edit backend block in projects to reference created S3 + DynamoDB if desired.
4) Deploy in order: 01-network -> 02-security -> 03-compute -> 04-database -> 05-route53-cloudfront

5) Upload backend JAR to S3 and set backend_app_s3_url variable before applying compute if you want Spring Boot app to run.
