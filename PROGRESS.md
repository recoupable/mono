# PROGRESS.md

> Last updated: 2026-03-19
> Purpose: Handoff notes for the next dev/agent picking up work.

---

## Current State of Each Submodule

### `tasks` (on `main`)
**Latest commits:**
- `[pending]` feat: inject `CHARTMETRIC_REFRESH_TOKEN` into sandbox env and openclaw.json
- `fad189e` fix: push mono repo root progress files directly to main (#96)
- `e2599e7` fix: set cwd to `/vercel/sandbox/mono` for Claude Code agent (#94)
- `70f345c` feat: increase maxDuration of coding-agent task (#89)
- `6625395` feat: inject `CLAUDE_CODE_OAUTH_TOKEN` into sandbox environment (#86)

**Status:** In progress — PR open for stdout context passing fix.

**What to know:** `runClaudeCodeAgent` now defaults `cwd` to `/vercel/sandbox/mono`. The `pushAndCreatePRsViaAgent` agent handles both mono root changes (direct push to main) and submodule changes (feature branch + PR).

**Pending PR:** Branch `fix/coding-agent-stdout-context` pushed to `recoupable/tasks`. PR needs to be opened: https://github.com/recoupable/tasks/pull/new/fix/coding-agent-stdout-context (base: `main`). `agentStdout` is now passed from the coding agent step into `pushAndCreatePRsViaAgent` so the git push agent has full context of what was changed. This fixes the bug where context was lost between the two agent steps and the push agent would incorrectly report no changes.

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

## [2026-03-19] Prevent API Keys for Org Accounts (DB Migration)

**Prompt:** Add a migration that prevents API keys from being created where `account_api_keys.account` equals an `organization_id` in `account_organization_ids`.
**Status:** completed
**Changes:**
- `database`: New migration `20260319000000_prevent_org_account_api_keys.sql` — creates `prevent_org_account_api_keys()` trigger function and attaches it as a `BEFORE INSERT OR UPDATE` trigger on `account_api_keys`. Raises an exception if the target `account` value exists as an `organization_id` in `account_organization_ids`.
**PRs:** none (migration-only change, needs to be applied via Supabase CLI)
**Notes:** The check queries `account_organization_ids.organization_id = NEW.account`. Org accounts are defined as rows where the account appears in the `organization_id` column. Member accounts (`account_id` column) are unaffected and can still have API keys.

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
## [2026-03-17] API — GET /api/admins/privy — Fix total field and remove total_active

**Prompt:** Remove `total_active_users` from the response and update `total` to use the same logic (active users count within period).
**Status:** completed
**Changes:**
- `api`: `getPrivyLoginsHandler.ts` — changed `total: users.length` to `total: total_active` (i.e., `countActiveAccounts(users, period)`); removed `total_active` and `total_privy_users` from response. Updated unit tests to match.
- `docs`: `api-reference/openapi.json` — removed `total_active` from required fields and properties; updated `total` description to "Number of accounts active (latest_verified_at) within the requested period".
**PRs:**
- api: `feature/privy-total-active-users-fix` → test: https://github.com/recoupable/api/pull/new/feature/privy-total-active-users-fix
- docs: `feature/privy-total-active-users-fix` → main: https://github.com/recoupable/docs/pull/new/feature/privy-total-active-users-fix
**Notes:** `total` is now the count of accounts whose `latest_verified_at` (across all linked_accounts) falls within the requested period. This matches what the docs page (developers.recoupable.com) shows as the intended `total` definition.

---

## [2026-03-17] Docs — All API Keys Are Personal (Remove Org Key Distinction)

**Prompt:** Update docs to reflect new API key architecture: all keys are personal. If a personal account has access to an org, it can use account_id filtering within that org. Remove "organization API keys" vs "personal API keys" distinction.
**Status:** completed
**Changes:**
- `docs`: `authentication.mdx` — removed "Personal vs. Organization API Keys" section and "How We Determine Key Type at Creation" section. Added "Access to Organizations" subsection under API Keys explaining that org members can use account_id filtering. Updated access-control diagram to remove personal/org key distinction.
- `docs`: `openapi.json` — updated all `account_id` parameter descriptions from "Only applicable for organization API keys - org keys can filter to any account within their organization. Personal keys cannot use this parameter." → "Only applicable to accounts the provided API Key has access to - keys can filter to any account within their organizations." Also updated all endpoint-level descriptions (chats, artists, sandboxes, pulses, orgs, etc.) to remove personal/org key distinction.
**PRs:** Branch `feature/personal-api-keys-docs` pushed to `recoupable/docs` — open PR at: https://github.com/recoupable/docs/pull/new/feature/personal-api-keys-docs (target: `main`)
**Notes:** This is docs-only. API and Chat changes (actual auth logic) are a separate PR per task scope. The new descriptions say "Only applicable to accounts the provided API Key has access to" which covers both own-account and org-member access uniformly.

---

## [2026-03-17] API — Formatter GitHub Action

**Prompt:** Add a GitHub Action that automatically runs the formatter (`pnpm format:check`) on all pull requests so all code changes follow standardized formatting.
**Status:** completed
**Changes:**
- `api`: Created `.github/workflows/format.yml` — runs `pnpm format:check` (Prettier) on every PR targeting `main` or `test`. Mirrors the existing `test.yml` pattern (Node 20, pnpm 9). PR fails if any file doesn't match Prettier standards.
**PRs:** Branch `feature/formatter-github-action` pushed to `recoupable/api` — PR needs to be opened manually (target: `test`): https://github.com/recoupable/api/pull/new/feature/formatter-github-action
**Notes:** `gh` CLI not available in sandbox so PR was not auto-created. The workflow only runs on `pull_request` events (not `push`), so it won't retroactively flag existing code on main/test — only new PRs.

---

## [2026-03-17] Admin — Remove total_privy_users from PrivyLoginsResponse type

**Prompt:** Remove `total_privy_users` from the `PrivyLoginsResponse` type in the admin repo (the `PrivyLoginsStats` component only uses `total_new` and `total_active`).
**Status:** completed
**Changes:**
- `admin`: Removed `total_privy_users: number` field from `PrivyLoginsResponse` type in `types/privy.ts`.
**PRs:** admin: `feature/remove-total-privy-users-type` → main: https://github.com/recoupable/admin/pull/new/feature/remove-total-privy-users-type
**Notes:** No UI changes needed — `PrivyLoginsStats` never rendered `total_privy_users`.

---

## [2026-03-19] Architecture — Chartmetric API Key in Sandbox (No Key Exposure)

**Prompt:** How can we give Recoup the ability to use a Chartmetric API key in a sandbox without exposing the key?
**Status:** architecture design — no code written yet
**Changes:** none (design/research task)
**PRs:** none
**Notes:**
Three options evaluated — **Option 1 (API Proxy + MCP tools) is recommended** as it fits the existing architecture:

1. **API Proxy + MCP tools (recommended):** Store `CHARTMETRIC_API_KEY` in Vercel env vars for the `api` service only. Build `lib/chartmetric/` domain functions internally. Expose MCP tools (`chartmetric_get_artist`, etc.) in `lib/mcp/tools/chartmetric/` that call those functions. Optionally add `app/api/chartmetric/[...path]/route.ts` REST proxy for non-MCP callers. Key never enters the sandbox.

2. **Short-lived token injection (simpler):** In `tasks`, exchange the Chartmetric `refresh_token` for a 1-hour `access_token` via `POST https://api.chartmetric.com/api/token`. Inject only the `access_token` (not the refresh token or key) into the sandbox env. Token expires after the sandbox run — reduced blast radius even if the agent reads it.

3. **MCP-only (strictest):** Same as Option 1 but no REST proxy — Chartmetric is only callable via MCP tools. Key stays entirely in `api` service env.

**Implementation plan for Option 1:**
- Add `CHARTMETRIC_API_KEY` to Vercel env (api service only)
- `lib/chartmetric/fetchChartmetric.ts` — internal fetch wrapper
- `lib/mcp/tools/chartmetric/` — register MCP tools
- `app/api/chartmetric/[...path]/route.ts` — authenticated REST proxy (optional)
- Pattern mirrors existing MCP tools: `get_chats`, `get_pulses`, etc.

---

## [2026-03-19] Database — Migrate Org API Keys to Personal Account (audit trail added)

**Prompt:** Apply feedback on migration — document the 12 specific API keys confirmed to be impacted.
**Status:** completed
**Changes:**
- `database`: Updated `20260318000000_migrate_org_api_keys_to_personal_account.sql` — added a comment block listing the 12 specific `account_api_keys` rows confirmed to be affected at review time (2026-03-19) as an audit trail. The SQL logic itself is unchanged (dynamic subquery approach retained so any keys created after review are also migrated).
**PRs:** Branch `feature/migrate-org-api-keys-to-personal-account` pushed to `recoupable/database` — PR targeting `main`.
**Notes:** 12 impacted keys span 5 org accounts: `cebcc866` (5 keys), `04e3aba9` (3 keys), `82bde32c` (2 keys), `6e544578` (1 key), `460c4cda` (1 key). All will be reassigned to personal account `fb678396-a68f-4294-ae50-b8cacf9ce77b`. Apply via `supabase db push` or Supabase dashboard after PR is merged.

---

## [2026-03-19] Cleanup Org API Key Terminology — Docs & API

**Prompt:** Remove all "org key" / "organization API key" references from docs openapi.json and API codebase. Update docs to use neutral "API key" / membership-based language. Remove dead lib/keys/org/ code from API.
**Status:** completed
**Changes:**
- `docs`: Updated `api-reference/openapi.json` — 24 lines updated. Removed all "org key"/"org API key" phrasing. Updated `account_id` param descriptions from "org keys only" to "accounts within your organizations". Updated pulses array description to remove personal/org key distinction. Updated 403 error descriptions from "personal key tried to filter" to "account tried to filter by an account_id they don't have access to".
- `api`: Deleted `lib/keys/org/` directory (3 dead files: `createOrgApiKeysHandler.ts`, `getOrgApiKeysHandler.ts`, `onlyOrgAccounts.ts`). Simplified `createApiKeyHandler.ts` and `getApiKeysHandler.ts` to remove `organizationId` delegation branches. Removed `organizationId` from `validateCreateApiKeyBody.ts`. Cleaned up ~50+ stale "org key" / "For org keys:" / "For personal keys:" comments across handlers, validators, MCP tools, tests, and AGENTS.md. Updated `lib/auth/validateAuthContext.ts`, `validateAccountIdOverride.ts`, `lib/organizations/validateGetOrganizationsRequest.ts`, `lib/chats/validateGetChatsRequest.ts`, `lib/chats/getChatsHandler.ts`, `lib/artists/validateGetArtistsRequest.ts`, pulse handlers, sandbox validators, notification handlers, and all associated test descriptions.
**PRs:**
- docs: https://github.com/recoupable/docs/pull/71 (feat/remove-org-key-terminology → main)
- api: changes pushed directly to `test` branch (commit `5dbcacf`)
**Notes:** All keys are personal. Org access is determined at access-check time via account membership (`canAccessAccount`). No code logic was changed — only terminology/comments. Lint was run and auto-fixed formatting.

---

## Known Issues / Next Steps

- `SUBMODULE_CONFIG` in `tasks/src/sandboxes/submoduleConfig.ts` does **not** include `admin` or `marketing` — if the agent modifies those submodules, PRs won't be auto-created. Consider adding them.
- `CHARTMETRIC_REFRESH_TOKEN` must be added to Trigger.dev secrets for the chartmetric skill to work in sandboxes (see 2026-03-19 entry).

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

## [2026-03-19] Chartmetric skill — sandbox env injection

**Prompt:** Give sandbox agents access to the Chartmetric API key so they can use the chartmetric skill without exposing the key.
**Status:** completed
**Changes:**
- `tasks`: `src/sandboxes/getSandboxEnv.ts` — added optional `CHARTMETRIC_REFRESH_TOKEN` injection (same pattern as `GITHUB_TOKEN`; no-op if env var not set).
- `tasks`: `src/sandboxes/setupOpenClaw.ts` — added optional `CHARTMETRIC_REFRESH_TOKEN` injection into openclaw.json's `env` block so the OpenClaw agent and all subprocess spawns get it.
**PRs:** PR needed — branch not yet pushed (done via direct edit in sandbox).
**Notes:**
- **Action required:** Add `CHARTMETRIC_REFRESH_TOKEN` to Trigger.dev environment secrets (same place as `RECOUP_API_KEY`, `GITHUB_TOKEN`, `CLAUDE_CODE_OAUTH_TOKEN`).
- The chartmetric skill (`skills/chartmetric`) is pre-installed in sandboxes at `.recoup/skills/chartmetric`. Its Python scripts read `CHARTMETRIC_REFRESH_TOKEN` from env and call the Chartmetric API directly — no new tools needed.
- The key is optional; existing sandboxes without it won't break.
- **Open question — tying Chartmetric usage to account credits:** The cleanest approach is to proxy Chartmetric API calls through `recoup-api.vercel.app` (e.g. `POST /api/chartmetric/search`). The proxy route authenticates via `RECOUP_API_KEY` + `RECOUP_ACCOUNT_ID`, deducts credits, then forwards to Chartmetric. The skill would point `CHARTMETRIC_BASE_URL` at the proxy instead of calling Chartmetric directly. This keeps the Chartmetric key server-side only and gives per-account usage tracking. Alternatively, log calls client-side via a lightweight fire-and-forget `POST /api/usage` call from the skill's bash wrapper — simpler but less reliable (agent could skip it). Proxy approach is recommended for production.
## [2026-03-19] Investigation — Content Pipeline Credit System Integration

**Prompt:** How should the content/ API be connected to the credit system so customers use credits when they run the content pipeline? Investigate existing credit system, propose usage-based pricing with margin.
**Status:** investigation complete — implementation not started
**Changes:** none (research only)
**PRs:** none

### Key Findings

**Credit system (fully implemented):**
- Table: `credits_usage` — `account_id`, `remaining_credits`, `timestamp`
- 1 credit = $0.01 USD (conversion via `Math.ceil(usdCost * 100)`)
- Core deduction fn: `api/lib/credits/deductCredits.ts` — validates balance, updates DB, throws on insufficient credits
- Chat/LLM credits: token-based via `handleChatCredits.ts` → `getCreditUsage.ts` (actual model pricing × tokens)
- Image credits: flat $0.15 = 15 credits via `fetchWithPayment.ts`
- Free tier: 333 credits. Pro tier: 1,000 credits/month (reset by `checkAndResetCredits` in chat)

**Content pipeline (credit deduction NOT YET IMPLEMENTED):**
- `POST /api/content/create` → `createContentHandler.ts` triggers Trigger.dev task — no credit check or deduction exists today
- `GET /api/content/estimate` → `getContentEstimateHandler.ts` has the cost logic already: base cost = `$0.82` (image-to-video) or `$0.95` (audio-to-video/lipsync), multiplied by `batch`
- The `validated.accountId` is already available at the top of `createContentHandler` (auth is fully resolved), so credit deduction can be dropped in right after validation

**Implementation — 3 files to touch in `api`:**

1. **NEW `api/lib/content/getContentCreditCost.ts`** — pure function, returns `creditsToDeduct` given `{ lipsync, upscale, batch }`. Constants: `BASE_VIDEO_CREDITS = 165`, `LIPSYNC_EXTRA_CREDITS = 25`, `UPSCALE_CREDITS = 30`.
2. **MODIFY `api/lib/content/createContentHandler.ts`** — call `getContentCreditCost()`, then `deductCredits(...)` after validation. Return 402 on insufficient credits.
3. **MODIFY `api/lib/content/getContentEstimateHandler.ts`** — add `credits_per_video` and `total_credits` to response.

---

## [2026-03-19] tasks — Inject CHARTMETRIC_REFRESH_TOKEN into sandbox env

**Prompt:** Give Recoup the ability to use a Chartmetric API key in a sandbox without exposing the key, so the agent can use the chartmetric skill via bash.
**Status:** completed
**Changes:**
- `tasks`: `src/sandboxes/getSandboxEnv.ts` — added optional `CHARTMETRIC_REFRESH_TOKEN` injection (same pattern as `GITHUB_TOKEN`; no-op if env var not set). `src/sandboxes/setupOpenClaw.ts` — injects `CHARTMETRIC_REFRESH_TOKEN` into `openclaw.json` env block so OpenClaw agent and all subprocesses get it.
**PRs:** Branch `feature/chartmetric-env-injection` pushed to `recoupable/tasks` — open PR at: https://github.com/recoupable/tasks/pull/new/feature/chartmetric-env-injection (target: `main`). `gh` not available in sandbox so PR not auto-created.
**Notes:** The chartmetric skill (`skills/chartmetric`) is already installed in sandboxes at `.recoup/skills/chartmetric`. Scripts read `CHARTMETRIC_REFRESH_TOKEN` from env. **Action required:** Add `CHARTMETRIC_REFRESH_TOKEN` to Trigger.dev environment secrets (same place as `RECOUP_API_KEY`, `GITHUB_TOKEN`). Once set, the agent can run `python .recoup/skills/chartmetric/scripts/search_artist.py "Drake"` without the token being user-visible.

---

## [2026-03-20] API — Chartmetric Proxy Endpoint (Option A for Credits)

**Prompt:** Implement Option A for credits — a proxy endpoint in `api` that authenticates callers, deducts 1 credit per call, exchanges the server-side refresh token for an access token, and forwards requests to Chartmetric.
**Status:** completed
**Changes:**
- `api`: New `lib/chartmetric/getChartmetricToken.ts` — exchanges `CHARTMETRIC_REFRESH_TOKEN` (server-side only) for a short-lived Chartmetric access token via `POST https://api.chartmetric.com/api/token`. New `lib/chartmetric/proxyChartmetricRequest.ts` — authenticates via `validateAuthContext`, deducts 1 credit, gets token, and forwards the request to Chartmetric. New `app/api/chartmetric/[...path]/route.ts` — exposes `GET` and `POST` handlers. New `lib/chartmetric/__tests__/proxyChartmetricRequest.test.ts` — 5 vitest tests (401, 402, 500, GET proxy, POST proxy), all green.
**PRs:** Branch `feature/chartmetric-proxy` pushed to `recoupable/api` — open PR at: https://github.com/recoupable/api/pull/new/feature/chartmetric-proxy (target: `test`). `gh` not available in sandbox.
**Notes:** `CHARTMETRIC_REFRESH_TOKEN` stays in the `api` service env only — never injected into sandboxes under this approach. Sandboxes call `POST /api/chartmetric/{path}` with their `RECOUP_API_KEY`. Each call costs 1 credit. The proxy preserves the original HTTP method, body, and query params.

---

## [2026-03-20] tasks — Switch CHARTMETRIC_REFRESH_TOKEN to CHARTMETRIC_BASE_URL

**Prompt:** Follow-up to Option A proxy: update tasks to inject proxy URL instead of refresh token.
**Status:** completed
**Changes:**
- `tasks`: `getSandboxEnv.ts` — replaced `CHARTMETRIC_REFRESH_TOKEN` injection with a hardcoded `CHARTMETRIC_BASE_URL=https://recoup-api.vercel.app/api/chartmetric`. `setupOpenClaw.ts` — removed `chartmetricRefreshToken` variable and its openclaw.json injection; replaced with always-on `CHARTMETRIC_BASE_URL` injection into openclaw.json env block.
**PRs:** Pushed to existing branch `agent/-u0ajm7x8fbr-how-can-we-give-r-1773964072471` on `recoupable/tasks` (target: `main`).
**Notes:** Sandboxes no longer need `CHARTMETRIC_REFRESH_TOKEN` in Trigger.dev secrets. The skill should read `CHARTMETRIC_BASE_URL` from env and call the proxy using `RECOUP_API_KEY` for auth. The proxy in `api` handles token exchange + credit deduction.

---
