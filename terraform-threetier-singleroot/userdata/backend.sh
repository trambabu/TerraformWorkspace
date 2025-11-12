#!/bin/bash
set -e

# install java & awscli
yum update -y
yum install -y java-17-amazon-corretto awscli

mkdir -p /opt/imlokal
BUCKET="${bucket}"
FILE="${filename}"

if aws s3 ls "s3://$BUCKET/$FILE" ; then
  aws s3 cp "s3://$BUCKET/$FILE" /opt/imlokal/$FILE
  chown ec2-user:ec2-user /opt/imlokal/$FILE
fi

# create a simple systemd service for the jar
cat >/etc/systemd/system/imlokal.service <<'SERVICE'
[Unit]
Description=imlokal backend service
After=network.target

[Service]
User=ec2-user
ExecStart=/usr/bin/java -jar /opt/imlokal/${filename} --server.port=8080
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable imlokal
systemctl start imlokal || true
# Note: service may fail to start if the DB is not yet reachable. The restart=always