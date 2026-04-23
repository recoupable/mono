# Agent Instructions

This file provides guidance to any AI agent working with code in this repository.

## Monorepo Structure

This is a git submodule-based monorepo for the Recoupable platform. Each submodule has its own context files with project-specific guidance.

| Submodule | Description | Key Tech |
|-----------|-------------|----------|
| `chat` | External, web app, AI chat interface for artists and labels | Next.js 16, React 19, Vercel AI SDK, Stagehand |
| `api` | External, backend API with payment middleware | Next.js 16, x402-next, Supabase |
| `marketing` | External, marketing website and landing pages | Next.js, React, Tailwind CSS |
| `docs` | External, API documentation | Mintlify |
| `cli` | External, CLI for the Recoupable platform | Commander.js, tsup, Node 22 |
| `skills` | External, Recoupable's public skills repo, platform usage + domain knowledge for AI agents | Markdown |
| `open-agents` | External, reference app for background coding agents on Vercel (web + agent workflow + sandbox) | Next.js, Turbo, Vercel Workflow, Vercel Sandbox |
| `admin` | Internal, admin dashboard for platform management | Next.js, React, Supabase |
| `tasks` | Internal, background job workers | Trigger.dev v4 |
| `database` | Internal, database migrations | Supabase CLI |
| `gtm` | Internal, go-to-market tooling and CRM sync | TypeScript, tsx |
| `strategy` | Internal, strategy docs, PMF journal, roadmap, customer notes | Markdown |
| `remotion` | Dormant, video generation | Remotion |
| `bash` | Dormant, interactive bash demo with AI agent | Next.js 16, React 19, just-bash |

## Design System

**Read `DESIGN.md` before building or modifying any UI across any submodule.**

It defines the shared visual language — colors, typography, spacing, components, depth, and motion — that all frontends (chat, marketing, admin) share. App-specific overrides are noted inline. Key points:

- **Four-font system:** Geist Pixel Square (display headlines), Plus Jakarta Sans (UI), Geist Sans (body), Instrument Serif (editorial moments)
- **Shadow-as-border:** Use `box-shadow` instead of CSS `border` on cards and containers
- **Achromatic chrome:** UI stays black/white — color comes from content and status indicators
- **Semantic CSS variables:** All colors defined as custom properties with light and dark values

## Git Workflow

**Common rules across all submodules:**
1. **NEVER push directly to `main`** - always use feature branches and PRs
2. After code changes, commit with descriptive messages and push to feature branches
3. Each submodule is an independent git repository
4. **Always open a PR** after pushing changes - check each repo's rules for which branch to target (e.g., `test` vs `main`)

### Worktree Workflow

Use git worktrees to work on features in isolation without affecting your main working directory.

**Creating a worktree for a new feature:**
```bash
# From the monorepo root, create a worktree for a submodule
git worktree add <submodule>-worktree -b <branch-name> <submodule>

# Example: Create a worktree for api
git worktree add api-worktree -b feature/my-feature api
```

**Removing the worktree after PR is merged:**
```bash
# Remove the worktree directory and prune
git worktree remove <submodule>-worktree
git worktree prune

# Example: Remove api worktree
git worktree remove api-worktree
git worktree prune
```

**Benefits of worktrees:**
- Work on multiple features simultaneously without stashing
- Keep your main working directory clean
- Isolated environment for each feature branch
- Easy cleanup after PR merge

**api has an additional `test` branch:**
- PRs should target `test`, not `main`
- Before starting work, sync test with main: `git checkout test && git pull origin test && git fetch origin main && git merge origin/main && git push origin test`

**chat has an additional `test` branch:**
- PRs should target `test`, not `main`
- Before starting work, sync test with main: `git checkout test && git pull origin test && git fetch origin main && git merge origin/main && git push origin test`

## Build Commands by Project

**chat & api:**
```bash
pnpm install        # Install dependencies
pnpm dev            # Start dev server
pnpm build          # Production build
pnpm lint           # Fix lint issues
pnpm format         # Run prettier
```

**tasks:**
```bash
pnpm install                     # Install dependencies
pnpm dev                         # Start Trigger.dev dev mode
pnpm run deploy:trigger-prod     # Deploy to production
```

**bash:**
```bash
pnpm install        # Install dependencies
pnpm dev            # Start dev server
pnpm build          # Production build
pnpm lint           # Fix lint issues
```

**cli:**
```bash
pnpm install        # Install dependencies
pnpm build          # Build with tsup
pnpm test           # Run tests with vitest
pnpm lint           # Fix lint issues
pnpm format         # Run prettier
```

**docs:**
```bash
npx mintlify@latest dev          # Preview docs locally
```

## Cross-Project Architecture

### Data Flow
- **chat** (frontend) -> **api** (backend) -> **Supabase** (database)
- **tasks** handles async background jobs triggered by the API
- **MCP Server**: api provides MCP tools (like `send_email`) used by chat

### API Endpoints
- **Chat**: `https://chat.recoupable.com/api`
- **API**: `https://recoup-api.vercel.app/api`
- **API Docs**: `https://developers.recoupable.com` (LLM-readable)

### Shared Patterns

**Supabase Operations (api & chat):**
- Never import Supabase client directly in domain code
- All database calls must go through `lib/supabase/[table_name]/[function].ts`
- Use naming: `select*`, `insert*`, `update*`, `delete*`, `get*` (for complex queries)

**Input Validation:**
- Use Zod schemas for all API input validation
- Pattern: `validate<EndpointName>Body.ts` or `validate<EndpointName>Query.ts`

**Code Principles:**
- SRP: One exported function per file
- DRY: Extract shared logic into utilities
- KISS: Simple solutions over clever ones
- YAGNI: Don't build for hypothetical future needs
- TDD: API changes should include unit tests

## Skills

| Purpose | Location |
|---------|----------|
| **Build & publish** skills | `skills/` submodule (the `recoupable/skills` repo) |
| **Install & use** skills | `.agents/skills/` via `npx skills add` |

### Installing a skill

```bash
npx skills add recoupable/skills        # install our own skills
npx skills add anthropics/skills        # install third-party skills
```

This puts skills into `.agents/skills/` (and `.cursor/skills/`, `.claude/skills/`, etc. depending on your tooling). All installed skills — ours and third-party — live in the same place.

### Building a new skill

Create a directory in the `skills/` submodule under `skills/` with a `SKILL.md`. See `skills/template/SKILL.md` for the format. Push to a feature branch, open a PR.

## Working Across Submodules

When making changes that span multiple submodules:
1. Work in each submodule independently (each has its own git history)
2. Coordinate API changes between chat and api
3. Update docs when API endpoints change
4. Database schema changes go in database migrations

## PROGRESS File (MANDATORY — Read Before & Write After Every Task)

`PROGRESS.md` is the monorepo's persistent memory. It lives at the root and gives the next agent instant context without re-deriving it from git history. **This is not optional.**

### Before starting any work:
1. Read `PROGRESS.md` to understand what has been done, what is in-flight, and what blockers exist
2. Use this context to avoid duplicating work and to continue from the correct state

### After completing any work (before taking a snapshot or exiting):
1. Append a new entry to `PROGRESS.md` using this format:

```text
## [YYYY-MM-DD] <short task title>
**Prompt:** <one-line summary of what was asked>
**Status:** completed | partial | blocked
**Changes:**
- <submodule>: <what changed and why>
**PRs:** <list of PR URLs, or "none">
**Notes:** <anything the next agent run should know>
```

2. Commit `PROGRESS.md` changes in the same commit as your other changes, or in a separate commit if nothing else changed

**If `PROGRESS.md` does not exist**, create it with an initial entry for the current task.

### Style rules
- Dates use ISO 8601: `YYYY-MM-DD`
- One line per item — no prose paragraphs
- Keep entries concise — recent completions, not a full changelog

### How the file gets saved
In sandbox environments, `pushAndCreatePRsViaAgent` pushes `PROGRESS.md` directly to `main` (no PR needed). You don't need to manually push — just edit it before the push step runs.

> **Why this matters:** Every agent run starts cold. Without `PROGRESS.md`, work gets duplicated, PRs get re-opened, and context is lost. Reading and writing this file is as important as writing the code itself.

## Branding

- **Primary color**: `#345A5D`
- **Support email**: `agent@recoupable.com`
- **App URL**: `https://chat.recoupable.com`
- **Website**: `https://recoupable.com`
