#!/bin/bash
set -e

# install httpd & awscli
yum update -y
yum install -y httpd awscli unzip

systemctl enable httpd
systemctl start httpd

# Download frontend artifact from S3 bucket
BUCKET="${bucket}"
FILE="${filename}"
if aws s3 ls "s3://$BUCKET/$FILE" ; then
  TMPDIR=/tmp/frontend
  mkdir -p $TMPDIR
  aws s3 cp "s3://$BUCKET/$FILE" $TMPDIR/$FILE
  # if it's a zip, unzip; if jar, place in /var/www/html for download or serve appropriately
  if file $TMPDIR/$FILE | grep -q "Zip archive"; then
    unzip -o $TMPDIR/$FILE -d /var/www/html/
  else
    # place jar for download or use a simple wrapper if using java on frontend
    mv $TMPDIR/$FILE /var/www/html/$FILE
  fi
  chown -R apache:apache /var/www/html
fi

# health endpoint
cat >/var/www/html/health.html <<'EOF'
OK
EOF
