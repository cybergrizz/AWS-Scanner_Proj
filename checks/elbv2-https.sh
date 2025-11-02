#!/bin/bash

CATEGORY="ELBv2"

echo "[ELBv2] Checking for HTTP-only listeners (unencrypted traffic)..."

lbs=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[*].LoadBalancerArn' --output text 2>/dev/null)
fail=0

for lb in $lbs; do
  listeners=$(aws elbv2 describe-listeners --load-balancer-arn "$lb" \
    --query 'Listeners[*].Protocol' --output text)

  for proto in $listeners; do
    if [ "$proto" == "HTTP" ]; then
      echo "❌ $lb is using an unencrypted HTTP listener"
      fail=1
    fi
  done
done

exit $fail

