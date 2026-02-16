# Recoup Monorepo

A git submodule-based monorepo for the Recoup platform.

## Quick Start

```bash
# Clone with submodules
git clone --recurse-submodules git@github.com:recoupable/mono.git

# Or if already cloned, initialize submodules
git submodule update --init --recursive
```

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

## Using This Repo with an LLM

This monorepo is designed for LLM-assisted development. Each submodule contains its own `CLAUDE.md` with project-specific context and instructions.

### Key Files for LLM Context

- **`CLAUDE.md`** (root): Monorepo-wide guidance, git workflow, cross-project architecture
- **Each submodule's `CLAUDE.md`**: Project-specific build commands, patterns, and conventions
- **API Docs**: https://developers.recoupable.com (LLM-readable)

### Tips for LLM Sessions

1. **Start with context**: Point your LLM to `CLAUDE.md` at the root for overall guidance
2. **Work in submodules**: Each submodule is an independent git repo - cd into the relevant folder
3. **Branch workflow**: Never push directly to `main`. Use feature branches and PRs
4. **Special branches**: `api` and `chat` have a `test` branch - PRs should target `test`, not `main`

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
