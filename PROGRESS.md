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

## [2026-03-18] Admin — Hide Sensitive Info Toggle

**Prompt:** Add a HideProvider wrapping the admin app with a toggle in the top-right of the global layout to hide/show all email fields.
**Status:** completed
**Changes:**
- `admin`: New `providers/HideProvider.tsx` — React context with `isHidden: boolean` + `toggle()`. New `hooks/useHide` pattern exported from the provider. New `lib/maskEmail.ts` — masks emails to `jo***@ex***.com`. New `components/HideToggle.tsx` — fixed top-right Eye/EyeOff button reading from `useHide()`. `providers/Providers.tsx` — wraps children in `<HideProvider>` + renders `<HideToggle />`. `components/PrivyLogins/privyLoginsColumns.tsx`, `components/Sandboxes/sandboxesColumns.tsx`, `components/SandboxOrgs/AccountReposList.tsx` — all email cells now use `useHide()` + `maskEmail()`.
**PRs:** `feature/hide-sensitive-info-toggle` → main: https://github.com/recoupable/admin/pull/new/feature/hide-sensitive-info-toggle
**Notes:** Toggle is global — one click hides all emails across all pages simultaneously. `maskEmail` shows first 2 chars of local part + `***`, and first 2 chars of domain + `***` (e.g. `john@example.com` → `jo***@ex***.com`).

---

## [2026-03-18] Chat — Remove Org API Keys from /keys Page

**Prompt:** On /keys, selecting an org showed org API keys instead of personal keys. Always show personal API keys regardless of selected org (removing org API key concept).
**Status:** completed
**Changes:**
- `chat`: `hooks/useApiKey.ts` — removed `selectedOrgId` from query key and all function calls. `lib/keys/fetchApiKeys.ts` — removed `organizationId` parameter. `lib/keys/createApiKey.ts` — removed `organizationId` parameter.
**PRs:** `feature/keys-always-personal` pushed to `recoupable/chat` — open PR at: https://github.com/recoupable/chat/pull/new/feature/keys-always-personal (target: `test`)
**Notes:** The API backend (`api/lib/keys/org/`) still has org key handlers but they are no longer called from the frontend. Those can be cleaned up in a future task if desired.

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
