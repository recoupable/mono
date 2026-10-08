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
| `blog` | Blog repository | Read local instructions |
| `plugins` | Plugin repository | Read local instructions |
| `business` | Internal, private company strategy, product opportunities, customers and operations | Markdown |
| `projects` | Internal, private technical project workspaces and client repository links | Git submodules, Markdown |
| `records` | Internal, private Recoup Records organization workspace and label operations | Markdown |

## Find context and save work

Read this file, then the owning repository's `AGENTS.md`; load the records relevant to the task.

| Task | Read first / save location |
| --- | --- |
| Company direction, product strategy or PMF learning | `business/strategy/README.md` → current orientation and decision/learning records |
| Product opportunity or customer demand | `business/products/AGENTS.md` → existing opportunity card and sources |
| Customer relationship, meeting or agreement | `business/AGENTS.md` → client/deal instructions and canonical records |
| Company positioning or market research | `business/positioning/` |
| Finance, legal or company metrics | `business/business/` |
| Recoup platform code and release status | Owning application submodule's instructions and progress record |
| Recoup Records label operations | `records/AGENTS.md` → operating plans, decisions and evidence references |
| Client technical build | `projects/AGENTS.md` → selected project map and owning child repository |
| Reusable agent capability | `skills/AGENTS.md` → `skills/skills/` |

The standalone `strategy/` submodule is retired. Its migration map and history live privately at
`business/strategy/migration-2026-09-16.md`. Existing local Strategy checkouts may remain for
preservation; do not write new work there or load their old instructions as current company policy.
Do not delete local checkouts or unpublished history as part of routine workspace cleanup.

If a private repository is uninitialized or inaccessible, report the missing context and request the
appropriate access; do not infer its contents from old strategy files or search personal checkouts.
Keep private facts inside their owning Business, Projects or Records repository, not in public Mono.
Link to the owning record instead of duplicating it. At handoff, update its dated status, evidence,
next action and blockers so another session can resume. A historical report or candidate idea is not
a current decision or release.

## Business Workspace

`business/` is the private `recoupable/business` repository, shared by Sidney and Sweets. It preserves
the consulting OS folder structure and contains reviewed business material plus the team's own work.
It has independent Git history; it is not a clone or mirror of Sidney's private consulting repository.

Use it for company strategy, product opportunities, customer context, meetings, consulting delivery,
pipeline, and business operations.
Before working on a client or deal, read `business/AGENTS.md` and that entity's `AGENTS.md`. Reference
the canonical record there instead of duplicating customer context in another submodule.

- **Company direction:** `business/strategy/`; start with its `README.md`.
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
branches override Recoup platform defaults; verify a child's documented release or PR target branch
before opening its PR. Its GitHub default branch may differ.

## Records Workspace

`records/` is the private organization repository used by Recoup Records. Read `records/AGENTS.md`
before operating the label. Use it for label plans, operating instructions, decisions and evidence
references. Keep contracts, statements, artist details and other private material out of public Mono.

Work **on the platform** in its owning application repositories; work **in the label** in `records/`.
Exercise the supported Recoup workflow for real operations, report product gaps as sanitized platform
issues, and verify the original business task after the product fix. Keep product architecture and
Context Engine planning in their existing product homes; link to them from Records instead of
creating a second platform roadmap.

With access to its private repository, initialize only Records using
`git submodule update --init -- records`. Commit changes in Records on feature branches and open
PRs against its `main`; after merge, update the `records` reference in a separate Mono PR against
`main`. The Business/Skills coordinator does not update Records. A shared Git remote does not prove
automatic synchronization with hosted Recoup sessions; verify the branch, commit and file readback.

## Design System

**Read `DESIGN.md` before building or modifying Recoup platform UI. Client projects follow their own design instructions.**

It maps the shared **Recoup Sky** system used by marketing and the app, and points at the sources of truth:
`marketing/DESIGN.md` for the system, each app's `app/globals.css` for tokens. Key points:

- **Colors:** white canvas, ink `#152E37`, brand blue `#007EBD`, dark green `#132B26`, lime `#D6FF62` for actions
- **Type:** DM Sans for everything, IBM Plex Mono for labels
- **When the doc and the code disagree, the code wins**; fix the doc in the same PR

## Git Workflow

**Repository workflow:**
1. **NEVER push directly to `main`** - always use feature branches and PRs
2. After code changes, commit with descriptive messages and push to feature branches
3. Each submodule is an independent git repository
4. **Always open a PR** after pushing changes. Recoup platform, Business and Projects PRs target `main`; project-owned repositories use their verified release branch. The old `api`/`chat` `test`-branch staging flow is retired.

### Worktree Workflow

**All linked worktrees must live under an ignored `.worktrees/` directory.** Keep Mono and Recoup
platform, Business, Projects, and Records worktrees at `mono/.worktrees/<repository>/<task>/`; use `mono` as
the repository name for a worktree of this parent repository. Do not create new sibling folders such
as `api-worktree`, or hide Git checkouts inside business task/output folders or temporary directories.

Project-owned workspaces with an established local convention keep their own `.worktrees/` root.
In particular, Seeker/Heartbeats worktrees stay inside that workspace's
`.worktrees/<repository>/<task>/`, not Mono's central directory. A standalone repository uses its own
ignored `.worktrees/<task>/`. Ordinary output folders are not worktrees and are not moved by this rule.

Create worktrees through the repository that owns the code. From the Mono root:

```bash
# Verify the starting ref in the owning repository before creating a branch.
git -C api worktree add ../.worktrees/api/<task> -b codex/<task> origin/main

# A worktree of Mono itself:
git worktree add .worktrees/mono/<task> -b codex/<task> origin/main
```

`git worktree add` at Mono's root creates a Mono worktree; a submodule path is not the submodule's
starting branch. Use `git -C <repository>` for both creation and removal.

Before relocating existing work, inventory registrations and preserve branch/commit, staged and
unstaged changes, untracked/ignored files, environment links and nested submodules. Check for running
processes and task paths. Use `git worktree move` for supported moves, then verify the registration
and local links. Git refuses to move worktrees containing submodules: those require an explicit,
verified migration that repairs both worktree registration and every nested repository pointer;
do not use a blind filesystem rename. Never reset or clean a checkout to make it movable.

Only remove a worktree after its work is merged or otherwise explicitly preserved, it is inactive,
and its tracked, untracked and ignored local files have been checked:

```bash
git -C api worktree remove ../.worktrees/api/<task>
```

Do not blanket-prune missing registrations. Check whether the checkout was moved or disconnected,
recover it when possible, and preserve its commit and metadata before pruning truly missing paths.
Private relocation inventories belong in ignored local storage, never this public repository.

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
