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

## Workflow

This is the recommended way to use these tools day-to-day.

### Step 1 — Bootstrap a project (once per repo)

Open Claude Code in your project and run:

```
/init-claude
```

This generates three project-specific files by analysing your codebase:
- `.claude/commands/prime.md` — loads codebase context at the start of each session
- `.claude/commands/validate.md` — runs build + lint + tests
- `.claude/settings.local.json` — pre-approved permissions for your stack

### Step 2 — Prime your context (start of each session)

```
/prime
```

Reads the key files in your codebase so Claude understands the architecture before you start work.

### Step 3 — Plan a feature

```
/plan_local <what you want to build>
```

You can pass a short description or a path to a PRD file:

```
/plan_local add user authentication with OAuth
/plan_local path/to/feature.prd.md
```

Claude will:
- Explore the codebase for existing patterns to follow
- Design the agent team (frontend, backend, tester-unit, tester-e2e, etc.)
- Write a detailed plan to `.agents/plans/{name}.plan.md`
- Output the exact command to execute it, e.g.:
  ```
  /build-with-agent-team .agents/plans/user-auth.plan.md 4
  ```

### Step 4 — Execute the plan (fresh Claude instance)

**Open a new Claude Code instance** (important — gives a clean context window), then run the command from Step 3:

```
/build-with-agent-team .agents/plans/user-auth.plan.md 4
```

The number at the end is the agent count from the plan. Claude will:
1. Create a git branch `plan/user-auth`
2. Spawn the agent team in tmux split panes
3. Orchestrate contracts between agents (backend publishes its API before frontend builds against it)
4. Run end-to-end validation when all agents complete
5. Open a PR automatically

### Step 5 — Validate

```
/validate
```

Runs build, lint, and tests. Use this after any significant change to confirm nothing is broken.

---

## Keeping your config up to date

When new skills, templates, or GSD patches are pushed to this repo:

```
/update-claude-config
```

This pulls the latest from GitHub and re-applies everything. No manual steps needed.

---

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
