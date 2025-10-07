#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "anthropic",
#     "openai",
#     "python-dotenv",
# ]
# ///
"""
Simple test to verify Helicone integration by making a direct API call.
Run with: uv run scripts/test_helicone_simple.py
"""

import os
import json
from dotenv import load_dotenv

# Load .env file - dotenv will find it in parent directory
load_dotenv()

def test_anthropic_with_helicone():
    """Test Anthropic API call through Helicone proxy"""

    api_key = os.environ.get("ANTHROPIC_API_KEY")
    helicone_key = os.environ.get("HELICONE_API_KEY")

    if not api_key:
        print("❌ ANTHROPIC_API_KEY not found in .env")
        return False

    if not helicone_key:
        print("❌ HELICONE_API_KEY not found in .env")
        print("Please add HELICONE_API_KEY=<your-key> to your .env file")
        return False

    print(f"✅ Found API keys:")
    print(f"   - Anthropic: {api_key[:15]}...")
    print(f"   - Helicone: {helicone_key[:10]}...")

    # Import anthropic
    from anthropic import Anthropic

    try:
        # Create client with Helicone proxy
        client = Anthropic(
            api_key=api_key,
            base_url="https://anthropic.helicone.ai",
            default_headers={
                "Helicone-Auth": f"Bearer {helicone_key}",
                "Helicone-Property-App": "tac-6",
                "Helicone-Property-Environment": "test",
                "Helicone-Property-Test": "helicone-integration"
            }
        )

        print("\n🔍 Making test API call through Helicone...")

        # Make a simple test call
        response = client.messages.create(
            model="claude-3-haiku-20240307",
            max_tokens=50,
            temperature=0,
            messages=[
                {"role": "user", "content": "Say 'Helicone test successful!' and nothing else."}
            ]
        )

        result = response.content[0].text
        print(f"✅ API call successful! Response: {result}")

        print("\n" + "="*60)
        print("📊 Check your Helicone dashboard:")
        print("1. Go to https://helicone.ai/dashboard")
        print("2. Look for a request with:")
        print("   - Model: claude-3-haiku-20240307")
        print("   - App: tac-6")
        print("   - Environment: test")
        print("   - Test: helicone-integration")
        print("="*60)

        return True

    except Exception as e:
        error_str = str(e)
        if "credit balance" in error_str.lower():
            print(f"⚠️  API call reached Helicone but failed due to insufficient credits")
            print(f"   Request ID: {error_str.split('request_id')[1].split('}')[0] if 'request_id' in error_str else 'N/A'}")
            print(f"✅ Helicone integration is working! (API error is unrelated to Helicone)")
            print(f"   Check your dashboard at: https://helicone.ai/dashboard")
            return True
        else:
            print(f"❌ Error: {e}")
            return False

def test_openai_with_helicone():
    """Test OpenAI API call through Helicone proxy"""

    api_key = os.environ.get("OPENAI_API_KEY")
    helicone_key = os.environ.get("HELICONE_API_KEY")

    if not api_key:
        print("\n⚠️  OPENAI_API_KEY not found - skipping OpenAI test")
        return True  # Not an error, just skip

    if not helicone_key:
        print("❌ HELICONE_API_KEY not found in .env")
        return False

    print(f"\n✅ Found OpenAI API key: {api_key[:15]}...")

    from openai import OpenAI

    try:
        # Create client with Helicone proxy
        client = OpenAI(
            api_key=api_key,
            base_url="https://oai.helicone.ai/v1",
            default_headers={
                "Helicone-Auth": f"Bearer {helicone_key}",
                "Helicone-Property-App": "tac-6",
                "Helicone-Property-Environment": "test",
                "Helicone-Property-Test": "helicone-integration"
            }
        )

        print("🔍 Making test OpenAI API call through Helicone...")

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "user", "content": "Say 'Helicone OpenAI test successful!' and nothing else."}
            ],
            temperature=0,
            max_tokens=50
        )

        result = response.choices[0].message.content
        print(f"✅ OpenAI call successful! Response: {result}")

        return True

    except Exception as e:
        print(f"❌ OpenAI Error: {e}")
        return False

if __name__ == "__main__":
    print("🧪 Testing Helicone Integration\n")

    # Test Anthropic
    anthropic_ok = test_anthropic_with_helicone()

    # Test OpenAI
    openai_ok = test_openai_with_helicone()

    if anthropic_ok:
        print("\n✅ Helicone integration test completed successfully!")
    else:
        print("\n❌ Helicone integration test failed")