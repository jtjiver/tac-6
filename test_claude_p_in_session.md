# Test: Does claude -p within a Claude session use API?

## Test Plan

We'll test if `claude -p` behaves differently when:
1. Run standalone from terminal (uses API - confirmed)
2. Run via Bash tool from within Claude session (unknown)

## Test 1: Standalone (Already Confirmed)

```bash
# From terminal, not in Claude session
claude -p "What is 2+2?"
# Result: API Error (we have no credits)
```

## Test 2: Within Claude Session

Run this test:

1. Start a Claude session
2. Use Bash tool to run `claude -p "test"`
3. Check if it works or errors

Expected results:
- If uses API → Should fail with "no credits" error
- If uses Pro subscription → Should work fine

## The Test

Please run:
```bash
echo "Testing if claude -p uses API or Pro when run from Bash tool..."
claude -p "Reply with just the word SUCCESS and nothing else"
```

If this returns "SUCCESS", then claude -p within a Claude session uses Pro subscription!
If it errors about API credits, then it uses API.

## Test Result (2025-10-14)

**RESULT**: API Error - User's theory is INCORRECT

```
Testing if claude -p uses API or Pro when run from Bash tool...
API Error: 400 {"type":"error","error":{"type":"invalid_request_error","message":"You have reached your specified API usage limits. You will regain access on 2025-11-01 at 00:00 UTC."},"request_id":"req_011CU6edGUTKmNecNxRcjBuX"}
```

### Conclusion

When `claude -p` is run from within a Claude Code session via the Bash tool:
- ❌ It does NOT inherit the parent session's Pro subscription authentication
- ✅ It ALWAYS uses `ANTHROPIC_API_KEY` from environment (which costs API credits)
- ⚠️ This means ANY `claude -p` command will attempt to use API, regardless of context

### Remaining Mystery

On the user's other server, `Bash(claude -p "/generate_branch_name ...")` was detected by the monitor but succeeded despite zero API credits.

**Possible explanations:**
1. The other server doesn't have `ANTHROPIC_API_KEY` set → used Pro subscription
2. There was a cached response or the command failed silently
3. The workflow on that server isn't actually using `claude -p` directly

**Action Required:** Check if `/adw_guide_*` commands actually execute `claude -p` via Bash tool, or if those references are documentation only.

## Current Evidence

On your other server where `/adw_guide_plan` worked:
- Monitor detected `claude -p` commands
- But you have zero API credits
- Yet it completed successfully
- Suggests: Pro subscription was used, not API!

## The Real Question

Is the behavior:
- **API key priority**: If ANTHROPIC_API_KEY is set → use API (fails for us)
- **Session inheritance**: If run from Claude session → use parent session auth (Pro)

Let's find out!
