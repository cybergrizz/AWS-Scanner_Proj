#!/bin/bash

CATEGORY="IAM"

echo "[IAM] Checking for users without MFA..."
users=$(aws iam list-users --query 'Users[*].UserName' --output text)

for user in $users; do
  mfa=$(aws iam list-mfa-devices --user-name "$user" --query 'MFADevices' --output text)
  if [ -z "$mfa" ]; then
    echo "❌ $user has NO MFA enabled"
  else
    echo "✅ $user has MFA enabled"
  fi
done

