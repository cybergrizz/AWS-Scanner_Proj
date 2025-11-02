#!/bin/bash

# Load from .env or paste directly
source .env

ACCOUNT_NAME="$1"
PASSED="$2"
FAILED="$3"
CATEGORY_BREAKDOWN="$4"
CATEGORY_BREAKDOWN="${CATEGORY_BREAKDOWN:-No category breakdown available}"

# Risk level calculation
if [ "$FAILED" -ge 6 ]; then
  RISK_EMOJI="🔴"
  RISK_LEVEL="High Risk"
elif [ "$FAILED" -ge 1 ]; then
  RISK_EMOJI="🟡"
  RISK_LEVEL="Medium Risk"
else
  RISK_EMOJI="🟢"
  RISK_LEVEL="Low Risk"
fi

MESSAGE="$RISK_EMOJI *$RISK_LEVEL*\n
*Account:* \`$ACCOUNT_NAME\`\n
*Results:* ✅ $PASSED, ❌ $FAILED, 📋 $((PASSED + FAILED)) Total\n
🗂 *By Category:*\n\`\`\`
$CATEGORY_BREAKDOWN
\`\`\`
🕒 *Time:* $(date -u '+%Y-%m-%d %H:%M UTC')"


curl -X POST -H 'Content-type: application/json' \
  --data "{\"text\":\"$MESSAGE\"}" \
  "$SLACK_WEBHOOK_URL"

