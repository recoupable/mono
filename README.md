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

## Repository Structure

| Submodule | Description | Tech Stack |
|-----------|-------------|------------|
| `chat` | Main chat application | Next.js 16, React 19, Vercel AI SDK, Stagehand |
| `api` | API service with payment middleware | Next.js 16, x402-next, Supabase |
| `tasks` | Background job workers | Trigger.dev v4 |
| `docs` | API documentation | Mintlify |
| `database` | Database migrations | Supabase CLI |
| `remotion` | Video generation | Remotion |
| `bash` | Interactive bash demo with AI agent | Next.js 16, React 19, just-bash, AI SDK |
| `skills` | AI agent skills monorepo | Markdown, Git submodules |
| `business` | Private customer relationships, meetings, agreements and operations | Markdown |
| `projects` | Private technical workspaces for products and client builds | Git submodules, Markdown |

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

All projects use `pnpm`:

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
