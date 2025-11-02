#!/bin/bash

CATEGORY="EC2"

echo "[EC2] Checking for Security Groups with port 3389 (RDP) open..."

sg_ids=$(aws ec2 describe-security-groups --query 'SecurityGroups[*].GroupId' --output text)

for sg in $sg_ids; do
  is_open=$(aws ec2 describe-security-groups \
    --group-ids "$sg" \
    --query "SecurityGroups[*].IpPermissions[?FromPort==\`3389\` && IpRanges[?CidrIp=='0.0.0.0/0']]" \
    --output text)

  if [ -n "$is_open" ]; then
    echo "❌ SG $sg has port 3389 open to the world"
  else
    echo "✅ SG $sg is locked down for RDP"
  fi
done

