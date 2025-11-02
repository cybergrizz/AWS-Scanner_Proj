#!/bin/bash

CATEGORY="Cloudtrail"

echo "[CloudTrail] Checking if logs are encrypted with KMS..."

fail=0
trails=$(aws cloudtrail describe-trails --query 'trailList[*].Name' --output text 2>/dev/null)

if [ -z "$trails" ]; then
  echo "ℹ️  No CloudTrails found"
  exit 0
fi

for trail in $trails; do
  key=$(aws cloudtrail get-trail --name "$trail" --query 'Trail.KmsKeyId' --output text)

  if [[ "$key" == "None" || -z "$key" ]]; then
    echo "❌ Trail $trail is NOT encrypted with KMS"
    fail=1
  else
    echo "✅ Trail $trail is encrypted (KMS Key: $key)"
  fi
done

exit $fail

