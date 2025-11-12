#!/bin/bash

# List of buckets to delete
buckets=(
  "tf-state-dev-188939218963"
  "tf-state-prod-188939218963"
  "tf-state-staging-188939218963"
  "tram-state-bucket-dev-123456"
  "imlokal-tfstate-unique"
)

# Loop through each bucket
for bucket in "${buckets[@]}"; do
  echo "Processing bucket: $bucket"

  # Get the bucket region dynamically
  region=$(aws s3api get-bucket-location --bucket "$bucket" --query 'LocationConstraint' --output text)
  
  # Default to us-east-1 if LocationConstraint is None
  if [ "$region" == "None" ]; then
    region="us-east-1"
  fi

  echo "Bucket region: $region"

  # Delete all object versions
  echo "Deleting all object versions..."
  aws s3api list-object-versions --bucket "$bucket" --output json |
    jq -r '.Versions[]? | [.Key, .VersionId] | @tsv' |
    while IFS=$'\t' read -r key version; do
      aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$version" --region "$region"
    done

  # Delete all delete markers
  echo "Deleting all delete markers..."
  aws s3api list-object-versions --bucket "$bucket" --output json |
    jq -r '.DeleteMarkers[]? | [.Key, .VersionId] | @tsv' |
    while IFS=$'\t' read -r key version; do
      aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$version" --region "$region"
    done

  # Finally, delete the bucket
  echo "Deleting bucket: $bucket"
  aws s3api delete-bucket --bucket "$bucket" --region "$region"
  echo "Bucket $bucket deleted successfully."
  echo "----------------------------------------"
done

echo "All specified buckets processed."
