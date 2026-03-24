# PROGRESS.md

> Last updated: 2026-03-17
> Purpose: Handoff notes for the next dev/agent picking up work.

---

## Current State of Each Submodule

### `tasks` (on `main`)
**Latest commits:**
- `fad189e` fix: push mono repo root progress files directly to main (#96)
- `e2599e7` fix: set cwd to `/vercel/sandbox/mono` for Claude Code agent (#94)
- `70f345c` feat: increase maxDuration of coding-agent task (#89)
- `6625395` feat: inject `CLAUDE_CODE_OAUTH_TOKEN` into sandbox environment (#86)

**Status:** Stable. The coding agent pipeline is working end-to-end:
1. Sandbox spins up → monorepo cloned → submodules synced
2. Claude Code agent runs with the user prompt (cwd = `/vercel/sandbox/mono`)
3. Changes are committed and PRs opened via `pushAndCreatePRsViaAgent`
4. Mono repo root files (e.g., `PROGRESS.md`) are pushed directly to `main`

**What to know:** `runClaudeCodeAgent` now defaults `cwd` to `/vercel/sandbox/mono`. The `pushAndCreatePRsViaAgent` agent handles both mono root changes (direct push to main) and submodule changes (feature branch + PR).

---

### `api` (on `test`)
**Latest commits:**
- `6ff735d` feat: add Slack chat bot integration for Record Label Agent (#296)
- `f1d9035` feat: add content-creation API endpoints and video persistence (#259)
- `5b1f6bc` feat: admin accounts table endpoint (#288)
- `6c5eda3` feat: endpoint to check if authenticated account is admin (#281)

**Status:** Stable on `test`. PRs target `test` branch, not `main`.

**What to know:** Slack integration added for Record Label Agent. Content-creation endpoints live. Admin-check endpoint added.

---

### `chat` (on `test`)
**Latest commits:**
- `03714296` feat: add navbar item for accounts (#1574)
- `729a9062` feat: task page top-left back link (#1573)
- `6efe316d` fix: duration stuck at 0ms for in-progress tasks (#1572)
- `eaeb5799` feat: polling UI for `prompt_sandbox` when `runId` present (#1563)
- `c3611b31` feat: move pulse to tasks page as Schedule/Recent/Pulse tabs (#1561)
- `c7fb2744` feat: artist connectors UI with tabbed settings modal (#1558)

**Status:** Stable on `test`. PRs target `test` branch.

**What to know:** Tasks page has been significantly built out — duration display, polling UI for sandbox runs, and pulse moved to tabs. Navbar now has accounts link.

---

### `cli` (on `main`, v0.1.11)
**Latest commits:**
- `a09929a` chore: bump version to 0.1.11
- `e4d4548` feat: add `recoup content` command suite (#13)
- `07e2b85` feat: add `music analyze` command (#7)
- `056257a` feat: add `--account` flag to notifications command (#12)

**Status:** Stable. Published to npm as `0.1.11`.

**What to know:** `recoup content` command suite added. `music analyze` command added. Version auto-bumped via CI.

---

### `docs` (on `main`)
**Latest commits:**
- `fd82b14` feat: add authentication page (#62)
- `0445501` docs: add CLI content command documentation (#61)
- `bf59ecf` docs: update `/api/admins/sandboxes` docs (#59)
- `e49f7ca` docs: add admin accounts table endpoint docs (#58)

**Status:** Stable. Docs are at `https://developers.recoupable.com`.

---

### `admin` (on `main`)
**Latest commits:**
- `3fcd006` feat: update favicon to match app (#6)
- `11b64e2` feat: accounts table with subscription status (#5)
- `5dd9571` feat: endpoint to check if account is admin (#3)
- `47295e8` feat: Privy login support (#2)
- `b53363f` feat: initial Next.js app setup (#1)

**Status:** Stable. Basic admin dashboard with Privy auth, accounts table, admin check, and new Org Repos commits table.

**What to know:** Added `/sandboxes/orgs` page showing a data table of commits per org sub-module. Key column is "Recent Commits" (latest_commit_messages array) showing up to 5 latest commit messages per repo. Data from `GET /api/admins/sandboxes/orgs`. New files: `types/sandbox.ts` (OrgRepoRow), `lib/fetchAdminSandboxOrgs.ts`, `hooks/useAdminSandboxOrgs.ts`, `components/SandboxOrgs/*`, `app/sandboxes/orgs/page.tsx`, `components/Home/OrgReposNavButton.tsx`. Nav button added to AdminDashboard.

---

## [2026-03-16] Account Task Runs Page + Pulse Sub-Task Tagging

**Prompt:** Admin page to view recent Pulse task runs for a specific account (e.g., "What Pulse emails has Alexis received in the past 7 days?")
**Status:** completed
**Changes:**
- `tasks`: Created `sendPulseTask` sub-task (`src/tasks/sendPulseTask.ts`). `sendPulsesTask` now calls `sendPulseTask.triggerAndWait(..., { tags: ['account:<id>'] })` per account so each run is queryable by account.
- `api`: Updated `validateGetTaskRunQuery.ts` to accept optional `account_id` query param. Admins (Bearer) can query any account; org API keys can query org members. New supabase fn `selectAllAccountSnapshotsWithOwners` returns `{account_id, github_repo}[]`. `buildSubmoduleRepoMap` now returns `AccountRepoEntry[]` with account_id. `getOrgRepoStats` + `getAdminSandboxOrgsHandler` enriched to include email in `account_repos`.
- `docs`: `openapi.json` — added `account_id` param to `GET /api/tasks/runs`, updated `OrgRepoRow.account_repos` schema to `{account_id, email, repo_url}[]`.
- `admin`: New `/accounts/[account_id]` page with `AccountDetailPage` + `TaskRunsTable` showing Pulse runs. `AccountReposList` updated — each entry shows clickable email → `/accounts/[id]`. `sandboxesColumns` — account email is now a clickable link to `/accounts/[id]`.
**PRs:** Branches pushed, PRs need to be created manually (gh not available in sandbox):
- tasks: `feature/pulse-sub-task-account-tag`
- api: `feature/task-runs-account-id-param` (target: `test`)
- docs: `feature/task-runs-account-id-param`
- admin: `feature/account-task-runs-page`
**Notes:** To answer "What Pulse emails has Alexis received?": find Alexis's `account_id` via `/sandboxes` page (or `/sandboxes/orgs`), then go to `/accounts/<id>` — the page shows all `send-pulse-task` runs for that account with status and timestamps.

---

## [2026-03-16] Pulse Run onClick — Email HTML Preview

**Prompt:** On /accounts/[account_id], clicking a send-pulse-task row should show the Resend email HTML sent during that task run.
**Status:** completed
**Changes:**
- `api`: New `lib/supabase/memory_emails/selectAccountEmailIds.ts` — joins rooms → memories → memory_emails to get Resend email IDs for an account. New `lib/admins/emails/getAdminEmailsHandler.ts` + `app/api/admins/emails/route.ts` — `GET /api/admins/emails?account_id=<id>` fetches each email from Resend SDK (returns id, subject, to, from, html, created_at). Admin Bearer auth required.
- `admin`: `TaskRunsTable` — added optional `onRunClick` prop; rows show `cursor-pointer` when clickable. `AccountDetailPage` — tracks `selectedRun` state, passes `onRunClick` to pulse runs table. New `PulseEmailModal` — fetches all emails for the account via `usePulseEmails`, matches the email closest to the run's time window (±5 min buffer), renders HTML in a sandboxed iframe. New `usePulseEmails` hook (lazy, enabled only when modal opens). New `fetchAccountPulseEmails` lib function.
**PRs:** Branches pushed, PRs need to be created manually:
- api: `feature/admin-pulse-email-preview` (target: `test`)
- admin: `feature/pulse-email-preview` (target: `main`)
**Notes:** Email matching uses the run's `startedAt`/`finishedAt` window ±5 min. Falls back to the most recent email for the account if no match. The `memory_emails` table is the link — emails only appear here if `handleSendEmailToolOutputs` was called after the pulse (i.e., the sandbox chat flow ran through the standard chat handler). If pulse emails aren't showing, check that `memory_emails` rows are being inserted for pulse runs.

---

## [2026-03-17] Admin README — API Calls Documentation

**Prompt:** Update the Admin README to highlight the API calls used and link to the docs where devs can learn more.
**Status:** completed
**Changes:**
- `admin`: Rewrote `README.md` — added "API Calls" section with a table of all 5 endpoints (`/api/admins`, `/api/admins/emails`, `/api/admins/sandboxes`, `/api/admins/sandboxes/orgs`, `/api/tasks/runs`), doc links to `developers.recoupable.com`, and a "Where each call is made" breakdown per hook/lib file. Also updated Tech Stack section to include Privy and TanStack React Query.
**PRs:** none (README-only change)
**Notes:** Doc links point to `https://developers.recoupable.com/api-reference/admins/*` and `.../tasks/runs`. All admin endpoints require Bearer auth (Privy access token).

---

## [2026-03-17] Admin Privy Logins Page

**Prompt:** Admin dashboard page to review Privy logins on a daily, weekly, and monthly basis — total count + table of results per time frame.
**Status:** completed
**Changes:**
- `docs`: Added `GET /api/admins/privy` to `openapi.json` (path + `PrivyLoginRow` / `AdminPrivyLoginsResponse` schemas), new `api-reference/admins/privy.mdx`, updated `docs.json` nav.
- `api`: New `lib/admins/privy/fetchPrivyLogins.ts` — paginates Privy Management API, stops early once users are older than the cutoff. New `validateGetPrivyLoginsQuery.ts` (period: daily/weekly/monthly, default daily). New `getPrivyLoginsHandler.ts`. New `app/api/admins/privy/route.ts`. 11 unit tests, all green.
- `admin`: New `types/privy.ts`, `lib/recoup/fetchPrivyLogins.ts`, `hooks/usePrivyLogins.ts`. New `/privy` page with period toggle (Daily/Weekly/Monthly), total count badge, and login table (email, Privy DID, timestamp). Added "View Privy Logins" nav button to `AdminDashboard`.
**PRs:** Branches pushed — PRs need to be opened via GitHub:
- docs: `feature/admin-privy-logins-docs` → main: https://github.com/recoupable/docs/pull/new/feature/admin-privy-logins-docs
- api: `feature/admin-privy-logins` → test: https://github.com/recoupable/api/pull/new/feature/admin-privy-logins
- admin: `feature/privy-logins-page` → main: https://github.com/recoupable/admin/pull/new/feature/privy-logins-page
**Notes:** `fetchPrivyLogins` paginates `GET https://api.privy.io/v1/users?order=desc` and stops early once `created_at < cutoff`. This keeps the daily call fast (only fetches recent pages). If Privy returns users without `linked_accounts` email, the row shows `null` for email.

---

## [2026-03-17] API — Remove Org API Key Logic (All Keys Are Personal)

**Prompt:** All API keys are personal. If a personal account has access to an org, it can use account_id filtering within that org. Remove the distinction between personal and org API keys for access control.
**Status:** completed
**Changes:**
- `api`: New `lib/organizations/canAccessAccountViaAnyOrg.ts` — checks if two accounts share any org membership (2 DB queries: get current account's orgs, then check if target is in any of them). New `lib/organizations/__tests__/canAccessAccountViaAnyOrg.test.ts` (4 tests). Updated `lib/auth/validateAccountIdOverride.ts` — when `orgId` is null (personal key) and target ≠ self, falls back to `canAccessAccountViaAnyOrg()` instead of immediately returning 403. Updated `lib/auth/__tests__/validateAuthContext.test.ts` — updated "denies personal key" test to mock the new function, added "allows personal key with shared org" test. All 1526 tests pass.
**PRs:** Branch `agent/remove-org-api-key-logic` pushed to `recoupable/api` (target: `test`):
- https://github.com/recoupable/api/pull/new/agent/remove-org-api-key-logic
**Notes:** Only `validateAccountIdOverride.ts` was changed in auth. The `buildGet*Params` functions that receive `orgId` from auth context don't need changes — when a personal key accesses via shared org, `orgId` in the auth context stays `null`, and the query params builders already handle `orgId: null` by not filtering on org. The access gate is purely in `validateAccountIdOverride`.

---

## [2026-03-24] AutoResearch Integration — Deep Analysis & Roadmap

**Prompt:** Read autoresearch (github.com/karpathy/autoresearch), analyze the mono repo, and ULTRATHINK how to use autoresearch to add value to customers. Propose a way to run autoresearch easily (API endpoint, sandbox, skill).
**Status:** analysis complete — no code written yet, roadmap ready for implementation
**Changes:** none (analysis/planning only)
**PRs:** none

---

### What autoresearch actually is

Karpathy's autoresearch is an **autonomous iterative optimization loop** for ML training:
- An AI agent (Claude Code) edits `train.py`, runs a fixed 5-minute experiment, measures `val_bpb`, keeps improvements and reverts regressions, then loops forever
- Human direction via a `program.md` skill file written in natural language
- Git is the lab notebook — every iteration is a commit; reverts are `git reset`
- Produces ~12 experiments/hour, ~100 per overnight session

**The insight that matters:** The actual ML training is incidental. The **PATTERN** is the product:

```
define a metric → agent proposes change → run experiment → measure → keep/revert → log → repeat
```

This pattern is universally applicable to any domain where:
1. Success is measurable (even approximately)
2. Hypotheses can be tested cheaply
3. Overnight unattended runs make economic sense

---

### How this maps to Recoupable's customers (music artists & labels)

Music artists face research problems where this pattern is extremely valuable:

| Problem | Metric | Experiment type | Overnight value |
|---------|--------|-----------------|-----------------|
| Pulse email effectiveness | open rate, reply rate | subject line variants, body style, timing, personalization depth | Agent tests 20+ variants while artist sleeps |
| Playlist curator targeting | response rate | curator selection, pitch angle, personalization | Ranks which pitching approaches work for a genre |
| Sync licensing leads | acceptance rate | platform, territory, mood tags, pitch framing | Finds which briefs match the artist's catalog |
| Fan segment research | engagement prediction accuracy | segmentation approach, feature selection | Surfaces which fan cohorts are most actionable |
| Social content strategy | engagement rate | post format, copy length, hashtag sets, posting time | Finds what resonates for the artist's audience |

**The biggest immediate win: Pulse email autoresearch**

Recoupable already has Pulse (sends emails to fans, tracks engagement). The autoresearch loop would:
1. After each Pulse batch, log the performance (open rate, replies)
2. Agent analyzes what varied and proposes the next variant
3. Next Pulse batch uses the new variant
4. Repeat — fans get increasingly well-targeted emails, artists see compounding engagement improvements

This is zero net new infrastructure cost and directly improves the core product.

---

### Proposed architecture: autoresearch as a service

The user wants this to work "like music flamingo" — a sandboxed API endpoint.

#### New API endpoints (in `api` submodule)

```
POST   /api/research/runs         # start a research run
GET    /api/research/runs         # list runs for authenticated account
GET    /api/research/runs/:id     # get run + all iterations
DELETE /api/research/runs/:id     # cancel an in-progress run
```

**POST /api/research/runs body:**
```json
{
  "objective": "Find best subject line strategy for hip-hop artists",
  "metric": "open_rate",
  "max_iterations": 20,
  "context": "artist_id optional — narrows data scope"
}
```

**GET /api/research/runs/:id response:**
```json
{
  "id": "uuid",
  "status": "running|completed|failed",
  "objective": "...",
  "metric": "open_rate",
  "best_result": { "value": 0.42, "iteration": 7, "hypothesis": "..." },
  "iterations": [
    { "n": 1, "hypothesis": "try ...", "result": 0.35, "kept": false },
    { "n": 7, "hypothesis": "...", "result": 0.42, "kept": true }
  ]
}
```

#### New Supabase tables (in `database` submodule)

```sql
-- research_runs
id, account_id, objective, metric, status, max_iterations,
iterations_completed, best_result_value, best_hypothesis,
created_at, completed_at

-- research_iterations
id, run_id, iteration_n, hypothesis, result_value, kept,
agent_reasoning, created_at
```

#### New Trigger.dev task (in `tasks` submodule)

`src/tasks/autoresearchTask.ts` — the loop:
1. Load run config + prior iterations from Supabase
2. Build a prompt: objective, metric, all prior iterations as "lab notebook"
3. Call Claude API to propose the next hypothesis + experiment design
4. Execute the experiment (e.g., call the Pulse API, query analytics)
5. Measure the metric
6. Log the iteration (kept/discarded)
7. Update `research_runs.best_result` if improved
8. Loop until `max_iterations` or `status = cancelled`

Key: each iteration is ~$0.02 in Claude API cost — 20 iterations = $0.40 per research run.

#### New MCP tools (in `api` submodule)

```typescript
// lib/mcp/tools/research/registerStartResearchTool.ts
start_research(objective, metric, max_iterations?)
  → returns run_id

// lib/mcp/tools/research/registerGetResearchResultsTool.ts
get_research_results(run_id)
  → returns status + iterations + best result
```

#### New skill (in `skills` submodule)

`autoresearch.md` skill that teaches any Claude agent how to:
1. Frame a music business question as an autoresearch objective
2. Choose the right metric (what does success look like?)
3. Call `start_research` and poll `get_research_results`
4. Interpret and act on the findings

---

### Implementation sequence (recommended order)

**Step 1 — Database** (`database` submodule)
- Migration: add `research_runs` and `research_iterations` tables

**Step 2 — Supabase lib** (`api` submodule)
- `lib/supabase/research_runs/insertResearchRun.ts`
- `lib/supabase/research_runs/selectResearchRuns.ts`
- `lib/supabase/research_runs/updateResearchRun.ts`
- `lib/supabase/research_iterations/insertResearchIteration.ts`
- `lib/supabase/research_iterations/selectResearchIterations.ts`

**Step 3 — Domain logic + API endpoints** (`api` submodule)
- `lib/research/startResearchRun.ts` — validates + inserts + triggers task
- `lib/research/getResearchRun.ts` — fetches run + iterations
- `app/api/research/runs/route.ts` — GET (list) + POST (create)
- `app/api/research/runs/[id]/route.ts` — GET (detail) + DELETE (cancel)
- Tests for all handlers

**Step 4 — Trigger.dev task** (`tasks` submodule)
- `src/tasks/autoresearchTask.ts` — the loop itself
- Uses Claude `claude-sonnet-4-6` via Anthropic SDK
- Context window = prior iteration log (keeps the "lab notebook" pattern)

**Step 5 — MCP tools** (`api` submodule)
- `lib/mcp/tools/research/registerStartResearchTool.ts`
- `lib/mcp/tools/research/registerGetResearchResultsTool.ts`
- Register in `lib/mcp/tools/index.ts`

**Step 6 — Chat UI** (`chat` submodule)
- Research runs as a new task type in the Tasks page
- Shows iteration progress, best result, log of hypotheses tried

**Step 7 — Skill** (`skills` submodule)
- `autoresearch.md` skill for agents

---

### Why this is high-leverage

- **Turns Pulse from a send tool into an optimize tool** — biggest single product improvement possible
- **Compounds over time** — each artist's research history makes the next run smarter
- **Overnight autonomy** — matches Karpathy's original insight: humans set direction, AI works while they sleep
- **Fits existing infra perfectly** — Trigger.dev loops already exist, Claude API already used, Supabase already the persistence layer
- **Low marginal cost** — each 20-iteration run costs ~$0.40 in LLM calls; can price as a premium feature

---

**Notes for next dev:**
- Start with Step 1 (database migration) — unblocks all subsequent work
- The Trigger.dev autoresearch loop is the hardest piece — the agent needs a well-structured system prompt that includes the full iteration history as the "lab notebook"
- Consider rate-limiting: max 1 active research run per account to start
- The `program.md` equivalent is the `objective` + `metric` fields — keep them simple and human-readable
- Pulse is the killer first use case — wire it up so completed Pulse runs auto-trigger a background research iteration analyzing what worked

---

## Known Issues / Next Steps

- `SUBMODULE_CONFIG` in `tasks/src/sandboxes/submoduleConfig.ts` does **not** include `admin` or `marketing` — if the agent modifies those submodules, PRs won't be auto-created. Consider adding them.
- No `PROGRESS_USAGE.md` exists yet — if this file should have a companion usage guide, create it.
- The `progress.txt` init file referenced in the task prompt was not found — likely hasn't been created yet, or was intended as a seed for future use.

---

## Architecture Reminder

```
chat (frontend) → api (backend) → Supabase (database)
                              ↘ tasks (async Trigger.dev jobs)
```

- **Coding agent flow:** Trigger.dev task → Vercel Sandbox → Claude Code CLI (`claude -p --dangerously-skip-permissions`) → git commit/push → PR via `gh`
- PRs for `api` and `chat` target `test` branch; all others target `main`
- Admin check: POST `/api/admins/check` — verifies if authenticated Privy user is in admins table

## [2026-03-17] Docs — Added response items for GET /api/admins/privy

**Prompt:** Update docs for GET /api/admins/privy to include the latest API response — missing default of `all` for period and missing response fields (`total_new`, `total_active`, `total_privy_users`)
**Status:** completed
**Changes:**
- `docs`: Updated `api-reference/openapi.json` — added `all` to `period` enum (set as default, replacing incorrect `daily` default); added missing 200 response fields: `total_new`, `total_active`, `total_privy_users`; updated endpoint description to reflect actual API behavior.
**PRs:** Branch `agent/-u0ajm7x8fbr-docs---added-resp-1773769254740` pushed to `recoupable/docs` — PR targeting `main`.
**Notes:** Actual API code (`validateGetPrivyLoginsQuery.ts`) defaults `period` to `"all"` (no date filter). Handler returns `{ status, total, total_new, total_active, total_privy_accounts, logins }`.

---

## [2026-03-17] Docs — Rename total_privy_users to total_privy_accounts

**Prompt:** Change `total_privy_users` to `total_privy_accounts` in the GET /api/admins/privy OpenAPI spec.
**Status:** completed
**Changes:**
- `docs`: Renamed `total_privy_users` → `total_privy_accounts` in `api-reference/openapi.json` (required field list, property name, and description).
**PRs:** Pushed to existing branch `agent/-u0ajm7x8fbr-docs---added-resp-1773769254740` on `recoupable/docs`.
**Notes:** Matches the API response field naming convention (accounts, not users).

---

## [2026-03-24] Paperclip Research — Integration Analysis

**Prompt:** Research https://github.com/paperclipai/paperclip and deeply think about how to integrate it (or its concepts) into this codebase.
**Status:** completed (research only — no code changes)
**Changes:** None. Research and recommendations captured here for the next dev.

---

### What Paperclip Is

Paperclip (MIT, 32k+ stars, v0.3.1) is a **multi-agent orchestration platform** — *"if OpenClaw is an employee, Paperclip is the company."* It provides the organizational layer above individual AI agents: org charts, goal hierarchies, heartbeat scheduling, budget controls, governance, and skills injection.

**Tech stack:** Node.js 20+, TypeScript, Express.js, PostgreSQL, React UI. Runs as a self-hosted server at `http://localhost:3100`.

**Key concepts:**
- **Org hierarchy**: Company → Project → Goal → Task → Agent
- **Heartbeat scheduling**: Agents wake on a schedule, check assigned work, execute
- **Per-agent budgets**: Monthly spend cap with auto-pause at 80%/100%
- **Skills injection**: `SKILL.md` files served via `GET /api/skills/index` at runtime — agents load skills dynamically without retraining
- **Approval gates**: Human-in-the-loop before high-stakes agent actions
- **Audit logs**: Immutable append-only logs with full tool-call traces
- **HTTP adapter system**: Normalized adapter for Claude Code, Codex, Cursor, Gemini, OpenCode — any agent type
- **Plugin ecosystem**: Webhooks, tools, UI slots, launchers

---

### How Paperclip Concepts Map to Recoupable

| Paperclip Concept | Recoupable Equivalent | Gap |
|---|---|---|
| Heartbeat scheduling | Pulses (`sendPulsesTask` → `sendPulseTask`) | Pulses are email-only, daily-only, not configurable |
| Org hierarchy | Account → Org → Artist → Chat/Task | No "goal/campaign" layer between artist and task |
| Per-agent budget | Credits (`lib/credits/`) | Credits only track chat usage — not sandbox/pulse executions |
| Skills injection | `skills/` submodule monorepo | No HTTP skills index endpoint — agents can't discover skills at runtime |
| Audit logs | Basic logging | No structured per-tool-call audit trail in DB |
| Agent lifecycle | Coding agent Redis states (`running/updating/failed`) | Only coding agent has state; general/pulse agents have none |
| Approval gates | None | No human-in-the-loop workflow exists |
| HTTP agent adapters | Separate agent types (chat, coding, pulse) | No normalized adapter interface |

---

### Integration Recommendations (Prioritized)

**Tier 1 — High value, low effort (implement next):**

1. **Skills Index Endpoint** (`api`)
   - Add `GET /api/skills` that reads the `skills/` submodule, parses YAML frontmatter from each `SKILL.md`, and returns `[{ name, description, url }]`
   - Agents can call this at runtime to discover available skills
   - Aligns exactly with Paperclip's `GET /api/skills/index` pattern
   - Files to create: `api/lib/skills/getSkillsHandler.ts`, `api/app/api/skills/route.ts`

2. **Agent Audit Logging** (`api`)
   - Log every MCP tool call to a new `agent_tool_calls` Supabase table: `(id, account_id, tool_name, input_json, output_summary, cost_usd, duration_ms, created_at)`
   - Add middleware in `api/lib/mcp/tools/` that wraps each tool handler
   - Surface in admin dashboard under `/accounts/[id]`
   - Value: Debugging, accountability, understanding what agents actually do

3. **Sandbox Execution Cost Tracking** (`tasks` + `api`)
   - After each `sendPulseTask` and `codingAgentTask` completes, POST cost to `POST /api/credits/sandbox` with `{ account_id, execution_type: 'pulse'|'coding', duration_ms, model }`
   - Store in existing `credits_usage` table with new `execution_type` column
   - Value: Full picture of per-account AI spend (not just chat)

**Tier 2 — High value, medium effort (plan for Q2):**

4. **Generalized Heartbeat System** (evolve Pulses)
   - Pulses are currently email-only, daily-only. Evolve to general "agent heartbeats":
     - Configurable frequency (hourly, daily, weekly, custom cron)
     - Configurable output type (email, Slack message, task creation, webhook)
     - Configurable trigger (schedule, event, threshold)
   - `pulse_accounts` table gains `frequency`, `output_type`, `trigger_config` columns
   - `sendPulsesTask` reads config and routes accordingly
   - Value: Unlocks recurring agent intelligence across many use cases

5. **Campaign/Goal Layer** (`api` + `chat`)
   - Add "campaigns" between Artist and Tasks: `Organization → Artist → Campaign → Task`
   - A campaign has a goal ("Release EP 'Lost in Time'"), a deadline, and spawns tasks
   - Agents work toward campaign goals autonomously — proactive rather than reactive
   - New DB table: `campaigns (id, artist_id, name, goal, deadline, status)`
   - New MCP tools: `create_campaign`, `get_campaigns`, `update_campaign`
   - Value: Transforms Recoupable from reactive chat to proactive goal-driven artist management

6. **Agent Lifecycle Management** (`api` + `admin`)
   - Extend Redis state management beyond coding agent to ALL agent types
   - Track status for: general chat agents, pulse agents, coding agents
   - Add unified `GET /api/agents/status` + `POST /api/agents/:id/pause|resume|terminate`
   - Surface in admin dashboard
   - Value: Operational visibility and control over all running agents

**Tier 3 — Strategic, high effort (future roadmap):**

7. **Approval Gates** — Human-in-the-loop for high-stakes actions (e.g., bulk fan email, large spend)
8. **HTTP Agent Adapter Pattern** — Normalized `AgentAdapter` interface wrapping coding/chat/pulse agents
9. **Per-Account Monthly Budget Caps** — Auto-pause accounts at spend threshold, configurable per subscription tier

---

### Should We Embed Paperclip Directly?

**Short answer: No — adopt concepts, not the codebase.**

Reasons not to embed Paperclip directly:
- Adds a full Express.js + PostgreSQL server to a Next.js + Supabase stack (tech sprawl)
- Paperclip's auth model (JWT per agent) conflicts with Recoupable's Privy/API-key auth
- Most valuable Paperclip features (skills injection, heartbeats, org hierarchy) are already partially built in Recoupable's architecture
- MIT license allows forking concepts without taking the dependency

**Best path:** Cherry-pick Paperclip's patterns (skills endpoint, heartbeat model, audit logs, adapter pattern) and implement them natively in the existing Recoupable stack. This preserves architectural coherence while gaining the most valuable ideas.

---

**PRs:** none (research task)
**Notes:** The `@U0AJM7X8FBR` Slack user requested this research. Tier 1 items can each be implemented as a focused 2–4 hour coding agent task. Start with the Skills Index Endpoint as it's the most self-contained and directly mirrors Paperclip's design.

---
