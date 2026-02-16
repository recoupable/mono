# Agent Instructions

This file provides guidance to any AI agent working with code in this repository.

## Monorepo Structure

This is a git submodule-based monorepo for the Recoup platform. Each submodule has its own context files with project-specific guidance.

| Submodule | Description | Key Tech |
|-----------|-------------|----------|
| `chat` | Main chat application | Next.js 16, React 19, Vercel AI SDK, Stagehand |
| `api` | API service with payment middleware | Next.js 16, x402-next, Supabase |
| `tasks` | Background job workers | Trigger.dev v4 |
| `docs` | API documentation | Mintlify |
| `database` | Database migrations | Supabase CLI |
| `remotion` | Video generation | Remotion |
| `bash` | Interactive bash demo with AI agent | Next.js 16, React 19, just-bash, AI SDK |
| `skills` | AI agent skills monorepo | Markdown, Git submodules |

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

## Working Across Submodules

When making changes that span multiple submodules:
1. Work in each submodule independently (each has its own git history)
2. Coordinate API changes between chat and api
3. Update docs when API endpoints change
4. Database schema changes go in database migrations

## Branding

- **Primary color**: `#345A5D`
- **Support email**: `agent@recoupable.com`
- **App URL**: `https://chat.recoupable.com`
- **Website**: `https://recoupable.com`
