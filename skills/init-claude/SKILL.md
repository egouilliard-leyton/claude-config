---
name: init-claude
description: Bootstrap a fully configured .claude/ directory in any project. Copies general-purpose agents, commands, and skills from ~/.claude/templates/, then generates project-specific prime.md, validate.md, and settings.local.json by analyzing the codebase.
allowed-tools: Bash, Read, Write, Glob, Grep
---

# Init Claude — Bootstrap `.claude/` for Any Project

You are setting up a complete `.claude/` directory in the current project. This involves copying general-purpose files from templates and generating project-specific configuration.

## Step 1: Copy General Files

Run the init script to copy template files:

```bash
bash ~/.claude/skills/init-claude/init-claude.sh
```

**If exit code is 2** (conflicts detected):
- Show the user which files conflict
- Ask: "Your project already has some .claude/ files. Should I overwrite them with the latest templates, or skip the conflicting files?"
- If overwrite: run `bash ~/.claude/skills/init-claude/init-claude.sh --force`
- If skip: proceed to Step 2 (the non-conflicting files were already copied)

**If exit code is 1** (templates missing):
- STOP and tell the user: "Templates not found at ~/.claude/templates/. The init-claude skill needs templates installed first."

## Step 2: Analyze the Codebase

Detect the project's stack by reading available config files. Check for these in order:

### Package Manager Detection

| File | Package Manager |
|------|----------------|
| `bun.lockb` or `bun.lock` | bun |
| `pnpm-lock.yaml` | pnpm |
| `yarn.lock` | yarn |
| `package-lock.json` | npm |
| `package.json` (no lockfile) | npm (default) |
| `Cargo.toml` | cargo |
| `pyproject.toml` or `setup.py` | pip/uv/poetry (check pyproject.toml for tool) |
| `go.mod` | go |

### Stack Detection

Read whichever manifest exists (`package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`) and extract:

1. **Project name and description**
2. **Framework** (React, Next.js, Vue, Svelte, Express, FastAPI, Actix, etc.)
3. **Build command** (from `scripts.build` in package.json, or infer from stack)
4. **Lint command** (from `scripts.lint`, or detect eslint/biome/clippy/ruff)
5. **Test command** (from `scripts.test`, or detect vitest/jest/pytest/cargo test)
6. **Test runner** (vitest, jest, pytest, cargo test, go test)
7. **Key dependencies** that shape architecture

Also check for:
- `docker-compose.yml` / `docker-compose.yaml` / `compose.yml` → Docker is used
- `Dockerfile` → Docker builds
- `.env.example` or `.env` → Environment variables needed
- `CLAUDE.md` → Already has project conventions (read it for context)
- `tsconfig.json` → TypeScript project
- `vite.config.*` / `next.config.*` / `webpack.config.*` → Build tool
- `tailwind.config.*` → Tailwind CSS
- `.github/workflows/` → CI/CD exists

### Key Files Detection

Find the most important files for understanding this codebase. Look for:

1. **Entry point**: `src/main.ts`, `src/index.ts`, `src/App.tsx`, `src/main.rs`, `cmd/main.go`, `app/main.py`
2. **Routing**: `src/App.tsx` (React Router), `app/` dir (Next.js/Remix), `src/routes/`
3. **Config**: `CLAUDE.md`, `package.json`, `tsconfig.json`, `Cargo.toml`, `pyproject.toml`
4. **API client/types**: `src/lib/`, `src/types/`, `src/api/`
5. **Database**: `schema.sql`, `prisma/schema.prisma`, `drizzle/`, `migrations/`
6. **Tests**: First test file found (to understand test patterns)

**Only include files that actually exist.** Use Glob to verify each candidate.

## Step 3: Read Example Files

Read the three example files to understand the target format:

```
~/.claude/skills/init-claude/examples/prime.md.example
~/.claude/skills/init-claude/examples/validate.md.example
~/.claude/skills/init-claude/examples/settings.local.json.example
```

Use these as structural references, NOT as content to copy. The generated files must reflect THIS project's actual stack.

## Step 4: Generate `prime.md`

Write to `.claude/commands/prime.md`.

### Structure

```markdown
---
allowed-tools: Read, Glob, Bash
description: Prime agent with codebase context
---

## Architecture Overview

{Project name} is a {brief description of what it is and tech stack}.

{2-4 bullet points describing the major components/layers}

---

Read these files to understand the codebase before starting work:

1. `CLAUDE.md` - Project conventions and patterns
2. `{manifest}` - Dependencies and scripts
{3-15 more files, each with a brief description}

Then run:
\`\`\`bash
{build command}
\`\`\`

Confirm the build passes before proceeding.
```

### Rules for prime.md

- **8-15 key files**, each must actually exist (verify with Glob)
- Start with `CLAUDE.md` and the package manifest
- Include entry points, routing, API clients, type definitions, config
- Brief description for each file (what it contains, not what to do with it)
- Build command at the end using the detected package manager
- Architecture overview should be 3-5 lines, factual, no fluff

## Step 5: Generate `validate.md`

Write to `.claude/commands/validate.md`.

### Structure

```markdown
---
allowed-tools: Bash({pm} run build:*), Bash({pm} run lint:*), Bash({pm} run test:*)
description: Run all checks (build, lint, test)
---

Run comprehensive validation. Execute in sequence:

1. **Build** (includes type checking):
   \`\`\`bash
   {build command}
   \`\`\`

2. **Lint**:
   \`\`\`bash
   {lint command}
   \`\`\`

3. **Tests**:
   \`\`\`bash
   {test command}
   \`\`\`

## Report

Summarize results:
- Build: PASS/FAIL
- Lint: X errors, Y warnings
- Tests: X passed, Y failed

**Overall: PASS or FAIL**
```

### Rules for validate.md

- Use the detected package manager (`npm`, `bun`, `pnpm`, `yarn`, `cargo`, `go`, `python -m pytest`, etc.)
- `allowed-tools` frontmatter must match the actual commands
- If a command doesn't exist in the project (e.g., no lint script), omit that section
- For Rust: `cargo build`, `cargo clippy`, `cargo test`
- For Python: `python -m pytest`, `ruff check .`, `mypy .`
- For Go: `go build ./...`, `golangci-lint run`, `go test ./...`

### Allowed-tools Patterns by Stack

| Stack | allowed-tools |
|-------|--------------|
| npm | `Bash(npm run build:*), Bash(npm run lint:*), Bash(npm run test:*)` |
| bun | `Bash(bun run build:*), Bash(bun run lint:*), Bash(bun run test:*)` |
| pnpm | `Bash(pnpm run build:*), Bash(pnpm run lint:*), Bash(pnpm run test:*)` |
| yarn | `Bash(yarn build:*), Bash(yarn lint:*), Bash(yarn test:*)` |
| cargo | `Bash(cargo build:*), Bash(cargo clippy:*), Bash(cargo test:*)` |
| go | `Bash(go build:*), Bash(golangci-lint:*), Bash(go test:*)` |
| python | `Bash(python -m pytest:*), Bash(ruff:*), Bash(mypy:*)` |

## Step 6: Generate `settings.local.json`

Write to `.claude/settings.local.json`.

### Structure

```json
{
  "permissions": {
    "allow": [
      // Always include
      "mcp__plugin_context7_context7__query-docs",
      "Bash(gh pr create:*)",
      "Bash(git push:*)",
      // Add based on stack detection
    ]
  }
}
```

### Permission Rules

Add permissions based on what's detected:

| Detection | Permission to Add |
|-----------|------------------|
| Docker compose file exists | `"Bash(docker:*)"`, `"Bash(docker compose:*)"` |
| `package.json` with npm | `"Bash(npm run build:*)"`, `"Bash(npm run test:*)"` |
| `package.json` with bun | `"Bash(bun run:*)"`, `"Bash(bun test:*)"` |
| `package.json` with pnpm | `"Bash(pnpm run:*)"`, `"Bash(pnpm test:*)"` |
| `Cargo.toml` | `"Bash(cargo build:*)"`, `"Bash(cargo test:*)"`, `"Bash(cargo clippy:*)"` |
| `pyproject.toml` | `"Bash(python -m pytest:*)"`, `"Bash(ruff:*)"` |
| `go.mod` | `"Bash(go build:*)"`, `"Bash(go test:*)"` |
| Medusa detected | `"Bash(npx create-medusa-app:*)"` |
| Agent teams skill installed | `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"` |

Only add permissions that are relevant. Don't add Docker permissions if there's no Docker setup.

## Step 7: Report

After generating all files, report to the user:

```markdown
## .claude/ initialized

**General files**: {N} files copied from templates
**Project-specific files generated**:
- `.claude/commands/prime.md` — {N} key files, {package manager} build
- `.claude/commands/validate.md` — {build/lint/test commands}
- `.claude/settings.local.json` — {N} permissions

**Detected stack**: {framework} + {language} + {package manager}

**Next steps**:
1. Run `/prime` to load codebase context
2. Run `/validate` to verify build/lint/test pass
3. Review `.claude/settings.local.json` and adjust permissions if needed
```
