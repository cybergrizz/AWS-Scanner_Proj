#!/opt/homebrew/bin/bash
# scanner.sh
# Modular AWS compliance scanner

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0
declare -A CATEGORY_FAILS
declare -A CATEGORY_TOTALS


run_check() {
  local check_script="$1"

  CATEGORY=$(grep -E '^CATEGORY=' "$check_script" | cut -d'=' -f2 | tr -d '"')
  CATEGORY=${CATEGORY:-General}  # Default to "General" if not set

  echo -e "\n===================================="
  echo "Running check: $check_script"
  echo "Category: $CATEGORY"
  echo "===================================="

  bash "$check_script"
  result=$?

  ((CATEGORY_TOTALS["$CATEGORY"]++))


  if [ $? -eq 0 ]; then
    ((PASS_COUNT++))
  else
    ((FAIL_COUNT++))
  fi
}

for check in checks/*.sh; do
  run_check "$check"
  echo
done

TOTAL=$((PASS_COUNT + FAIL_COUNT))
echo -e "\n🔍 Scan complete. $TOTAL checks run."
echo -e "${GREEN}✅ $PASS_COUNT Passed${NC}, ${RED}❌ $FAIL_COUNT Failed${NC}"

echo "🔧 Timestamp: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

echo -e "\n📊 Failures by Category:"
for cat in "${!CATEGORY_TOTALS[@]}"; do
  fails=${CATEGORY_FAILS[$cat]:-0}
  total=${CATEGORY_TOTALS[$cat]}
  echo "  • $cat: $fails / $total failed"
done

exit 0

