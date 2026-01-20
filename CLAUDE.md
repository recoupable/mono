# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Monorepo Structure

This is a git submodule-based monorepo for the Recoup platform. Each submodule has its own CLAUDE.md with project-specific guidance.

| Submodule | Description | Key Tech |
|-----------|-------------|----------|
| `Recoup-Chat` | Main chat application | Next.js 16, React 19, Vercel AI SDK, Stagehand |
| `Recoup-API` | API service with payment middleware | Next.js 16, x402-next, Supabase |
| `Recoup-Tasks` | Background job workers | Trigger.dev v4 |
| `Recoup-Docs` | API documentation | Mintlify |
| `Recoup-Supabase` | Database migrations | Supabase CLI |

## Git Workflow

**Common rules across all submodules:**
1. **NEVER push directly to `main`** - always use feature branches and PRs
2. After code changes, commit with descriptive messages and push to feature branches
3. Each submodule is an independent git repository

**Recoup-API has an additional `test` branch:**
- PRs should target `test`, not `main`
- Before starting work, sync test with main: `git checkout test && git pull origin test && git fetch origin main && git merge origin/main && git push origin test`

**Recoup-Chat has an additional `test` branch:**
- PRs should target `test`, not `main`
- Before starting work, sync test with main: `git checkout test && git pull origin test && git fetch origin main && git merge origin/main && git push origin test`

## Build Commands by Project

**Recoup-Chat & Recoup-API:**
```bash
pnpm install        # Install dependencies
pnpm dev            # Start dev server
pnpm build          # Production build
pnpm lint           # Fix lint issues
pnpm format         # Run prettier
```

**Recoup-Tasks:**
```bash
pnpm install                     # Install dependencies
pnpm dev                         # Start Trigger.dev dev mode
pnpm run deploy:trigger-prod     # Deploy to production
```

**Recoup-Docs:**
```bash
npx mintlify@latest dev          # Preview docs locally
```

## Cross-Project Architecture

### Data Flow
- **Recoup-Chat** (frontend) -> **Recoup-API** (backend) -> **Supabase** (database)
- **Recoup-Tasks** handles async background jobs triggered by the API
- **MCP Server**: Recoup-API provides MCP tools (like `send_email`) used by Recoup-Chat

### API Endpoints
- **Recoup Chat**: `https://chat.recoupable.com/api`
- **Recoup API**: `https://recoup-api.vercel.app/api`
- **API Docs**: `https://developers.recoupable.com` (LLM-readable)

### Shared Patterns

**Supabase Operations (Recoup-API & Recoup-Chat):**
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

## Working Across Submodules

When making changes that span multiple submodules:
1. Work in each submodule independently (each has its own git history)
2. Coordinate API changes between Recoup-Chat and Recoup-API
3. Update Recoup-Docs when API endpoints change
4. Database schema changes go in Recoup-Supabase migrations

## Branding

- **Primary color**: `#345A5D`
- **Support email**: `agent@recoupable.com`
- **App URL**: `https://chat.recoupable.com`
- **Website**: `https://recoupable.com`
