#!/bin/bash
# Update and install HTTPD for frontend server
yum update -y
yum install -y httpd

# Enable and start HTTPD
systemctl enable httpd
systemctl start httpd

# Optional: simple HTML page
echo "<h1>Frontend Server - $(hostname)</h1>" > /var/www/html/index.html
