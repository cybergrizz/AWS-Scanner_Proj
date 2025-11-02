#!/bin/bash

ROLE_NAME="VulnScanReadOnly"
PROFILE="soc"
SESSION_NAME="scanner-multi-session"
ACCOUNTS_FILE="accounts.txt"

mkdir -p reports

while read -r ACCOUNT_ID; do
  echo -e "Now Scanning account: $ACCOUNT_ID"

  creds=$(aws sts assume-role \
    --profile "$PROFILE" \
    --role-arn arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME \
    --role-session-name "$SESSION_NAME" \
    --query 'Credentials' --output json)

  if [ -z "$creds" ]; then
    echo "❌ Failed to assume role in $ACCOUNT_ID"
    continue
  fi

  export AWS_ACCESS_KEY_ID=$(echo "$creds" | jq -r '.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo "$creds" | jq -r '.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo "$creds" | jq -r '.SessionToken')

  echo "✅ Credentials set. Running scan..."

  # Run the scan and capture output
  scan_output=$(./scanner.sh)
  echo "$scan_output" > "reports/scan_${ACCOUNT_ID}.txt"

  # Extract pass/fail counts from output using grep
  pass_count=$(echo "$scan_output" | grep -Eo '✅ [0-9]+ Passed' | awk '{print $2}' | head -1)
  fail_count=$(echo "$scan_output" | grep -Eo '❌ [0-9]+ Failed' | awk '{print $2}' | head -1)

  # Fallback if grep fails
  pass_count=${pass_count:-0}
  fail_count=${fail_count:-0}
  # Validate
  if ! [[ "$pass_count" =~ ^[0-9]+$ && "$fail_count" =~ ^[0-9]+$ ]]; then
    echo "⚠️ Invalid counts: pass='$pass_count', fail='$fail_count' — skipping Slack alert."
    continue
  fi

  MESSAGE="🔐 *Scan Complete*\n\
  *Account:* \`$ACCOUNT_ID\`\n\
  ✅ $PASSED, ❌ $FAILED\n\
  🕒 $(date -u '+%Y-%m-%d %H:%M UTC')"

# Extract category breakdown from scan output
category_summary=$(echo "$scan_output" | sed -n '/📊 Failures by Category:/,$p' | tail -n +2)

# Optional: debug print
echo "🧾 Category Breakdown:"
echo "$category_summary"

# Send Slack alert with full details
./slack-notify.sh "$ACCOUNT_ID" "$pass_count" "$fail_count" "$category_summary"


  # Optional: Wait to avoid throttling
  sleep 2

done < accounts.txt

echo -e "\🚀 All accounts scanned."

