#!/bin/bash

CATEGORY="RDS"

echo "[RDS] Checking for publicly accessible RDS databases..."

instances=$(aws rds describe-db-instances --query 'DBInstances[*].DBInstanceIdentifier' --output text)

fail=0
for db in $instances; do
  public=$(aws rds describe-db-instances \
    --db-instance-identifier "$db" \
    --query 'DBInstances[0].PubliclyAccessible' --output text)

  if [ "$public" == "True" ]; then
    echo "❌ $db is PUBLICLY accessible"
    fail=1
  else
    echo "✅ $db is private"
  fi
done

exit $fail

