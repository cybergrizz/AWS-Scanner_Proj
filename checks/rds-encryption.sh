#!/bin/bash

CATEGORY="RDS"

echo "[RDS] Checking for unencrypted RDS databases..."

instances=$(aws rds describe-db-instances --query 'DBInstances[*].DBInstanceIdentifier' --output text)

fail=0
for db in $instances; do
  encrypted=$(aws rds describe-db-instances \
    --db-instance-identifier "$db" \
    --query 'DBInstances[0].StorageEncrypted' --output text)

  if [ "$encrypted" == "False" ]; then
    echo "❌ $db is NOT encrypted"
    fail=1
  else
    echo "✅ $db is encrypted"
  fi
done

exit $fail

