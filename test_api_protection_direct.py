#!/usr/bin/env python3
"""Direct test of API protection in agent.py"""

import sys
import os

# Add adws to path
sys.path.insert(0, 'adws')

# Import the module
try:
    from adw_modules.agent import API_USAGE_ALLOWED, prompt_claude_code
    from adw_modules.data_types import AgentPromptRequest

    print("=" * 80)
    print("API CREDIT PROTECTION TEST")
    print("=" * 80)
    print()
    print(f"API_USAGE_ALLOWED environment variable: {os.getenv('ADW_ALLOW_API_USAGE', 'not set')}")
    print(f"API_USAGE_ALLOWED in agent.py: {API_USAGE_ALLOWED}")
    print()

    if API_USAGE_ALLOWED:
        print("⚠️  WARNING: API usage is ENABLED - commands will consume API credits!")
    else:
        print("✅ API usage is BLOCKED - protection active")

    print()
    print("=" * 80)
    print("Attempting to execute a test command...")
    print("=" * 80)
    print()

    # Try to execute a command
    request = AgentPromptRequest(
        prompt="/test example_test.py",
        adw_id="test1234",
        agent_name="test_protection",
        model="sonnet",
        dangerously_skip_permissions=True,
        output_file="/tmp/test_protection_output.jsonl"
    )

    response = prompt_claude_code(request)

    print()
    print("=" * 80)
    print("RESULT")
    print("=" * 80)
    print(f"Success: {response.success}")
    print(f"Output (first 100 chars): {response.output[:100]}")
    print()

    if not response.success and "BLOCKED" in response.output:
        print("✅ TEST PASSED: Command was blocked by API protection")
    elif response.success:
        print("❌ TEST FAILED: Command was executed (API credits may have been used!)")
    else:
        print("⚠️  TEST INCONCLUSIVE: Command failed for other reasons")

    print("=" * 80)

except ImportError as e:
    print(f"Import error: {e}")
    print()
    print("Run with: uv run test_api_protection_direct.py")
    sys.exit(1)
