#!/bin/bash

CATEGORY="IAM"

echo "[IAM] Checking for access keys older than 90 days..."

users=$(aws iam list-users --query 'Users[*].UserName' --output text)

fail=0

for user in $users; do
  keys=$(aws iam list-access-keys --user-name "$user" --query 'AccessKeyMetadata[*]' --output json)

  echo "$keys" | jq -c '.[]' | while read -r key; do
    key_id=$(echo "$key" | jq -r '.AccessKeyId')
    created=$(echo "$key" | jq -r '.CreateDate')

    if [ -z "$created" ]; then
      echo "⚠️  Skipping $key_id (no creation date found)"
      continue
    fi

    created_ts=$(date -d "$created" +%s 2>/dev/null)

    if [ -z "$created_ts" ]; then
      echo "⚠️  Could not parse timestamp for $key_id"
      continue
    fi

    now_ts=$(date +%s)
    days_old=$(( (now_ts - created_ts) / 86400 ))

    if [ "$days_old" -gt 90 ]; then
      echo "❌ $user has access key $key_id that is $days_old days old"
      fail=1
    else
      echo "✅ $user key $key_id is only $days_old days old"
    fi
  done
done

exit $fail

