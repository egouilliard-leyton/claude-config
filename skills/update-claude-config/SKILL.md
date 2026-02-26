---
name: update-claude-config
description: Pull the latest claude-config from GitHub and re-apply all skills, templates, and GSD patches.
allowed-tools: Bash
---

# Update Claude Config

Pull the latest changes from the shared `claude-config` repo and re-apply everything.

## Run the update script

```bash
bash ~/.claude/skills/update-claude-config/update-claude-config.sh
```

The script will:
1. Find the `claude-config` repo via the `init-claude` symlink
2. Run `git pull` to get the latest changes
3. Re-run `install.sh` which re-links skills/templates and re-applies GSD patches

## Report

Tell the user what changed (from git pull output) and confirm everything was applied successfully.
