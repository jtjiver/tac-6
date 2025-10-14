#!/bin/bash
# Test API protection by attempting to run an automated ADW script

echo "=========================================="
echo "Testing API Credit Protection"
echo "=========================================="
echo ""
echo "Attempting to run: python3 adw_plan.py 12"
echo ""
echo "Expected: Should be BLOCKED with warning"
echo "=========================================="
echo ""

cd "$(dirname "$0")"

# Try to run the automated plan script (should be blocked)
python3 adw_plan.py 12 2>&1 | head -60

echo ""
echo "=========================================="
echo "Test Complete"
echo "=========================================="
