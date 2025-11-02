#!/bin/bash

CATEGORY="S3"

echo "[S3] Checking for buckets without default encryption..."

buckets=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)

for bucket in $buckets; do
  enc=$(aws s3api get-bucket-encryption --bucket "$bucket" 2>/dev/null)

  if [[ $? -ne 0 ]]; then
    echo "❌ $bucket has NO encryption enabled"
    exit 1
  else
    echo "✅ $bucket has encryption enabled"
  fi
done

exit 0

