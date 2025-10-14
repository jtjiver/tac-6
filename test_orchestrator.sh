#!/bin/bash
# Test script to verify orchestrator command execution works
# Tests with simple Claude Code built-in slash commands

echo "=================================="
echo "Testing Orchestrator Command Execution"
echo "=================================="
echo ""

# Test 1: Call /prime (simple command, no arguments)
echo "Test 1: Running claude /prime"
echo "-------------------------------"
claude "/prime"
echo ""
echo "✓ Test 1 completed"
echo ""

# Wait a bit between tests
sleep 2

# Test 2: Call /clear (another simple command)
echo "Test 2: Running claude /clear"
echo "-------------------------------"
claude "/clear"
echo ""
echo "✓ Test 2 completed"
echo ""

echo "=================================="
echo "All tests completed!"
echo "=================================="
echo ""
echo "If both tests ran without errors, the orchestrator"
echo "command format should work correctly."
