# Recoupable Platform Progress

_Last updated: 2026-03-16_

## Active Work

<!-- Agent: add new tasks here, remove when done -->

- [ ] Set up Tasks repo to read/write PROGRESS.md (coding-agent + update-pr tasks)

## Recent Completions

<!-- Agent: move finished items here with ISO date -->

- 2026-03-16: Added admin and marketing submodules to AGENTS.md (PR #26)
- 2026-03-16: Updated submodule pointers (PR #25)
- 2026-03-16: Added PROGRESS.md + PROGRESS_USAGE.md to mono repo root

## Known Issues / Blockers

<!-- Agent: log discovered bugs, blockers, or tech debt worth remembering -->

(none)

## Key Decisions

<!-- Agent: record architectural choices future tasks should respect -->

- `api` and `chat` PRs must target the `test` branch, not `main`
- Supabase calls go through `lib/supabase/[table_name]/[fn].ts` — never import client directly
- One exported function per file (SRP); no barrel re-exports
- Zod for all API input validation; pattern: `validate<Name>Body.ts` / `validate<Name>Query.ts`
- Tasks use Trigger.dev v4 SDK — never use deprecated `client.defineJob`
- `triggerAndWait()` returns `Result` — always check `result.ok` before `result.output`
- Never wrap `triggerAndWait` / `wait` calls in `Promise.all`

## Submodule Notes

<!-- Agent: add per-submodule context that isn't in CLAUDE.md -->

| Submodule | Target Branch | Notes |
|-----------|--------------|-------|
| api       | test          | payment middleware, MCP tools |
| chat      | test          | main Next.js frontend |
| tasks     | main          | Trigger.dev v4 background workers |
| admin     | main          | internal dashboard; recently added |
| cli       | main          | Commander.js + tsup |
| docs      | main          | Mintlify; update when API endpoints change |
| marketing | main          | recently added |
