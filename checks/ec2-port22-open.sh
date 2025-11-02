#!/bin/bash

CATEGORY="EC2"

echo "[EC2] Checking for Security Groups with port 22 open..."

sg_ids=$(aws ec2 describe-security-groups --query 'SecurityGroups[*].GroupId' --output text)

for sg in $sg_ids; do
  is_open=$(aws ec2 describe-security-groups \
    --group-ids "$sg" \
    --query "SecurityGroups[*].IpPermissions[?FromPort==\`22\` && IpRanges[?CidrIp=='0.0.0.0/0']]" \
    --output text)

  if [ -n "$is_open" ]; then
    echo "❌ $sg has port 22 open to the world"
  else
    echo "✅ $sg does NOT expose port 22 publicly"
  fi
done

