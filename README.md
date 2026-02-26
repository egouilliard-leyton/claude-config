# claude-config

Shared Claude Code configuration — skills and templates for bootstrapping any project.

## What's included

| Path | What it does |
|------|-------------|
| `skills/init-claude/` | `/init-claude` — bootstraps a `.claude/` directory in any project |
| `skills/update-claude/` | `/update-claude` — refreshes template files in an existing project |
| `templates/agents/` | 6 general-purpose agent definitions (code-reviewer, pr-test-analyzer, …) |
| `templates/commands/` | 10+ commands (commit, create-pr, review-pr, implement, plan, …) |
| `templates/skills/` | agent-browser, build-with-agent-team, update-claude |

## Installation

```bash
git clone git@github.com:yourorg/claude-config.git
cd claude-config
chmod +x install.sh
./install.sh
```

`install.sh` symlinks skills and templates into `~/.claude/`. Symlinks mean you get updates automatically with `git pull` — no reinstall needed.

The script is safe on existing setups: it only touches the items it owns and warns if something already exists as a real directory.

## Getting updates

```bash
git pull
# That's it — symlinks pick up changes immediately.
```

## Using it

Open Claude Code in any project and run:

```
/init-claude
```

This copies the templates into `.claude/` and generates project-specific files (`prime.md`, `validate.md`, `settings.local.json`) by analysing the codebase.

To update template files in an existing project after `git pull`:

```
/update-claude
```

## Verification

After running `install.sh`, confirm setup:

1. Open Claude Code in any project
2. Run `/init-claude`
3. Check that `.claude/commands/prime.md`, `.claude/commands/validate.md`, and `.claude/settings.local.json` are generated

## What's excluded

Personal or machine-specific config is intentionally not in this repo:

- `~/.claude/settings.json` (personal plugins, API keys)
- `~/.claude/hooks/` (personal workflow hooks)
- `~/.claude/projects/` (per-machine session data)
- Skills with personal paths (email-processor, meeting-summarizer, etc.)
