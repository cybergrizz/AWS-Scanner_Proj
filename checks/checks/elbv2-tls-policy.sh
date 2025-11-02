#!/bin/bash

CATEGORY="ELBv2"

echo "[ELBv2] Checking TLS policy strength on HTTPS listeners..."

lbs=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[*].LoadBalancerArn' --output text 2>/dev/null)
fail=0

for lb in $lbs; do
  listeners=$(aws elbv2 describe-listeners --load-balancer-arn "$lb" --query 'Listeners[*]' --output json)
  echo "$listeners" | jq -c '.[]' | while read listener; do
    proto=$(echo "$listener" | jq -r '.Protocol')
    policy=$(echo "$listener" | jq -r '.SslPolicy // empty')

    if [ "$proto" == "HTTPS" ]; then
      if [[ "$policy" =~ TLS_1_0|TLS_1_1 ]]; then
        echo "❌ $lb uses weak TLS policy: $policy"
        fail=1
      else
        echo "✅ $lb uses secure TLS policy: $policy"
      fi
    fi
  done
done

exit $fail

