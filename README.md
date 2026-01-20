# Recoup Monorepo

A git submodule-based monorepo for the Recoup platform.

## Quick Start

```bash
# Clone with submodules
git clone --recurse-submodules git@github.com:Recoupable-com/recoup-monorepo.git

# Or if already cloned, initialize submodules
git submodule update --init --recursive
```

## Repository Structure

| Submodule | Description | Tech Stack |
|-----------|-------------|------------|
| `Recoup-Chat` | Main chat application | Next.js 16, React 19, Vercel AI SDK, Stagehand |
| `Recoup-API` | API service with payment middleware | Next.js 16, x402-next, Supabase |
| `Recoup-Tasks` | Background job workers | Trigger.dev v4 |
| `Recoup-Docs` | API documentation | Mintlify |
| `Recoup-Supabase` | Database migrations | Supabase CLI |

## Using This Repo with an LLM

This monorepo is designed for LLM-assisted development. Each submodule contains its own `CLAUDE.md` with project-specific context and instructions.

### Key Files for LLM Context

- **`CLAUDE.md`** (root): Monorepo-wide guidance, git workflow, cross-project architecture
- **`CONTRIBUTING.md`**: How to make changes to submodules
- **Each submodule's `CLAUDE.md`**: Project-specific build commands, patterns, and conventions

### Tips for LLM Sessions

1. **Start with context**: Point your LLM to `CLAUDE.md` at the root for overall guidance
2. **Work in submodules**: Each submodule is an independent git repo - cd into the relevant folder
3. **Branch workflow**: Never push directly to `main`. Use feature branches and PRs
4. **Special branches**: `Recoup-API` and `Recoup-Chat` have a `test` branch - PRs should target `test`, not `main`

## Data Flow

```
Recoup-Chat (frontend) → Recoup-API (backend) → Supabase (database)
                              ↓
                        Recoup-Tasks (async jobs)
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
- **Website**: https://recoupable.com
