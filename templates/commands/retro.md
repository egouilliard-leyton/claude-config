---
description: Session retrospective — extract and persist learnings to knowledge base
argument-hint: [session-label]
---

# Session Retrospective

**Input**: $ARGUMENTS

## Objective

Analyze the current work session and extract structured learnings into a persistent knowledge base at `.claude/knowledge/`. This creates a compounding feedback loop — every future session benefits from past discoveries.

**Core Principle**: EXTRACT, DON'T INVENT. Learnings must come from what actually happened in this session, not hypothetical advice.

---

## Phase 1: PARSE

### Determine Session Label

| Input | Action |
|-------|--------|
| `$ARGUMENTS` provided | Use as session label (kebab-case it if needed) |
| No arguments | Extract from current branch name: `git branch --show-current` |

### Derive Session Metadata

```bash
SESSION_LABEL="{from above}"
SESSION_DATE="$(date +%Y-%m-%d)"
SESSION_FILE=".claude/knowledge/sessions/${SESSION_DATE}-${SESSION_LABEL}.md"
```

### Validate Context

- Current branch: !`git branch --show-current`
- Confirm we are NOT on `main` or `master`. If we are → STOP and tell the user: "Run /retro from a feature branch, not main."

**PHASE_1_CHECKPOINT:**
- [ ] Session label determined
- [ ] On a feature branch (not main/master)

---

## Phase 2: GATHER

### Collect Session Artifacts

Run these commands to build a picture of what happened:

**Commit history:**
```bash
git log main..HEAD --oneline --no-decorate
```

**Changed files summary:**
```bash
git diff main --stat
```

**Full diff (for analysis):**
```bash
git diff main
```

If the diff exceeds ~2000 lines, focus on the `--stat` summary and read only the most significant changed files directly rather than the full diff.

**Plan file (if exists):**
Search for a matching plan in `.agents/plans/`:
```bash
ls .agents/plans/ 2>/dev/null
```
Read any plan file whose name relates to the session label or branch name.

**Existing knowledge base (for deduplication):**
If `.claude/knowledge/` exists, read:
- `.claude/knowledge/patterns.md`
- `.claude/knowledge/gotchas.md`
- `.claude/knowledge/agent-playbook.md`

These are needed to avoid duplicating already-captured learnings.

**PHASE_2_CHECKPOINT:**
- [ ] Commit history collected
- [ ] File change summary collected
- [ ] Diff analyzed (full or summarized)
- [ ] Plan file read (if available)
- [ ] Existing knowledge base read (if available)

---

## Phase 3: ANALYZE

### Extract Structured Learnings

Analyze the gathered artifacts and extract learnings into four categories. Each learning must be grounded in something concrete from this session — a specific file, a specific error, a specific decision.

### 3a — Patterns Discovered

New conventions, API shapes, or code patterns that worked well. Look for:
- Repeated structural patterns across new files
- Naming conventions that emerged
- Error handling approaches that were adopted
- Data flow patterns between components
- Test patterns that proved effective

For each pattern: describe it, cite the file(s) where it appears, and explain why it works.

### 3b — Gotchas and Pitfalls

Integration issues, surprising behavior, workarounds applied. Look for:
- Commits that fix a previous commit (indicates a gotcha was hit)
- Workaround comments in the diff (`// workaround`, `// hack`, `// note:`)
- Config changes that weren't obvious
- Dependencies that behaved unexpectedly
- Environment or setup issues

For each gotcha: describe the problem, the symptom, and the solution applied.

### 3c — Agent Team Insights

If this session used agent teams (check for plan file or multi-agent patterns):
- How many agents were used and what roles?
- What contract mismatches occurred (if any)?
- What spawn order worked?
- What cross-cutting concerns fell through the cracks?

Skip this category if the session was single-agent work.

### 3d — Tooling Notes

Build quirks, test runner flags, environment setup steps discovered. Look for:
- Changes to config files (`tsconfig`, `vite.config`, `eslint`, etc.)
- New scripts added to `package.json` or equivalent
- Docker or infrastructure changes
- CI/CD adjustments

**PHASE_3_CHECKPOINT:**
- [ ] Patterns extracted (at least 1, or explicitly noted "none new")
- [ ] Gotchas extracted (at least 1, or explicitly noted "none encountered")
- [ ] Agent insights extracted (or skipped if single-agent session)
- [ ] Tooling notes extracted (or explicitly noted "no tooling changes")

---

## Phase 4: PERSIST

### Initialize Knowledge Base

```bash
mkdir -p .claude/knowledge/sessions
```

### Write Knowledge Files

For each knowledge file (`patterns.md`, `gotchas.md`, `agent-playbook.md`):

**If the file does not exist yet**, create it with a header:

`patterns.md`:
```markdown
# Patterns

Accumulated code patterns discovered across sessions. Each entry is dated and labeled.

---
```

`gotchas.md`:
```markdown
# Gotchas

Known pitfalls, surprising behaviors, and their solutions. Each entry is dated and labeled.

---
```

`agent-playbook.md`:
```markdown
# Agent Playbook

Effective team configurations, spawn orders, and contract lessons for this project.

---
```

**Append new entries** to each file. Use this format for each entry:

```markdown

## {SESSION_DATE} — {SESSION_LABEL}

{extracted learnings for this category}
```

Only append entries for categories that have actual learnings. Do not append empty entries.

**Deduplication**: Before appending, compare against existing entries. If a learning is substantially the same as one already captured, skip it. Err on the side of including — slight variations are fine.

### Write Session Recap

Write the full session recap to `.claude/knowledge/sessions/{SESSION_DATE}-{SESSION_LABEL}.md`:

```markdown
# Session Recap: {SESSION_LABEL} ({SESSION_DATE})

## What Was Built

{1-3 sentence summary of what this session accomplished}

## Files Changed

- {N} files created, {M} files modified
- Key: {list the 3-5 most significant files/directories}

## Patterns Discovered

{patterns from Phase 3a, or "No new patterns."}

## Gotchas

{gotchas from Phase 3b, or "No gotchas encountered."}

## Agent Team Notes

{insights from Phase 3c, or "Single-agent session — no team notes."}

## Tooling Notes

{notes from Phase 3d, or "No tooling changes."}
```

**PHASE_4_CHECKPOINT:**
- [ ] `.claude/knowledge/` directory exists
- [ ] Knowledge files created or appended to (only for non-empty categories)
- [ ] Session recap written to `sessions/` subdirectory
- [ ] No duplicate entries appended

---

## Phase 5: INTEGRATE

### Update prime.md Reference

Read `.claude/commands/prime.md`. Check if it already contains a reference to `.claude/knowledge/`.

**If NOT referenced**: append a line to the numbered file list in prime.md:

```markdown
{N}. `.claude/knowledge/` - Accumulated learnings from past sessions (patterns, gotchas, agent playbook)
```

Where `{N}` is the next number in the list.

**If already referenced**: skip — no changes needed.

**PHASE_5_CHECKPOINT:**
- [ ] prime.md checked for knowledge base reference
- [ ] Reference added if missing, skipped if present

---

## Phase 6: REPORT

**REPORT_TO_USER:**

```markdown
## Session Retrospective Complete

**Session**: {SESSION_LABEL} ({SESSION_DATE})
**Branch**: {branch name}

### Learnings Captured

| Category | Count | Status |
|----------|-------|--------|
| Patterns | {N} | {written / none new} |
| Gotchas | {N} | {written / none encountered} |
| Agent insights | {N} | {written / skipped (single-agent)} |
| Tooling notes | {N} | {written / no changes} |

### Files Written

- `.claude/knowledge/sessions/{SESSION_DATE}-{SESSION_LABEL}.md` — full session recap
{only list files that were actually written/appended to:}
- `.claude/knowledge/patterns.md` — {N} new entries appended
- `.claude/knowledge/gotchas.md` — {N} new entries appended
- `.claude/knowledge/agent-playbook.md` — {N} new entries appended

### Integration

- prime.md: {updated with knowledge base reference / already referenced}

Future sessions will automatically benefit from these learnings via `/prime` and `/plan_local`.
```
