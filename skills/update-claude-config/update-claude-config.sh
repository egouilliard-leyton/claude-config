#!/usr/bin/env bash
# update-claude-config.sh — Pull latest claude-config and re-apply everything
#
# Finds the repo via the init-claude symlink, pulls, and re-runs install.sh.

set -euo pipefail

SKILL_LINK=~/.claude/skills/init-claude

if [ ! -L "$SKILL_LINK" ]; then
  echo "ERROR: ~/.claude/skills/init-claude is not a symlink."
  echo "Re-run install.sh from your claude-config repo manually."
  exit 1
fi

# Resolve repo root: symlink points to <repo>/skills/init-claude/ — go up two levels
REPO_DIR="$(cd "$(dirname "$(readlink "$SKILL_LINK")")/.." && pwd)"

if [ ! -f "$REPO_DIR/install.sh" ]; then
  echo "ERROR: Could not find install.sh in $REPO_DIR"
  exit 1
fi

echo "claude-config repo: $REPO_DIR"
echo ""

# Pull latest
cd "$REPO_DIR"
git pull

echo ""

# Re-run install.sh (idempotent — safe to run repeatedly)
bash "$REPO_DIR/install.sh"
