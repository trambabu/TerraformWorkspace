#!/bin/bash
# Install git, unzip and other utilities on Bastion
yum update -y
yum install -y git unzip

# Setup SSH keys for accessing private instances
mkdir -p /home/ec2-user/.ssh
chmod 700 /home/ec2-user/.ssh

# Copy authorized keys from a mounted location or S3 (optional placeholder)
# echo "ssh-rsa AAAA..." >> /home/ec2-user/.ssh/authorized_keys

chown -R ec2-user:ec2-user /home/ec2-user/.ssh
chmod 600 /home/ec2-user/.ssh/authorized_keys

# Enable SSH agent forwarding (if needed)
echo "ForwardAgent yes" >> /etc/ssh/ssh_config
