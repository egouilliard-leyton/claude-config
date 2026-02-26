#!/usr/bin/env bash
# init-claude.sh — Copy general .claude/ template files into a project
#
# Usage:
#   bash init-claude.sh [--force] [target-dir]
#
# Exit codes:
#   0 — Success
#   1 — Templates directory not found
#   2 — Conflicts detected (target has existing files that would be overwritten)

set -euo pipefail

TEMPLATES_DIR="$HOME/.claude/templates"
FORCE=false
TARGET_DIR="."

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=true; shift ;;
    *) TARGET_DIR="$1"; shift ;;
  esac
done

DEST="$TARGET_DIR/.claude"

# Check templates exist
if [[ ! -d "$TEMPLATES_DIR" ]]; then
  echo "ERROR: Templates directory not found at $TEMPLATES_DIR"
  echo "Run the init-claude skill first to set up templates."
  exit 1
fi

# Collect list of files to copy (relative paths)
FILES=()
while IFS= read -r -d '' file; do
  FILES+=("${file#$TEMPLATES_DIR/}")
done < <(find "$TEMPLATES_DIR" -type f -print0)

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "ERROR: No template files found in $TEMPLATES_DIR"
  exit 1
fi

# Check for conflicts (files that already exist in target)
CONFLICTS=()
for rel_path in "${FILES[@]}"; do
  if [[ -f "$DEST/$rel_path" ]]; then
    CONFLICTS+=("$rel_path")
  fi
done

if [[ ${#CONFLICTS[@]} -gt 0 ]] && [[ "$FORCE" == "false" ]]; then
  echo "CONFLICTS: ${#CONFLICTS[@]} files already exist in $DEST/"
  for c in "${CONFLICTS[@]}"; do
    echo "  - $c"
  done
  echo ""
  echo "Use --force to overwrite, or handle conflicts manually."
  exit 2
fi

# Copy files, preserving directory structure
COPIED=0
SKIPPED=0
for rel_path in "${FILES[@]}"; do
  dest_file="$DEST/$rel_path"
  dest_dir="$(dirname "$dest_file")"

  # Create directory if needed
  mkdir -p "$dest_dir"

  # Check if file exists and we're not forcing
  if [[ -f "$dest_file" ]] && [[ "$FORCE" == "false" ]]; then
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  cp "$TEMPLATES_DIR/$rel_path" "$dest_file"
  COPIED=$((COPIED + 1))
done

echo "Done: copied $COPIED files, skipped $SKIPPED"
echo "Target: $DEST/"
