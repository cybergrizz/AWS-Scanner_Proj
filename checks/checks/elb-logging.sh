#!/bin/bash

CATEGORY="ELB"

echo "[ELB] Checking for ELBs without access logging enabled..."

lbs=$(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[*].LoadBalancerName' --output text 2>/dev/null)
fail=0

for lb in $lbs; do
  logging=$(aws elb describe-load-balancer-attributes --load-balancer-name "$lb" \
    --query 'LoadBalancerAttributes.AccessLog.Enabled' --output text)

  if [ "$logging" != "true" ]; then
    echo "❌ ELB $lb does NOT have access logging enabled"
    fail=1
  else
    echo "✅ ELB $lb has access logging enabled"
  fi
done

exit $fail

