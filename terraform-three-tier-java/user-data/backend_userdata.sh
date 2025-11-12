#!/bin/bash
# Update and install HTTPD (or can install Java/SpringBoot runtime)
yum update -y
yum install -y httpd java-17-amazon-corretto

# Enable and start HTTPD (as placeholder for backend service)
systemctl enable httpd
systemctl start httpd

# Optional: simple HTML page to indicate backend
echo "<h1>Backend Server - $(hostname)</h1>" > /var/www/html/index.html

# Example: Download backend application jar from S3 (if provided)
# aws s3 cp s3://your-backend-app-bucket/backend-app.jar /home/ec2-user/backend-app.jar
# java -jar /home/ec2-user/backend-app.jar &
