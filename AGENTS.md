# AGENTS.md

This file provides guidance to any AI agent working with code in this repository.

## Monorepo Structure

This is a git submodule-based workspace for the Recoupable platform, business operations and project builds. Each submodule has its own context files with project-specific guidance.

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
| `tasks` | Internal, background job workers — **deprecating in favor of Vercel Workflows inside `api`; don't add new jobs here** | Trigger.dev v4 |
| `database` | Internal, database migrations | Supabase CLI |
| `gtm` | Internal, go-to-market tooling and CRM sync | TypeScript, tsx |
| `strategy` | Internal, strategy docs, PMF journal, roadmap, customer notes | Markdown |
| `business` | Internal, private shared client, pipeline, meeting, and business context | Markdown |
| `projects` | Internal, private technical project workspaces and client repository links | Git submodules, Markdown |

## Business Workspace

`business/` is the private `recoupable/business` repository, shared by Sidney and Sweets. It preserves
the consulting OS folder structure and contains reviewed business material plus the team's own work.
It has independent Git history; it is not a clone or mirror of Sidney's private consulting repository.

Use it for customer context, meeting records, consulting delivery, pipeline, and business operations.
Before working on a client or deal, read `business/AGENTS.md` and that entity's `AGENTS.md`. Reference
the canonical record there instead of duplicating customer context in another submodule.

- **Customer relationships:** `business/clients/`; prospective deals: `business/pipeline/`.
- **Technical project work:** `projects/<project>/`; follow `projects/AGENTS.md` and the project map.
- **Reusable context:** `business/knowledge/`, `business/library/`, and sourced insights in `business/signals/`.
- **Content and product opportunities:** `business/content/` and `business/products/`.
- **Back office:** `business/business/`; the practice dashboard is `business/business/metrics/dashboard.html`.

**Sharing boundary:** ordinary personal details mentioned in legitimate customer/client meetings may
remain. Exclude actual therapy-session transcripts, standalone personal/family/health records, unrelated employment
records and credentials. Client material remains confidential.
Do not fetch private source repositories, inboxes, meeting accounts, or missing originals from Mono.
Future private-source imports require review outside Business before any branch is pushed. An excerpt
is incomplete evidence; do not reconstruct omitted passages. Historical ingestion routines are reference
only. The separate private sync coordinator AI-reviews outbound files and polls released Business/Skills
changes back into the private workspace. In Mono, its signed PRs are based on current main and change only the Business/Skills submodule references.
No source-ingestion worker runs inside Mono.

**Skills:** Mono's `skills/` is the single shared checkout of the public `recoupable/skills` repository.
Business uses it through `../skills/`; do not create a nested `business/plugin/` checkout or copy skills
into Business. Author skills at `skills/skills/<skill-name>/SKILL.md` from the Mono root, or
`../skills/skills/<skill-name>/SKILL.md` from the Business root. Follow `skills/AGENTS.md` for publishing.
For consulting capabilities, `<skill-name>` is the full `recoup-internal-consulting-<short-name>`
in both the folder name and SKILL.md frontmatter. “Internal” describes their intended
audience, not repository privacy. Keep client records and private business examples in Business. When
running a shared skill for Business, use Business as the working directory and output destination.
Publish skill changes in a Skills PR targeting `main` and let the coordinator update Mono's Skills reference after merge (or update it manually while sync is paused).
Publish Business changes in a Business PR targeting `main` and let the coordinator update its Mono reference separately (or do so manually while sync is paused). Neither repository's commit publishes
the other. Consulting's private plugin authoring workflow remains separate from this Mono setup.

On a fresh Mono clone, initialize Business and shared Skills with
`git submodule update --init -- business skills`. Commit Business content in its own repository;
Mono records only the Business commit reference. Both use feature branches and PRs targeting `main`.

## Projects Workspace

`projects/` is the private `recoupable/projects` repository. It organizes technical builds in named
project folders. Read `projects/AGENTS.md` and the selected project's
instructions for its repository map and current setup status. Source repositories keep their owning
GitHub organizations, permissions, histories and deployment workflows.

Business holds the customer relationship: meetings, agreements, account status and commitments.
Projects holds the implementation: applications, services, operating systems and technical guidance.
Link between the canonical records; keep each fact in its owning repository. Projects uses its own
repository permissions and is outside the private Consulting-to-Business publication process.

Initialize Projects with `git submodule update --init -- projects`. Then read its project instructions
before initializing only the required child repositories. A private project's source access must be
granted separately; Mono access is not source-repository access. Mono is public, so keep customer
code, records, credentials and detailed project inventories inside the private repositories.

Work and merge in each owning repository first, update its reference in a Projects PR, then update
Mono's `projects` reference in a Mono PR. The Business/Skills coordinator does not update Projects.
Preserve active local checkouts and worktrees during setup. Project-specific branding and release
branches override Recoup platform defaults; verify a child's default branch before opening its PR.

## Design System

**Read `DESIGN.md` before building or modifying Recoup platform UI. Client projects follow their own design instructions.**

It defines the shared visual language — colors, typography, spacing, components, depth, and motion — that all frontends (chat, marketing, admin) share. App-specific overrides are noted inline. Key points:

- **Four-font system:** Geist Pixel Square (display headlines), Plus Jakarta Sans (UI), Geist Sans (body), Instrument Serif (editorial moments)
- **Shadow-as-border:** Use `box-shadow` instead of CSS `border` on cards and containers
- **Achromatic chrome:** UI stays black/white — color comes from content and status indicators
- **Semantic CSS variables:** All colors defined as custom properties with light and dark values

## Git Workflow

**Repository workflow:**
1. **NEVER push directly to `main`** - always use feature branches and PRs
2. After code changes, commit with descriptive messages and push to feature branches
3. Each submodule is an independent git repository
4. **Always open a PR** after pushing changes. Recoup platform, Business and Projects PRs target `main`; project-owned repositories use their verified release branch. The old `api`/`chat` `test`-branch staging flow is retired.

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

**Recoup platform submodules (including `api` and `chat`), Business and Projects take PRs against `main`. Client-owned repositories follow their own branch rules.** The `test` branches in `api`/`chat` are retired as PR targets — do not open PRs against them or run the old test-sync ritual.

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
- **tasks** handles existing async background jobs (Trigger.dev), but is deprecating — new background/scheduled work uses Vercel Workflows inside **api** (cron route → workflow)
- **MCP Server**: api provides MCP tools (like `send_email`) used by chat

### API Endpoints
- **Chat**: `https://chat.recoupable.dev/api`
- **API**: `https://api.recoupable.dev/api`
- **API Docs**: `https://docs.recoupable.dev` (LLM-readable: `/llms.txt`, `/llms-full.txt`)

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

Create `skills/skills/<skill-name>/SKILL.md` in the `skills/` submodule. Follow `skills/AGENTS.md`
for the format, resolver entry, and validation. Push to a feature branch and open a PR. This is also
the authoring location for agents working from Business; see the Business Workspace section above.

## Working Across Submodules

When making changes that span multiple submodules:
1. Work in each submodule independently (each has its own git history)
2. Coordinate API changes between chat and api
3. Update docs when API endpoints change
4. Database schema changes go in database migrations

## Branding

- **Support email**: `agent@recoupable.dev`
- **App URL**: `https://chat.recoupable.dev`
- **Website**: `https://recoupable.dev`
