#!/bin/bash

CATEGORY="GuardDuty"

echo "[GuardDuty] Checking if GuardDuty is enabled..."

detectors=$(aws guardduty list-detectors --query 'DetectorIds' --output text 2>/dev/null)

if [ -z "$detectors" ]; then
  echo "❌ GuardDuty is NOT enabled in this region"
  exit 1
else
  echo "✅ GuardDuty is enabled (Detector ID: $detectors)"
  exit 0
fi

