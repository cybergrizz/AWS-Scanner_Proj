#!/bin/bash

CATEGORY="S3"

echo "[S3] Checking for buckets missing Block Public Access settings..."

buckets=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)

for bucket in $buckets; do
  block=$(aws s3api get-bucket-public-access-block --bucket "$bucket" 2>/dev/null)

  if [[ $? -ne 0 ]]; then
    echo "❌ $bucket does NOT have Block Public Access settings configured"
    exit 1
  else
    echo "✅ $bucket has Block Public Access enabled"
  fi
done

exit 0

