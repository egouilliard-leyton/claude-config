---
name: update-claude
description: Update .claude/ template files in the current project to the latest versions from ~/.claude/templates/. Skips regenerating project-specific files (prime.md, validate.md, settings.local.json). Run this after ~/.claude/templates/ has been updated to propagate changes to existing projects.
allowed-tools: Bash
---

# Update Claude Templates

You are updating the `.claude/` directory in the current project with the latest template files from `~/.claude/templates/`.

This is a targeted sync — it overwrites template-derived files (agents, commands, skills) with their latest versions but does **not** regenerate the project-specific files (`prime.md`, `validate.md`, `settings.local.json`) that were customized for this codebase.

## Step 1: Verify templates exist

Check that `~/.claude/templates/` is present. If it's missing, stop and tell the user: "Templates not found at ~/.claude/templates/. Run the init-claude skill first."

## Step 2: Run the update

```bash
bash ~/.claude/skills/init-claude/init-claude.sh --force
```

This overwrites all template files in `.claude/` with the latest versions from `~/.claude/templates/`.

## Step 3: Report

Tell the user:
- How many files were copied (from the script output)
- That `prime.md`, `validate.md`, and `settings.local.json` were **not** touched
- If they want to regenerate those project-specific files, run `/init-claude` instead
