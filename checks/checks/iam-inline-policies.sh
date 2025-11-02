#!/bin/bash

CATEGORY="IAM"

echo "[IAM] Checking for IAM entities with inline policies..."

fail=0
users=$(aws iam list-users --query 'Users[*].UserName' --output text)
for user in $users; do
  policies=$(aws iam list-user-policies --user-name "$user" --query 'PolicyNames' --output text)
  if [ -n "$policies" ]; then
    echo "❌ User $user has inline policies: $policies"
    fail=1
  fi
done

roles=$(aws iam list-roles --query 'Roles[*].RoleName' --output text)
for role in $roles; do
  policies=$(aws iam list-role-policies --role-name "$role" --query 'PolicyNames' --output text)
  if [ -n "$policies" ]; then
    echo "❌ Role $role has inline policies: $policies"
    fail=1
  fi
done

groups=$(aws iam list-groups --query 'Groups[*].GroupName' --output text)
for group in $groups; do
  policies=$(aws iam list-group-policies --group-name "$group" --query 'PolicyNames' --output text)
  if [ -n "$policies" ]; then
    echo "❌ Group $group has inline policies: $policies"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "✅ No inline policies found"
fi

exit $fail

