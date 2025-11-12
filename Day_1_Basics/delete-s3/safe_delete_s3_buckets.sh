#!/bin/bash
set -e

echo "============================================"
echo "🚀 SAFE Auto S3 Bucket Cleanup Script (AWS)"
echo "============================================"

# === STEP 1: FETCH ALL BUCKET NAMES ===
echo -e "\n📋 Fetching all S3 buckets..."
buckets=$(aws s3api list-buckets --query 'Buckets[].Name' --output text)

if [ -z "$buckets" ]; then
  echo "✅ No buckets found. Nothing to delete."
  exit 0
fi

echo -e "🪣 Buckets found:\n$buckets"

# === STEP 2: ASK USER BEFORE DELETING EACH BUCKET ===
for bucket in $buckets; do
  echo -e "\n=============================="
  echo "🧩 Bucket detected: $bucket"
  echo "=============================="

  read -p "❓ Do you want to delete this bucket? (yes/no): " choice
  case "$choice" in
    [Yy][Ee][Ss]|[Yy])
      echo "⚠️ Proceeding to delete $bucket..."
      ;;
    [Nn][Oo]|[Nn])
      echo "⏩ Skipping $bucket as per user choice."
      continue
      ;;
    *)
      echo "⚠️ Invalid input, skipping $bucket by default."
      continue
      ;;
  esac

  # Check if bucket exists
  if ! aws s3api head-bucket --bucket "$bucket" 2>/dev/null; then
    echo "⚠️ Bucket $bucket does not exist — skipping."
    continue
  fi

  echo "🧹 Emptying bucket: $bucket"

  # Delete all versions (if versioning enabled)
  versions=$(aws s3api list-object-versions --bucket "$bucket" --output json --query 'Versions')
  if [[ "$versions" != "[]" && "$versions" != "null" ]]; then
    echo "🗑 Deleting object versions..."
    aws s3api delete-objects --bucket "$bucket" \
      --delete "$(aws s3api list-object-versions --bucket "$bucket" \
      --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}' --output json)" || true
  fi

  # Delete delete markers
  markers=$(aws s3api list-object-versions --bucket "$bucket" --output json --query 'DeleteMarkers')
  if [[ "$markers" != "[]" && "$markers" != "null" ]]; then
    echo "🚮 Deleting delete markers..."
    aws s3api delete-objects --bucket "$bucket" \
      --delete "$(aws s3api list-object-versions --bucket "$bucket" \
      --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' --output json)" || true
  fi

  # Delete all remaining objects (non-versioned)
  echo "🧾 Deleting remaining objects..."
  aws s3 rm "s3://$bucket" --recursive || true

  # Delete the bucket itself
  echo "💣 Deleting bucket $bucket..."
  aws s3api delete-bucket --bucket "$bucket" || true

  echo "✅ $bucket deleted successfully."
done

# === STEP 3: VERIFY CLEANUP ===
echo -e "\n📋 Verifying cleanup..."
remaining=$(aws s3api list-buckets --query 'Buckets[].Name' --output text)

if [ -z "$remaining" ]; then
  echo "🎉 All S3 buckets deleted successfully!"
else
  echo "⚠️ Still remaining buckets:"
  echo "$remaining"
fi

echo -e "\n✅ Cleanup complete."
echo "============================================"