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

# ── GSD ───────────────────────────────────────────────────────────────────────
# Install GSD if not present, then apply local patches.

GSD_DIR=~/.claude/get-shit-done
PATCHES_DIR="$REPO_DIR/patches/gsd"

if [ ! -d "$GSD_DIR" ]; then
  echo "  GSD not found — installing via npx..."
  npx -y get-shit-done-cc@latest --global
  echo "  installed GSD"
else
  echo "  GSD already installed ($(cat "$GSD_DIR/VERSION" 2>/dev/null || echo "unknown version"))"
fi

# Apply patches with home path substitution so they work on any machine.
if [ -d "$PATCHES_DIR" ]; then
  while IFS= read -r -d '' patch_file; do
    rel="${patch_file#$PATCHES_DIR/}"
    target="$GSD_DIR/$rel"
    if [ ! -f "$target" ]; then
      echo "  skipping patches/gsd/$rel — target not found in GSD install"
    else
      sed "s|/home/edouard-gouilliard|$HOME|g" "$patch_file" > "$target"
      echo "  patched gsd/$rel"
    fi
  done < <(find "$PATCHES_DIR" -type f -print0)
fi

echo ""
echo "Done. Open Claude Code in any project and run /init-claude to bootstrap it."
