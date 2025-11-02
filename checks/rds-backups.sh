#!/bin/bash

CATEGORY="RDS"

echo "[RDS] Checking for RDS databases without automated backups..."

instances=$(aws rds describe-db-instances --query 'DBInstances[*].DBInstanceIdentifier' --output text)

fail=0
for db in $instances; do
  retention=$(aws rds describe-db-instances \
    --db-instance-identifier "$db" \
    --query 'DBInstances[0].BackupRetentionPeriod' --output text)

  if [ "$retention" -eq 0 ]; then
    echo "❌ $db has NO automated backups enabled"
    fail=1
  else
    echo "✅ $db has backups enabled (retention: $retention days)"
  fi
done

exit $fail

