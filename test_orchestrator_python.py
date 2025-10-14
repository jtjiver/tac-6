#!/usr/bin/env python3
"""
Test script to verify the orchestrator's command execution approach works.
This mimics what the orchestrator does when launching Claude Code sessions.
"""

import subprocess
import time
from datetime import datetime

def log(message):
    """Simple logging"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"[{timestamp}] {message}")

def test_command(cmd_string, test_name):
    """Test running a command the way the orchestrator does"""
    log(f"{'='*60}")
    log(f"Test: {test_name}")
    log(f"Command: {cmd_string}")
    log(f"{'='*60}")

    try:
        # This is exactly how the orchestrator launches Claude sessions
        process = subprocess.Popen(
            cmd_string,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        log(f"✓ Process started with PID: {process.pid}")

        # Wait for completion (with timeout)
        try:
            return_code = process.wait(timeout=30)

            if return_code == 0:
                log(f"✓ Process completed successfully (exit code: {return_code})")
                stdout = process.stdout.read() if process.stdout else ""
                if stdout:
                    log(f"Output preview: {stdout[:200]}")
                return True
            else:
                log(f"✗ Process failed (exit code: {return_code})")
                stderr = process.stderr.read() if process.stderr else ""
                if stderr:
                    log(f"Error: {stderr[:200]}")
                return False

        except subprocess.TimeoutExpired:
            log(f"⚠️  Process timeout - killing process")
            process.kill()
            return False

    except Exception as e:
        log(f"✗ Failed to start process: {e}")
        return False

    finally:
        log("")

def main():
    """Run tests"""
    log("="*60)
    log("Orchestrator Command Execution Test")
    log("="*60)
    log("")

    tests_passed = 0
    tests_total = 0

    # Test 1: Simple command without quotes
    tests_total += 1
    if test_command('claude /prime', 'Test 1: claude /prime (no quotes)'):
        tests_passed += 1

    time.sleep(2)

    # Test 2: Command with quotes (orchestrator style)
    tests_total += 1
    if test_command('claude "/prime"', 'Test 2: claude "/prime" (with quotes)'):
        tests_passed += 1

    time.sleep(2)

    # Test 3: Command with argument and quotes (full orchestrator style)
    tests_total += 1
    # Note: We can't actually test /adw_guide commands without a real ADW session
    # But we can test the command format with a hypothetical example
    log("="*60)
    log("Test 3: Command format check (not executed)")
    log("="*60)
    log('Format: claude "/adw_guide_test 777c8c50"')
    log("This is the format the orchestrator will use for ADW commands")
    log("")

    # Summary
    log("="*60)
    log(f"Test Results: {tests_passed}/{tests_total} passed")
    log("="*60)

    if tests_passed == tests_total - 1:  # -1 because test 3 is format check only
        log("✓ Tests passed! Orchestrator command format should work.")
        return 0
    else:
        log("✗ Some tests failed. Check output above.")
        return 1

if __name__ == '__main__':
    exit(main())
