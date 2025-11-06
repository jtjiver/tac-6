#!/bin/bash
# Test if claude -p uses API or Pro subscription

echo "Testing claude -p mode..."
echo ""
echo "Running: claude -p 'What is 2+2? Answer with just the number.'"
echo ""

# Run claude -p
claude -p "What is 2+2? Answer with just the number." 2>&1 | head -10

echo ""
echo "If this worked without API error, then claude -p uses Pro subscription"
echo "If you got an API error, then it uses API credits"
