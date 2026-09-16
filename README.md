# Recoup Monorepo

A git submodule-based workspace for the Recoup platform, business operations and project builds.

## Quick Start

```bash
# Clone the workspace, then initialize the repositories you need.
git clone git@github.com:recoupable/mono.git
cd mono
git submodule update --init -- chat api skills

# With access to the private company repositories:
git submodule update --init -- business projects
```

Read `projects/AGENTS.md` before initializing a client project's repositories. Each private source
requires its own access; select only what the current task needs.

## Find context

Start with [AGENTS.md](AGENTS.md), which routes tasks to their owning repository and explains where
to save results. Company direction is in `business/strategy/README.md`; customer records and product
opportunities remain in Business's existing folders. The standalone `strategy` submodule is retired.
After initializing Business, use `business/strategy/migration-2026-09-16.md` for historical paths.
Existing local Strategy checkouts may remain as preserved history; do not create new work there.

## Repository Structure

| Submodule | Purpose |
| --- | --- |
| `chat` | Artist and label web application |
| `api` | Backend API and new background workflows |
| `marketing` | Marketing website and landing pages |
| `docs` | Public API documentation |
| `cli` | Command-line interface |
| `skills` | Public reusable agent skills |
| `open-agents` | Reference application for background coding agents |
| `admin` | Internal platform administration |
| `tasks` | Existing Trigger.dev jobs; new jobs belong in API workflows |
| `database` | Supabase migrations |
| `gtm` | Internal go-to-market tooling |
| `blog` | Blog repository |
| `plugins` | Plugin repository; read its local instructions |
| `business` | Private company strategy, product opportunities, customers and operations |
| `projects` | Private technical project maps and client repository links |

## Using This Repo with an LLM

This monorepo is designed for LLM-assisted development. Each submodule contains its own agent context files with project-specific instructions.

### Key Files for LLM Context

- **`AGENTS.md`** (root): Monorepo-wide guidance, git workflow, cross-project architecture — source of truth for all AI agents
- **`CLAUDE.md`** (root): Symlink to `AGENTS.md` — so Claude automatically picks up the same instructions
- **Each submodule's context files**: Project-specific build commands, patterns, and conventions
- **API Docs**: https://developers.recoupable.com (LLM-readable)

### Tips for LLM Sessions

1. **Start with context**: Point your LLM to `AGENTS.md` (or `CLAUDE.md`) at the root for overall guidance
2. **Work in submodules**: Each submodule is an independent git repo - cd into the relevant folder
3. **Branch workflow**: Never push directly to `main`. Use feature branches and PRs
4. **Release branches**: Recoup platform, Business and Projects PRs target `main`. Client project repositories follow their own verified release branches.

## Data Flow

```text
chat (frontend) → api (backend) → Supabase (database)
                       ↓
                 tasks (async jobs)
```

## Build Commands

Recoup application repositories use `pnpm`. For work under `projects/`, follow the selected project's
own build and package-manager instructions. Common Recoup application commands:

```bash
pnpm install   # Install dependencies
pnpm dev       # Start dev server
pnpm build     # Production build
pnpm lint      # Fix lint issues
pnpm format    # Run prettier
```

## Links

- **App**: https://chat.recoupable.com
- **API**: https://recoup-api.vercel.app/api
- **Docs**: https://developers.recoupable.com
- **Website**: https://recoupable.com
