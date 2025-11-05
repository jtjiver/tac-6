#!/usr/bin/env node

/**
 * ADW Framework Interactive Setup
 * Guides users through framework configuration for their project
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const readline = require('readline');

// Colors for terminal output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

// Helper to print colored text
const print = {
  info: (msg) => console.log(`${colors.blue}ℹ${colors.reset}  ${msg}`),
  success: (msg) => console.log(`${colors.green}✓${colors.reset}  ${msg}`),
  warn: (msg) => console.log(`${colors.yellow}⚠${colors.reset}  ${msg}`),
  error: (msg) => console.log(`${colors.red}✗${colors.reset}  ${msg}`),
  header: (msg) => console.log(`\n${colors.bright}${colors.cyan}${msg}${colors.reset}\n`),
  step: (num, msg) => console.log(`\n${colors.bright}Step ${num}:${colors.reset} ${msg}\n`),
};

// Create readline interface
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

// Promisify question
const question = (query) => new Promise((resolve) => rl.question(query, resolve));

// Check if command exists
function commandExists(cmd) {
  try {
    execSync(`which ${cmd}`, { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

// Main setup function
async function setup() {
  console.clear();

  print.header('╔════════════════════════════════════════════════╗');
  print.header('║   ADW Framework Interactive Setup             ║');
  print.header('║   AI Developer Workflow Configuration         ║');
  print.header('╚════════════════════════════════════════════════╝');

  console.log('');
  console.log('This wizard will help you configure the ADW Framework for your project.');
  console.log('');

  // Step 1: Check Prerequisites
  print.step(1, 'Checking Prerequisites');

  const checks = [
    { name: 'Python', cmd: 'python3', required: true },
    { name: 'uv', cmd: 'uv', required: true },
    { name: 'Node.js', cmd: 'node', required: true },
    { name: 'Git', cmd: 'git', required: true },
    { name: 'GitHub CLI', cmd: 'gh', required: true },
    { name: 'Claude Code CLI', cmd: 'claude', required: false },
  ];

  let allRequired = true;
  for (const check of checks) {
    if (commandExists(check.cmd)) {
      print.success(`${check.name} is installed`);
    } else {
      if (check.required) {
        print.error(`${check.name} is required but not installed`);
        allRequired = false;
      } else {
        print.warn(`${check.name} is not installed (optional but recommended)`);
      }
    }
  }

  if (!allRequired) {
    console.log('');
    print.error('Please install missing requirements and run setup again.');
    console.log('');
    console.log('Installation guides:');
    console.log('  - uv: curl -LsSf https://astral.sh/uv/install.sh | sh');
    console.log('  - GitHub CLI: brew install gh (or https://cli.github.com)');
    console.log('  - Claude Code: https://docs.anthropic.com/claude/docs/claude-code');
    rl.close();
    process.exit(1);
  }

  // Step 2: Project Information
  print.step(2, 'Project Information');

  // Get current directory name as default
  const currentDirName = path.basename(process.cwd());
  const defaultProjectName = currentDirName;

  const projectNameInput = await question(`Enter your project name [${defaultProjectName}]: `);
  const projectName = projectNameInput.trim() || defaultProjectName;

  // Auto-detect GitHub username
  let githubUsername = '';
  try {
    githubUsername = execSync('gh api user --jq .login', { encoding: 'utf8' }).trim();
  } catch (error) {
    // Fall back to git config if gh CLI fails
    try {
      const gitRemote = execSync('git config --get remote.origin.url', { encoding: 'utf8' }).trim();
      const match = gitRemote.match(/github\.com[:/]([^/]+)/);
      if (match) {
        githubUsername = match[1];
      }
    } catch {}
  }

  // Generate default repo URL
  const defaultRepoUrl = githubUsername
    ? `https://github.com/${githubUsername}/${projectName}`
    : '';

  const projectRepoInput = await question(
    defaultRepoUrl
      ? `Enter your GitHub repository URL [${defaultRepoUrl}]: `
      : 'Enter your GitHub repository URL (https://github.com/owner/repo): '
  );
  const projectRepo = projectRepoInput.trim() || defaultRepoUrl;

  const useWebhook = (await question('Will you use webhook automation? (y/N): ')).toLowerCase() === 'y';

  // Step 3: Execution Mode
  print.step(3, 'Choose Execution Mode');

  console.log('ADW Framework supports two execution modes:');
  console.log('');
  console.log(`${colors.green}1. Interactive Mode (Recommended for Development)${colors.reset}`);
  console.log('   - Zero cost ($0, covered by Claude Pro)');
  console.log('   - 2-4x faster execution');
  console.log('   - Real-time visibility');
  console.log('   - Use: claude -p "/adw_guide_plan 123"');
  console.log('');
  console.log(`${colors.yellow}2. Automated Mode (For CI/CD)${colors.reset}`);
  console.log('   - API-based automation ($7-25 per workflow)');
  console.log('   - Hands-free operation');
  console.log('   - Webhook integration');
  console.log('   - Use: uv run adw_plan.py 123');
  console.log('');
  console.log(`${colors.blue}3. Both Modes${colors.reset}`);
  console.log('   - Best of both worlds');
  console.log('   - Interactive for development, automated for production');
  console.log('');

  const modeChoice = await question('Choose mode (1/2/3): ');
  const mode = modeChoice === '1' ? 'interactive' : modeChoice === '2' ? 'automated' : 'both';

  // Step 4: API Configuration
  let anthropicKey = '';
  if (mode === 'automated' || mode === 'both') {
    print.step(4, 'API Configuration (for Automated Mode)');

    anthropicKey = await question('Enter your Anthropic API key (sk-ant-...): ');

    if (!anthropicKey.startsWith('sk-ant-')) {
      print.warn('API key format looks incorrect, but continuing...');
    }
  }

  // Step 5: Optional Integrations
  print.step(mode === 'interactive' ? 4 : 5, 'Optional Integrations');

  const useR2 = (await question('Use Cloudflare R2 for screenshot uploads? (y/N): ')).toLowerCase() === 'y';

  let r2Config = {};
  if (useR2) {
    r2Config.accountId = await question('R2 Account ID: ');
    r2Config.accessKeyId = await question('R2 Access Key ID: ');
    r2Config.secretAccessKey = await question('R2 Secret Access Key: ');
    r2Config.bucketName = await question('R2 Bucket Name: ');
  }

  const useGithubPat = (await question('Use custom GitHub PAT (different from gh CLI)? (y/N): ')).toLowerCase() === 'y';
  let githubPat = '';
  if (useGithubPat) {
    githubPat = await question('GitHub PAT (ghp_...): ');
  }

  // Step 6: Create Configuration Files
  print.step(mode === 'interactive' ? 5 : 6, 'Creating Configuration Files');

  // Create .env file
  const envContent = `# ADW Framework Environment Configuration
# Generated by setup wizard

# Project Configuration
PROJECT_NAME=${projectName}
GITHUB_REPO_URL=${projectRepo}

${mode !== 'interactive' ? `# Anthropic API (Optional with Claude Code Pro subscription)
ANTHROPIC_API_KEY=${anthropicKey}
` : '# Anthropic API (Optional with Claude Code Pro subscription)\n# ANTHROPIC_API_KEY=sk-ant-...'}

${githubPat ? `# GitHub PAT (Optional - different account than gh CLI)
GITHUB_PAT=${githubPat}
` : '# GitHub PAT (Optional)\n# GITHUB_PAT=ghp_...'}

${useR2 ? `# Cloudflare R2 (Optional - screenshot uploads)
CLOUDFLARE_R2_ACCOUNT_ID=${r2Config.accountId}
CLOUDFLARE_R2_ACCESS_KEY_ID=${r2Config.accessKeyId}
CLOUDFLARE_R2_SECRET_ACCESS_KEY=${r2Config.secretAccessKey}
CLOUDFLARE_R2_BUCKET_NAME=${r2Config.bucketName}
` : '# Cloudflare R2 (Optional)\n# CLOUDFLARE_R2_ACCOUNT_ID=\n# CLOUDFLARE_R2_ACCESS_KEY_ID=\n# CLOUDFLARE_R2_SECRET_ACCESS_KEY=\n# CLOUDFLARE_R2_BUCKET_NAME='}

# Execution Mode
ADW_MODE=${mode}
`;

  fs.writeFileSync('.env', envContent);
  print.success('Created .env file');

  // Create .mcp.json if it doesn't exist
  if (!fs.existsSync('.mcp.json')) {
    fs.copyFileSync('.mcp.json.sample', '.mcp.json');
    print.success('Created .mcp.json from template');
  } else {
    print.info('.mcp.json already exists (not overwriting)');
  }

  // Update .claude/settings.json with repository path
  if (fs.existsSync('.claude/settings.json')) {
    try {
      const settings = JSON.parse(fs.readFileSync('.claude/settings.json', 'utf8'));

      // Update any repository-specific patterns
      if (settings.toolPermissions?.bash?.allowedCommands) {
        // This is project-agnostic, so we don't need to change much
        print.info('Claude settings.json already configured');
      }

      print.success('Verified .claude/settings.json');
    } catch (error) {
      print.warn('Could not parse .claude/settings.json: ' + error.message);
    }
  }

  // Step 7: Install Dependencies
  print.step(mode === 'interactive' ? 6 : 7, 'Installing Dependencies');

  console.log('Installing Playwright for E2E testing...');
  try {
    execSync('npm install', { stdio: 'inherit' });
    print.success('Playwright installed');
  } catch (error) {
    print.error('Failed to install dependencies: ' + error.message);
  }

  // Step 7.5: Initialize Git and Create GitHub Repository
  const nextStep = mode === 'interactive' ? 7 : 8;
  print.step(nextStep, 'Initialize Git Repository');

  const createGitHub = (await question('Create private GitHub repository and push? (Y/n): ')).toLowerCase() !== 'n';

  if (createGitHub) {
    try {
      // Check if already a git repo
      let isGitRepo = false;
      try {
        execSync('git rev-parse --git-dir', { stdio: 'ignore' });
        isGitRepo = true;
      } catch {}

      if (!isGitRepo) {
        console.log('Initializing git repository...');
        execSync('git init', { stdio: 'inherit' });
        print.success('Git repository initialized');
      } else {
        print.info('Already a git repository');
      }

      // Create .gitignore if it doesn't have critical entries
      const gitignorePath = '.gitignore';
      let gitignoreContent = fs.existsSync(gitignorePath)
        ? fs.readFileSync(gitignorePath, 'utf8')
        : '';

      if (!gitignoreContent.includes('.env')) {
        gitignoreContent += '\n# Environment variables\n.env\n.env.local\n';
        fs.writeFileSync(gitignorePath, gitignoreContent);
        print.success('Updated .gitignore');
      }

      // Add all files
      console.log('Adding files to git...');
      execSync('git add .', { stdio: 'inherit' });
      print.success('Files staged');

      // Create initial commit
      console.log('Creating initial commit...');
      execSync('git commit -m "Initial commit: ADW Framework setup\n\n🤖 Generated with ADW Framework Setup Wizard\n\nIncludes:\n- ADW System (core modules, workflows, triggers)\n- Claude Code Configuration (settings, hooks, commands)\n- Testing Infrastructure (Playwright MCP, E2E templates)\n- Documentation and guides"', { stdio: 'inherit' });
      print.success('Initial commit created');

      // Extract repo owner and name from URL
      const repoMatch = projectRepo.match(/github\.com[:/]([^/]+)\/(.+?)(\.git)?$/);
      if (repoMatch) {
        const repoOwner = repoMatch[1];
        const repoName = repoMatch[2];

        // Create GitHub repository
        console.log(`Creating private GitHub repository: ${repoOwner}/${repoName}...`);
        try {
          execSync(`gh repo create ${repoOwner}/${repoName} --private --source=. --remote=origin --push`, {
            stdio: 'inherit'
          });
          print.success(`Repository created and pushed to ${projectRepo}`);
        } catch (error) {
          // If repo already exists, just add remote and push
          print.warn('Repository might already exist, trying to add remote and push...');
          try {
            execSync(`git remote add origin ${projectRepo}`, { stdio: 'ignore' });
          } catch {}
          try {
            execSync('git branch -M main', { stdio: 'inherit' });
            execSync('git push -u origin main', { stdio: 'inherit' });
            print.success('Pushed to existing repository');
          } catch (pushError) {
            print.error('Failed to push: ' + pushError.message);
            print.info('You can manually push later with: git push -u origin main');
          }
        }
      } else {
        print.warn('Could not parse repository URL for GitHub creation');
        print.info('You can manually create the repository and push later');
      }

    } catch (error) {
      print.error('Failed to initialize git: ' + error.message);
      print.info('You can manually initialize git and push later');
    }
  } else {
    print.info('Skipping GitHub repository creation');
    print.info('You can create it later with: gh repo create --private --source=. --remote=origin');
  }

  // Step 8: Create Quick Start Guide
  print.step(mode === 'interactive' ? 8 : 9, 'Creating Quick Start Guide');

  const quickStartContent = `# Quick Start Guide - ${projectName}

## Your Configuration

- **Execution Mode**: ${mode}
- **GitHub Repo**: ${projectRepo}
- **Webhook**: ${useWebhook ? 'Enabled' : 'Disabled'}
- **Screenshot Upload**: ${useR2 ? 'Enabled (R2)' : 'Disabled'}

## Getting Started

### Interactive Mode (Zero Cost)

1. **Plan a feature**:
   \`\`\`bash
   claude -p "/adw_guide_plan <issue-number>"
   \`\`\`

2. **Build the implementation**:
   \`\`\`bash
   claude -p "/adw_guide_build <adw-id>"
   \`\`\`

3. **Run tests**:
   \`\`\`bash
   claude -p "/adw_guide_test <adw-id>"
   \`\`\`

4. **Create PR**:
   \`\`\`bash
   claude -p "/adw_guide_pr <adw-id>"
   \`\`\`

${mode !== 'interactive' ? `### Automated Mode (API-Based)

1. **Complete workflow for an issue**:
   \`\`\`bash
   cd adws
   uv run adw_plan_build_test_review.py <issue-number>
   \`\`\`

2. **Individual phases**:
   \`\`\`bash
   # Planning only
   uv run adw_plan.py <issue-number>

   # Build only (requires existing plan)
   uv run adw_build.py <issue-number>

   # Test only (requires implementation)
   uv run adw_test.py <issue-number>
   \`\`\`

${useWebhook ? `3. **Start webhook server**:
   \`\`\`bash
   cd adws
   uv run adw_triggers/trigger_webhook.py
   \`\`\`
` : ''}` : ''}

## Next Steps

1. **Review documentation**:
   - \`docs/README.md\` - Documentation index
   - \`docs/ADW_AGENTS_GUIDE.md\` - Agent catalog
   - \`docs/COEXISTENCE_GUIDE.md\` - Mode comparison

2. **Create your first E2E test**:
   - Add test to \`.claude/commands/e2e/\`
   - Follow template in \`.claude/commands/e2e/README.md\`

3. **Customize planning templates**:
   - Edit \`.claude/commands/feature.md\`
   - Edit \`.claude/commands/bug.md\`
   - Edit \`.claude/commands/chore.md\`

4. **Configure GitHub webhook** (if using automated mode):
   - Repository Settings → Webhooks → Add webhook
   - Payload URL: Your server URL
   - Content type: application/json
   - Events: Issues, Pull requests, Issue comments

## Troubleshooting

### Interactive mode not working
- Verify Claude Code CLI is installed: \`claude --version\`
- Check you have Claude Pro subscription
- Ensure you're in the project directory

### Automated mode API errors
- With Claude Code Pro: No API key needed, uses authenticated session
- Without Pro: Verify API key in \`.env\`: \`ANTHROPIC_API_KEY\`
- Check API key has not expired (if using API key)
- Review \`agents/<adw-id>/logs/\` for error details

### E2E tests failing
- Ensure application is running
- Check Playwright browser is installed: \`npx playwright install\`
- Review screenshots in \`agents/<adw-id>/<agent>/img/\`

## Cost Tracking

- **Interactive mode**: $0 (Claude Pro)
- **Automated mode**: See \`docs/COMPARISON_SUMMARY.md\`
  - Planning: ~$2-8 per workflow
  - Build: ~$3-10 per workflow
  - Test: ~$2-7 per workflow

## Support

- Documentation: \`docs/README.md\`
- Examples: See \`.claude/commands/\` for command templates
- Issues: GitHub repository issues
`;

  fs.writeFileSync('QUICKSTART.md', quickStartContent);
  print.success('Created QUICKSTART.md');

  // Final Summary
  console.log('');
  print.header('╔════════════════════════════════════════════════╗');
  print.header('║  ✓ Setup Complete!                            ║');
  print.header('╚════════════════════════════════════════════════╝');
  console.log('');

  print.success('ADW Framework is configured and ready to use!');
  console.log('');

  console.log(`${colors.bright}Configuration Summary:${colors.reset}`);
  console.log(`  Project: ${projectName}`);
  console.log(`  Mode: ${mode}`);
  console.log(`  Repository: ${projectRepo}`);
  console.log(`  Files created: .env, QUICKSTART.md`);
  console.log('');

  if (mode === 'interactive' || mode === 'both') {
    console.log(`${colors.green}${colors.bright}Try it now (Interactive - Zero Cost):${colors.reset}`);
    console.log(`  ${colors.cyan}claude -p "/adw_guide_plan <issue-number>"${colors.reset}`);
    console.log('');
  }

  if (mode === 'automated' || mode === 'both') {
    console.log(`${colors.yellow}${colors.bright}Try it now (Automated):${colors.reset}`);
    console.log(`  ${colors.cyan}cd adws && uv run adw_plan.py <issue-number>${colors.reset}`);
    console.log('');
  }

  console.log(`${colors.bright}Next Steps:${colors.reset}`);
  console.log('  1. Read QUICKSTART.md for usage examples');
  console.log('  2. Review docs/README.md for complete documentation');
  console.log('  3. Create your first E2E test in .claude/commands/e2e/');
  console.log('  4. Customize planning templates in .claude/commands/');
  console.log('');

  print.info('Happy coding with AI assistance! 🚀');
  console.log('');

  rl.close();
}

// Run setup
setup().catch((error) => {
  console.error('');
  print.error('Setup failed: ' + error.message);
  console.error('');
  rl.close();
  process.exit(1);
});
