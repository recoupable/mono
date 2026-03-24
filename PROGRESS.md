# PROGRESS.md

> Last updated: 2026-03-24
> Purpose: Handoff notes for the next dev/agent picking up work.

---

## [2026-03-24] Connect Code Reviewer and Sr Dev review loop (REC-9)
**Prompt:** Set up automated review loop between Sr Dev and Code Reviewer agents
**Status:** completed
**Changes:**
- agents/code-reviewer/AGENTS.md: Added "Review Loop with Sr Dev" section — when @-mentioned by Sr Dev, review the PR; if changes needed, @-mention Sr Dev back; if approved, @-mention Sr Dev and close
- agents/sr-dev/AGENTS.md: Added "Review Loop with Code Reviewer" section — after creating/updating a PR, @-mention Code Reviewer; when feedback arrives, fix and @-mention again; loop until approved
**PRs:** none (local instruction changes)
**Notes:** Both agents now have symmetric handoff instructions. The loop uses Paperclip @-mentions to trigger heartbeats. Sr Dev starts the cycle by @-mentioning Code Reviewer after pushing a PR. Code Reviewer closes the cycle by @-mentioning Sr Dev with approval/feedback.

---

## [2026-03-24] API — fix PR #341 review feedback (REC-7)
**Prompt:** Fix code review feedback on content-agent PR #341
**Status:** completed
**Changes:**
- api: Created clean branch `fix/content-agent-clean` from `test` with only 17 new feature files (removed ~90 JSDoc-only changes)
- api: Renamed `handlers/handleContentAgentCallback.ts` → `registerOnSubscribedMessage.ts` (naming collision fix)
- api: Added `crypto.timingSafeEqual` for callback secret comparison in `handleContentAgentCallback.ts`
- api: Fixed all JSDoc lint errors in new feature files
**PRs:** https://github.com/recoupable/api/pull/342 (supersedes #341)
**Notes:** Old PR #341 had 106 files changed (90 unrelated JSDoc noise). New PR #342 has only 17 files. Posted update to Slack thread and commented on #341. Task reassigned to board for review.

---

## [2026-03-24] API — review PR #341 (REC-7)
**Prompt:** Review PR https://github.com/recoupable/api/pull/341 and provide feedback
**Status:** completed
**Changes:**
- none (review only)
**PRs:** https://github.com/recoupable/api/pull/341 (reviewed, request changes)
**Notes:** PR adds Recoup Content Agent Slack bot + `/api/launch` endpoint. Verdict: request changes. Blocking issue: ~90 unrelated JSDoc-only changes inflate PR from ~16 new feature files to 106. Feature code itself is clean. Also flagged naming collision between two `handleContentAgentCallback` files and suggested `crypto.timingSafeEqual` for callback secret. Review comment: https://github.com/recoupable/api/pull/341#issuecomment-4121681007

---

## [2026-03-24] Docs — fix PR #78 feedback (REC-6)
**Prompt:** Fix feedback comments on docs PR #78 and update Slack thread
**Status:** completed
**Changes:**
- docs: Linked `POST /api/content-agent/callback` to its API reference page in data flow and endpoints table
- docs: Added missing `RECOUP_API_KEY` to environment variables table
**PRs:** https://github.com/recoupable/docs/pull/78 (updated, commit `2149b60`)
**Notes:** Posted summary to #code-review Slack thread. PR still open for review.

---

## [2026-03-24] Code Reviewer agent created (REC-4)
**Prompt:** Create a new agent to review unmerged PRs in Recoup mono repo submodules
**Status:** completed
**Changes:**
- Paperclip: Created "Code Reviewer" agent (QA role, claude-sonnet-4-6, reports to CTO)
- Agent ID: 8dec924a-7c20-4280-985d-f3ea996e0c4e (urlKey: code-reviewer-2)
- Approval: d2fbd753 (approved after revision to add CLEAN code principles)
- mono: Created `agents/code-reviewer/AGENTS.md` with review instructions (SRP, OCP, DRY, YAGNI, security checklist)
- Set instructions path via API
**PRs:** none (instructions file created locally, not yet committed)
**Notes:** Agent is idle and ready for tasks. First revision was requested by board to emphasize CLEAN coding principles — incorporated into capabilities and instructions. Old agent 815e3d4f (Code Reviewer 1) was from the rejected first hire attempt.

---

## [2026-03-24] Recoup Content Agent scaffold
**Prompt:** Scaffold the content-agent Slack bot following the coding-agent pattern
**Status:** completed
**Changes:**
- api: Added `content-agent` Slack bot (routes, handlers, bot singleton, callback) on `feature/content-agent` branch
- tasks: Added `poll-content-run` Trigger.dev task on `feature/content-agent` branch
**PRs:** Branches pushed — PRs need to be created manually (api → test, tasks → main)
**Notes:** New env vars needed: `SLACK_CONTENT_BOT_TOKEN`, `SLACK_CONTENT_SIGNING_SECRET`, `CONTENT_AGENT_CALLBACK_SECRET`. Also needs `RECOUP_API_BASE_URL` in tasks env. Slack App must be created with `app_mentions:read` + `chat:write` scopes.

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

### `docs` (on `main`, feature branch `feat/mcp-docs-full-tool-list` open)
**Latest commits:**
- `05c455c` docs: improve user journey — navigation, quickstart, MCP client configs
- `e083670` docs: expand MCP page with full tool list and docs search MCP explanation
- `fd82b14` feat: add authentication page (#62)

**Status:** Feature branch `feat/mcp-docs-full-tool-list` pushed, PR needs to be opened against `main`.

**What changed (2026-03-24 user journey improvements):**
- Navigation order fixed: Authentication now comes before MCP in sidebar
- Homepage (`index.mdx`): integration path cards (REST/MCP/CLI), clearer "what you can build" framing
- Quickstart (`quickstart.mdx`): new first example uses Spotify search (works immediately, no existing data needed); Tasks list removed as first example
- MCP page (`mcp.mdx`): ready-to-paste config snippets for Claude Desktop, Cursor, and VS Code added before TypeScript SDK
- API reference intro (`api-reference/introduction.mdx`): stripped duplicate auth/base URL content, now links to auth guide

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

## [2026-03-24] Docs — MCP Page Rewrite (Full Tool List + Docs Search MCP)

**Prompt:** Document both MCP servers in docs: (1) the Mintlify docs search MCP and (2) the Recoup API MCP with a full list of all tools.
**Status:** completed
**Changes:**
- `docs`: Rewrote `mcp.mdx` — now explains both servers (Mintlify docs search MCP via contextual menu, and the Recoup API MCP at `https://recoup-api.vercel.app/mcp`). Documents all 44 tools grouped by category (Artists, Chats, Tasks, Pulses, Catalogs, Spotify, YouTube, Search, Images, Video, Audio, Files, Communication, Segments, Sandboxes, Utilities). Removed outdated `run_sandbox_command` entry (tool doesn't exist). Added connection snippet and two call examples.
**PRs:** Branch `feat/mcp-docs-full-tool-list` pushed — open PR via: https://github.com/recoupable/docs/pull/new/feat/mcp-docs-full-tool-list
**Notes:** Tool list was derived from all `register*Tool.ts` files in `api/lib/mcp/tools/`. The `run_sandbox_command` in the old mcp.mdx was stale — no such tool is registered. If new tools are added to the API, update this page.

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

## [2026-03-24] Docs User Journey Improvements

**Prompt:** Review docs from a user journey perspective — are they clear for Humans and Agents?
**Status:** completed
**Changes:**
- `docs`: Navigation order fixed — authentication before MCP in sidebar
- `docs`: Homepage (`index.mdx`) — integration path cards (REST API / MCP / CLI), clearer "what you can build" framing for humans and agents
- `docs`: Quickstart (`quickstart.mdx`) — first example now uses Spotify search (no existing data needed, works immediately); removed Tasks list as first example; added MCP in next steps
- `docs`: MCP page (`mcp.mdx`) — added copy-paste config snippets for Claude Desktop, Cursor, and VS Code before the TypeScript SDK; moved tool reference after connection guides
- `docs`: API reference intro (`api-reference/introduction.mdx`) — removed duplicate auth/base URL content; now a clean page linking to auth guide
**PRs:** Branch `feat/mcp-docs-full-tool-list` pushed to `recoupable/docs`. PR needs to be opened against `main`.
**Notes:** `gh` CLI not available in this sandbox — PR must be created manually or via the next agent run that has GitHub access.

---

## [2026-03-24] Composio connectors expansion
**Status:** completed
**Changes:**
- api: Expanded SUPPORTED_TOOLKITS from 4 to 12 connectors (added Gmail, Google Calendar, Spotify, Instagram, Twitter/X, YouTube, Slack, LinkedIn)
- api: Expanded ALLOWED_ARTIST_CONNECTORS to include spotify, instagram, twitter, youtube (in addition to tiktok)
- api: Updated CONNECTOR_DISPLAY_NAMES with 8 new entries
- api: Updated 3 test files — all 13 tests pass
**PRs:** https://github.com/recoupable/api/pull/337
**Notes:** PR targets `test` branch. Changes are in feature/composio-more-connectors branch.

---

## [2026-03-24] Coding agent tag-based filtering
**Prompt:** Add tag filter chips to admin coding page with new API endpoint for filter options
**Status:** completed
**Changes:**
- `api`: Added optional `tag` query param to `GET /api/admins/coding/slack` (filters by user_id); created new `GET /api/admins/coding-agent/slack-tags` endpoint returning distinct Slack users; added 5 passing tests
- `admin`: Added `SlackTagOption`/`SlackTagOptionsResponse` types; created `fetchSlackTagOptions` and `useSlackTagOptions`; updated `useSlackTags` to accept optional `tag` param; updated `CodingAgentSlackTagsPage` with clickable filter chips, toggle, and clear-filter UX
**PRs:**
- api: https://github.com/recoupable/api/pull/338 (base: test)
- admin: https://github.com/recoupable/admin/pull/23 (base: main)
**Notes:** Admin lint was non-functional due to pre-existing monorepo root eslint.config.js missing `@eslint/js` package — unrelated to this task. API lint errors in my new files match the same pattern as existing route files (pre-existing jsdoc rules). All new tests pass.

---

## [2026-03-24] Hire Sr Dev agent (REC-8)
**Prompt:** Create a new Sr Dev agent that handles coding tasks delegated by the CTO, working closely with the Code Reviewer agent
**Status:** completed
**Changes:**
- `mono/agents/sr-dev/AGENTS.md`: Created instructions file for the Sr Dev agent covering code standards, git workflow, build commands, and Code Reviewer integration
**PRs:** none
**Notes:** Hire approved by board. Sr Dev agent (81d2b822-486a-4d29-8d43-87d83d740239) is active and idle. Workflow: CTO delegates coding tasks → Sr Dev implements → Code Reviewer reviews → feedback tasks routed back to Sr Dev.

---
