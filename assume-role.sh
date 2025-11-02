#!/bin/bash

source assume-role.env

echo "🔐 Assuming role into $ACCOUNT_ID..."

creds=$(aws sts assume-role \
  --profile "$PROFILE" \
  --role-arn arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME \
  --role-session-name "$SESSION_NAME" \
  --query 'Credentials' \
  --output json)

if [ -z "$creds" ]; then
  echo "❌ Failed to assume role"
  exit 1
fi

export AWS_ACCESS_KEY_ID=$(echo "$creds" | jq -r '.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$creds" | jq -r '.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$creds" | jq -r '.SessionToken')

echo "✅ Role assumed. Temporary credentials set."

