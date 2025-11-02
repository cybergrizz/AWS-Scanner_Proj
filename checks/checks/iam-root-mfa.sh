#!/bin/bash

CATEGORY="IAM"

echo "[IAM] Checking if root account has MFA enabled..."

mfa=$(aws iam get-account-summary --query 'SummaryMap.AccountMFAEnabled' --output text)

if [ "$mfa" -eq 1 ]; then
  echo "✅ Root account has MFA enabled"
  exit 0
else
  echo "❌ Root account does NOT have MFA enabled"
  exit 1
fi

