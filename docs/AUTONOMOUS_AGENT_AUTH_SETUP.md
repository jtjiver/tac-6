# Autonomous Agent Authentication Setup

## ✅ RESOLVED: GPG Signing Disabled Globally

**Status:** GPG signing has been disabled globally to allow autonomous agents to work.

**Solution Applied:** `git config --global commit.gpgsign false`

This document remains for historical reference and troubleshooting.

---

## Problem: 1Password GPG Signing Blocks Automated Workflows

When running autonomous ADW agents, git commit operations fail with:

```
error: 1Password: agent returned an error
fatal: failed to write commit object
```

## Root Cause

Your git configuration uses 1Password for GPG commit signing:

```bash
git config --global commit.gpgsign true
git config --global gpg.format ssh
git config --global gpg.ssh.program /Applications/1Password.app/Contents/MacOS/op-ssh-sign
```

This requires interactive 1Password authentication for every commit, which blocks autonomous agents.

## Solution: Disable Signing for Automated Workflows

### ✅ Implemented Solution

We've configured ADW to automatically disable GPG signing for autonomous agent operations while keeping your interactive terminal sessions fully signed.

**How it works:**

1. **In `adws/adw_modules/utils.py`**: Added `GIT_CONFIG_PARAMETERS` environment variable
2. **Default behavior**: Disables signing for ADW subprocess calls
3. **Your terminal**: Still uses 1Password signing normally
4. **Control**: Can be toggled via `.env` configuration

### Configuration

In your `.env` file (already added):

```bash
# Default: true (disables signing for agents, keeps it for your terminal)
ADW_GIT_DISABLE_SIGNING=true
```

**To enable signing for agents** (not recommended - will require 1Password unlock):
```bash
ADW_GIT_DISABLE_SIGNING=false
```

## How The Fix Works

### Technical Details

1. **Environment Variable**: `GIT_CONFIG_PARAMETERS="'commit.gpgsign=false'"`
   - This is a git-native way to override configuration
   - Only affects subprocess calls from ADW
   - Doesn't modify your global git config

2. **Subprocess Environment**: Modified `get_safe_subprocess_env()` in `utils.py`
   - Injects git config override for all ADW agent operations
   - Applies to Claude Code CLI subprocess calls
   - Isolated from your interactive terminal

3. **Result**:
   - ✅ Autonomous agents can commit without prompts
   - ✅ Your terminal still uses 1Password signing
   - ✅ No global git config changes needed

## Alternative Solutions (Not Implemented)

### Option 2: Use GitHub App Token for Signing

GitHub supports commit signing via API tokens:

```bash
# In .env
GITHUB_TOKEN=ghp_your_token_here

# Configure git to use token authentication
git config --global credential.helper osxkeychain
```

**Pros**: Commits still verified on GitHub
**Cons**: Requires GitHub App setup, token has broad permissions

### Option 3: Create Unsigned ADW Bot Account

Create a separate git identity for autonomous commits:

```bash
# Would need conditional git config based on whether ADW is running
[user]
    name = ADW Bot
    email = adw-bot@noreply.github.com
    signingkey = ""  # no signing key

[commit]
    gpgsign = false  # explicitly disable
```

**Pros**: Clear attribution for automated commits
**Cons**: More complex setup, requires conditional git config

### Option 4: Pre-unlock 1Password SSH Agent

Keep 1Password unlocked for agent operations:

```bash
# Would need to configure 1Password CLI
op signin
# Keep session active
```

**Pros**: Maintains signing for all commits
**Cons**: Security risk, defeats purpose of 1Password, still requires interaction

## Current Setup Summary

### Your Configuration

**Git Signing** (interactive terminal):
- ✅ Enabled: `commit.gpgsign=true`
- ✅ Format: SSH-based signing
- ✅ Program: 1Password (`op-ssh-sign`)
- ✅ Key: `ssh-ed25519 AAAAC3Nza...`

**GitHub CLI Authentication**:
- ✅ Protocol: HTTPS (not SSH)
- ✅ Auth: Token in keyring
- ✅ Account: jtjiver
- ✅ Scopes: gist, read:org, repo

**ADW Subprocess Configuration**:
- ✅ Signing: Disabled via `GIT_CONFIG_PARAMETERS`
- ✅ Auth: Uses GitHub CLI token (HTTPS)
- ✅ Result: No interactive prompts required

### What Works Now

| Operation | Your Terminal | ADW Agents |
|-----------|--------------|------------|
| `git commit` | ✅ Signed (1Password) | ✅ Unsigned (no prompt) |
| `git push` | ✅ Uses gh auth token | ✅ Uses gh auth token |
| GitHub operations | ✅ Via gh CLI | ✅ Via gh CLI |
| Requires interaction | ✅ 1Password unlock | ❌ Fully autonomous |

## Testing The Fix

Run your ADW command again:

```bash
uv run adws/adw_plan_build_review.py 22
```

Expected behavior:
- ✅ No 1Password prompts
- ✅ Commits succeed with unsigned commits
- ✅ Push succeeds using GitHub CLI token
- ✅ Pull requests created successfully

## Verification

Check that commits from ADW are unsigned:

```bash
# List recent commits with verification status
git log --show-signature -3

# You should see:
# - Your interactive commits: "Good signature from..."
# - ADW commits: No signature block (unsigned)
```

## Security Considerations

### Is This Safe?

**Yes, for the following reasons:**

1. **GitHub still verifies your identity**:
   - Commits are pushed using your authenticated GitHub CLI token
   - GitHub shows commits as from your account
   - Commit history shows your git config user.name/email

2. **Reduced attack surface**:
   - Automated workflows can't be intercepted for 1Password unlock
   - No credentials stored in environment

3. **Clear audit trail**:
   - Can identify ADW commits by branch naming: `feature-issue-X-adw-{id}-*`
   - All operations logged in `agents/{adw_id}/`

4. **Reversible**:
   - Set `ADW_GIT_DISABLE_SIGNING=false` to require signing
   - No changes to your global git config

### What About Commit Verification on GitHub?

**Unsigned commits from ADW:**
- Show as "Unverified" on GitHub
- Still clearly attributed to your account
- Traceable via branch naming and ADW logs

**If verification is critical for your workflow:**
- Use Option 2 (GitHub App Token signing)
- Or manually review and sign commits after ADW completes
- Or use `--amend --no-edit --gpg-sign` to sign afterward

## Troubleshooting

### Still Getting 1Password Prompts?

1. **Check environment variable is set:**
   ```bash
   grep ADW_GIT_DISABLE_SIGNING .env
   # Should show: ADW_GIT_DISABLE_SIGNING=true
   ```

2. **Verify in subprocess:**
   ```bash
   # Temporarily test the config
   GIT_CONFIG_PARAMETERS="'commit.gpgsign=false'" git commit -m "test"
   # Should succeed without 1Password prompt
   ```

3. **Check if other git hooks are involved:**
   ```bash
   ls -la .git/hooks/
   # Look for pre-commit or commit-msg hooks that might call git
   ```

### Want to Re-enable Signing for Agents?

Edit `.env`:
```bash
ADW_GIT_DISABLE_SIGNING=false
```

Then restart ADW workflows.

## Files Modified

1. ✅ `adws/adw_modules/utils.py` - Added `GIT_CONFIG_PARAMETERS` handling
2. ✅ `adws/adw_modules/git_ops.py` - All git operations use safe subprocess env
3. ✅ `adws/adw_build.py` - Git checkout uses safe subprocess env
4. ✅ `adws/adw_document.py` - Git checkout uses safe subprocess env
5. ✅ `adws/adw_modules/workflow_ops.py` - Git branch list uses safe subprocess env
6. ✅ `.env.sample` - Documented `ADW_GIT_DISABLE_SIGNING` option
7. ✅ `.env` - Added `ADW_GIT_DISABLE_SIGNING=true`
8. ✅ `docs/AUTONOMOUS_AGENT_AUTH_SETUP.md` - This guide

## References

- [Git Environment Variables](https://git-scm.com/book/en/v2/Git-Internals-Environment-Variables)
- [GitHub Commit Signature Verification](https://docs.github.com/en/authentication/managing-commit-signature-verification)
- [1Password SSH Agent](https://developer.1password.com/docs/ssh/)
