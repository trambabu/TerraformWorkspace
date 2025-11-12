#!/bin/bash -xe
yum update -y
yum install -y httpd awscli
systemctl enable --now httpd || true
cat > /var/www/html/index.html <<'HTML'
<html><body><h1>imlokal Frontend</h1><p>$(hostname -f)</p></body></html>
HTML
