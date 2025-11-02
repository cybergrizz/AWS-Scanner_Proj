#!/bin/bash
CATEGORY="Cloudtrail"

echo "[CloudTrail] Checking if CloudTrail is enabled in this region..."

trails=$(aws cloudtrail describe-trails --query 'trailList[*].TrailARN' --output text 2>/dev/null)

if [ -z "$trails" ]; then
  echo "❌ No CloudTrails found in this region"
  exit 1
else
  echo "✅ CloudTrail is enabled"
  exit 0
fi

