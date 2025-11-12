# Install & Prime

## Read
.env.sample (never read .env)
./app/server/.env.sample (never read .env)

## Read and Execute
.claude/commands/prime.md

## Run
- Think through each of these steps to make sure you don't miss anything.
- Remove the existing git remote: `git remote remove origin`
- Initialize a new git repository: `git init`
- Install FE and BE dependencies
- Run `./scripts/copy_dot_env.sh` to copy the .env file from the tac-2 directory. Note, the tac-2 codebase may not exists, proceed either way.
- Run `./scripts/reset_db.sh` to setup the database from the backup.db file
- On a background process, run `./scripts/start.sh` with 'nohup' or a 'subshell' to start the server so you don't get stuck

## Report
- Output the work you've just done in a concise bullet point list.
- Instruct the user to fill out the root level ./.env based on .env.sample.
- If `./app/server/.env` does not exist, instruct the user to fill out `./app/server/.env` based on `./app/server/.env.sample`
- If `./env` does not exist, instruct the user to fill out `./env` based on `./env.sample`
- Mention the url of the frontend application we can visit based on `scripts/start.sh`

### IMPORTANT: Setup Git Remote for ADW

**The install process removed the git remote. You MUST set this up for ADW to work.**

ADW (AI Developer Workflow) requires a git remote to create branches, commits, and pull requests. Setup your GitHub repository now:

**Option 1: Using HTTPS (Recommended - works with gh auth)**
```bash
git remote add origin https://github.com/yourusername/yourrepo.git
git push -u origin main
```

**Option 2: Using SSH (Requires SSH keys configured)**
```bash
git remote add origin git@github.com:yourusername/yourrepo.git
git push -u origin main
```

**Example with actual repository:**
```bash
# If your repo is: github.com/jtjiver/tac-6
git remote add origin https://github.com/jtjiver/tac-6.git
git push -u origin main
```

Without this, ADW commands will fail with: "No git remote 'origin' found"

- Mention: If you want to upload images to github during the review process setup cloudflare for public image access you can setup your cloudflare environment variables. See .env.sample for the variables.