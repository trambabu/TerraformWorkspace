#!/bin/bash -xe
yum update -y
yum install -y httpd
systemctl enable --now httpd || true
yum install -y amazon-ssm-agent || true
systemctl enable --now amazon-ssm-agent || true
