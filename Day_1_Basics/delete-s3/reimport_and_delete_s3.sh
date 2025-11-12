#!/bin/bash
set -e

buckets=(
  "tramfrontends3bucket"
  "tramordersservices3bucket"
  "tramuserservices3bucket"
)

echo "=============================="
echo "🚀 Starting S3 Bucket Cleanup & Terraform Delete Process"
echo "=============================="

# === STEP 1: RE-IMPORT BUCKETS ===
echo -e "\n📦 Step 1: Re-importing S3 buckets into Terraform state..."
for bucket in "${buckets[@]}"; do
  echo "→ Importing $bucket ..."
  terraform import "aws_s3_bucket.buckets_to_delete[\"$bucket\"]" "$bucket" || echo "⚠️ Skipping import for $bucket (maybe already exists)"
done

# === STEP 2: EMPTY BUCKETS ===
echo -e "\n🧹 Step 2: Emptying all buckets before deletion..."
for bucket in "${buckets[@]}"; do
  echo -e "\n--- Emptying $bucket ---"

  # Check if bucket exists
  if ! aws s3api head-bucket --bucket "$bucket" 2>/dev/null; then
    echo "⚠️ Bucket $bucket does not exist — skipping."
    continue
  fi

  # Get all versions
  versions=$(aws s3api list-object-versions --bucket "$bucket" --output json --query 'Versions')
  if [[ "$versions" != "[]" && "$versions" != "null" ]]; then
    echo "Deleting object versions..."
    aws s3api delete-objects --bucket "$bucket" \
      --delete "$(aws s3api list-object-versions --bucket "$bucket" \
      --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}' --output json)" || true
  fi

  # Get all delete markers
  markers=$(aws s3api list-object-versions --bucket "$bucket" --output json --query 'DeleteMarkers')
  if [[ "$markers" != "[]" && "$markers" != "null" ]]; then
    echo "Deleting delete markers..."
    aws s3api delete-objects --bucket "$bucket" \
      --delete "$(aws s3api list-object-versions --bucket "$bucket" \
      --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' --output json)" || true
  fi

  # Delete any remaining (non-versioned) objects
  echo "Deleting all remaining objects..."
  aws s3 rm "s3://$bucket" --recursive || true

  echo "✅ $bucket emptied successfully."
done

# === STEP 3: DESTROY USING TERRAFORM ===
echo -e "\n💣 Step 3: Destroying S3 buckets via Terraform..."
terraform destroy -auto-approve

echo -e "\n✅ All buckets deleted successfully!"
echo "=============================="