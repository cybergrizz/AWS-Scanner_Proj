#!/bin/bash

CATEGORY="S3"

echo "[S3] Checking for publicly accessible buckets..."

buckets=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)

for bucket in $buckets; do
  policy=$(aws s3api get-bucket-policy-status --bucket "$bucket" --query 'PolicyStatus.IsPublic' 2>/dev/null)

  if [ "$policy" == "true" ]; then
    echo "❌ Bucket $bucket is PUBLIC"
  else
    echo "✅ Bucket $bucket is private"
  fi
done

