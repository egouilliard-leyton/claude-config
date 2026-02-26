#!/usr/bin/env bash
# install.sh — Symlink claude-config skills and templates into ~/.claude/
#
# Safe to run on both fresh and existing ~/.claude/ setups.
# Uses per-item symlinks so unrelated skills/templates are never touched.
#
# Usage:
#   ./install.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing claude-config from: $REPO_DIR"
echo ""

mkdir -p ~/.claude/skills ~/.claude/templates

# ── Skills ────────────────────────────────────────────────────────────────────
# Symlink each skill individually so unrelated skills are untouched.

for skill in "$REPO_DIR/skills"/*/; do
  skill_name="$(basename "$skill")"
  target=~/.claude/skills/"$skill_name"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "  skipping skills/$skill_name — already exists (not a symlink). Remove it manually to override."
  else
    ln -sf "$skill" "$target"
    echo "  linked  skills/$skill_name"
  fi
done

# ── Templates ─────────────────────────────────────────────────────────────────
# Symlink per category (agents/, commands/, skills/) so unrelated dirs are safe.

for category in agents commands skills; do
  src="$REPO_DIR/templates/$category"
  target=~/.claude/templates/"$category"

  if [ ! -d "$src" ]; then
    continue
  fi

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "  skipping templates/$category — already exists (not a symlink). Remove it manually to override."
  else
    ln -sf "$src" "$target"
    echo "  linked  templates/$category"
  fi
done

echo ""
echo "Done. Open Claude Code in any project and run /init-claude to bootstrap it."
