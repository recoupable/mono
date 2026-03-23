# PROGRESS.md

> Last updated: 2026-03-23
> Purpose: Handoff notes for the next dev/agent picking up work.

---

## Current State of Each Submodule

### `tasks` (on `main`)
**Latest commits:**
- `feature/agent-day-task` PR #108 — agent-day Sunday task (open, awaiting merge)
- `5df28de` fix: update CODING_AGENT_ACCOUNT_ID to personal account (#105)
- `df2e32f` coding-agent task passes stdout to the git push step (#102)

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

### `cli` (on `feature/accounts-and-keys-commands`)
**Latest commits:**
- `8b090df` feat: add accounts and keys commands to CLI
- `a09929a` chore: bump version to 0.1.11
- `e4d4548` feat: add `recoup content` command suite (#13)

**Status:** PR open targeting `main`. 92 tests passing.

**What to know:** Added `recoup accounts create/upgrade` and `recoup keys list/create/delete`. Added `del()` to client.ts. Keys commands require the API PR (`feature/keys-api-key-auth`) to be merged first so x-api-key auth works on `/api/keys` endpoints.

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

## [2026-03-21] Artist Intel Pack — Industry-Grade Outputs for Artists & Labels

**Prompt:** How is this helpful to artists and labels? What would make it more valuable?
**Status:** completed
**Changes:**
- `api`: Upgraded `ArtistMarketingCopy` interface — added 5 new high-value industry outputs:
  - `artist_one_sheet` — industry-standard one-pager (bio, stats, comps, contact)
  - `ar_memo` — A&R discovery brief for label meetings (comps + momentum + recommendation)
  - `sync_brief` — sync licensing brief for music supervisors with specific placement use cases (TV/film/ads)
  - `spotify_playlist_targets` — 8–10 named Spotify editorial playlists to pitch (e.g., "New Music Friday", "Pollen", "bedroom pop") — not just "pitch to curators"
  - `brand_partnership_pitch` — 3–4 brand alignments with pitch angle and activation type
- `api`: `formatArtistIntelPackAsMarkdown.ts` — restructured report layout:
  - New `## Industry Pack` section leads (one-sheet, A&R memo, sync brief, playlist targets, brand pitch)
  - `## Outreach & Social` section now secondary (pitch email, press release, social captions)
  - `## Recent Web Context` renamed to `## Recent News & Press`
- `api`: Updated AI system prompt to "senior music industry executive" with A&R, sync, brand partnership, artist management framing
- `api`: Updated tests — `mockMarketingCopy` includes new fields, formatter tests cover new sections (21 format tests + 10 integration tests = 31 total, all green)
**PRs:** Pushed to existing branch `agent/-u0ajm7x8fbr-implement-the-wil-1774118338794` → PR #328 (target: `test`)
**Notes:** The key insight from the feedback: social media captions are the *least* industry-specific output. Real value for artists = one-sheet + sync brief + named playlist targets. Real value for labels = A&R memo with comps. Social captions remain but are deprioritized. The `spotify_playlist_targets` field is now a `string[]` of actual playlist names — much more actionable than a generic pitch paragraph.

---

## [2026-03-21] Artist Intel Pack — Feedback: "Just an Easy Prompt" → Real Data Intelligence

**Prompt:** Feedback: the current output is just an easy prompt. Make it more valuable by thinking deeply.
**Status:** completed
**Changes:**
- `api`: New `lib/spotify/getRelatedArtists.ts` — hits Spotify `/artists/{id}/related-artists` endpoint
- `api`: New `lib/artistIntel/getRelatedArtistsData.ts` — fetches top 5 related artists by follower count, computes follower/popularity percentile rankings vs the target artist, returns actual Spotify numbers for peer benchmarking
- `api`: New `lib/artistIntel/computeArtistOpportunityScores.ts` — four algorithmic scores (0–100) computed purely from real data (no AI):
  - **Sync Score**: BPM range, energy versatility, mood count, production quality, instrument richness
  - **Playlist Score**: danceability × energy × Spotify popularity
  - **A&R Score**: popularity-to-follower efficiency ratio (the classic "undervalued artist" signal), peer gap below median
  - **Brand Score**: lifestyle tag count, platform breadth, demographic specificity, marketing hook presence
- `api`: New `lib/artistIntel/analyzeCatalogDepth.ts` — analyses all 10 top tracks: avg popularity, std deviation, consistency score, top-track concentration %, catalog type classification (consistent / hit-driven / emerging)
- `api`: Updated `generateArtistIntelPack.ts` — three parallel fetches (MusicFlamingo + Perplexity + Related Artists); opportunity scores and catalog depth computed synchronously from fetched data; all 5 data sources fed into AI synthesis
- `api`: Updated `buildArtistMarketingCopy.ts` — AI prompt now receives real peer follower counts and percentile rankings so "comparable artist" references cite actual data, not hallucinations; prompt instructs AI to use specific scores in each output section
- `api`: Updated `formatArtistIntelPackAsMarkdown.ts` — 3 new report sections:
  - `## Opportunity Scores` — table with ASCII bar charts (█░) and emoji rating per domain
  - `## Peer Benchmarking` — table showing target artist vs 5 real peers with gap column (±K)
  - `## Catalog Analysis` — table + per-track popularity bars + catalog type callout
**PRs:** Pushed to `agent/-u0ajm7x8fbr-implement-the-wil-1774118338794` → PR #328 (target: `test`)
**Notes:** Core insight: the value of the pack was almost entirely from AI text generation (easy to replicate, possible to hallucinate). Now the majority of value comes from real data: actual peer follower counts, algorithmically derived scores from MusicFlamingo audio data, and catalog consistency math from Spotify track popularity numbers. The AI copy is still valuable but is now grounded in real benchmarks.

---

## [2026-03-23] Admin + Docs + API — Coding Agent Slack Tags Analytics Page

**Prompt:** Create an admin page to view analytics for Slack tags of the Recoup Coding Agent — show total count, a chart of tags over time, and a table of who tagged the agent, the prompt, and the timestamp.
**Status:** completed
**Changes:**
- `docs`: Added `GET /api/admins/coding-agent/slack-tags` to `openapi.json` (full response schema with `status`, `total`, `tags[]`). New `api-reference/admins/coding-agent-slack-tags.mdx`. Updated `docs.json` nav (Admins group).
- `api`: New `lib/admins/coding-agent/fetchSlackMentions.ts` — calls Slack Web API directly (`auth.test` → `conversations.list` → `conversations.history`) using `SLACK_BOT_TOKEN` as source of truth. Filters messages containing `<@BOT_USER_ID>`, strips mention from prompt, resolves user display names + avatars via `users.info` (cached). Supports period filtering (all/daily/weekly/monthly). New `validateGetSlackTagsQuery.ts`, `getSlackTagsHandler.ts`, `app/api/admins/coding-agent/slack-tags/route.ts`. 11 unit tests, all passing.
- `admin`: New `types/coding-agent.ts`, `lib/recoup/fetchSlackTags.ts`, `hooks/useSlackTags.ts`, `lib/coding-agent/getTagsByDate.ts`. New `/coding-agent` page with period selector, total count, line chart (tags per day), and sortable table (Tagged By with avatar, Prompt, Channel, Timestamp). Added "Coding Agent Tags" nav button to `AdminDashboard`.
**PRs:** Branches pushed — PRs need to be opened via GitHub:
- docs: `feature/coding-agent-slack-tags` → main: https://github.com/recoupable/docs/pull/new/feature/coding-agent-slack-tags
- api: `feature/coding-agent-slack-tags` → test: https://github.com/recoupable/api/pull/new/feature/coding-agent-slack-tags
- admin: `feature/coding-agent-slack-tags` → main: https://github.com/recoupable/admin/pull/new/feature/coding-agent-slack-tags
**Notes:** The Slack API approach paginate all channels the bot is in and scans message history. For large workspaces with many channels and messages this may be slow — consider caching or storing mentions in Supabase on `onNewMention` if latency becomes an issue. `SLACK_BOT_TOKEN` must have `channels:history`, `groups:history`, `conversations:history`, and `users:read` OAuth scopes.

---

## [2026-03-23] Agent Day Task — Autonomous Sunday Feature Implementation

**Prompt:** Create a new Trigger.dev task (`agent-day`) that runs only on Sundays and implements a new feature end-to-end: searches recent commits, plans a feature, implements it, reviews the PR (checks + feedback + Vercel preview), merges it, and posts to Slack.
**Status:** completed
**Changes:**
- `tasks`: New `src/tasks/agentDayTask.ts` — `schedules.task` with cron `0 10 * * 0` (10 AM ET Sundays), 2h maxDuration. Flow: fetch commits → generate feature prompt via Claude → trigger `coding-agent` → wait for CI checks → assess PR feedback with Claude → apply fixes via `update-pr` → test Vercel preview → squash-merge → post to Slack `#C08HN8RKJHZ`.
- `tasks`: New GitHub utilities: `fetchRecentSubmoduleCommits`, `waitForPRChecks`, `fetchPRReviews`, `mergePR`, `getVercelPreviewUrl`.
- `tasks`: New `src/slack/postToSlackChannel.ts` — posts to any Slack channel via `SLACK_BOT_TOKEN`.
- `tasks`: New AI utilities: `generateFeaturePrompt` and `assessPRFeedback` — both call Anthropic API directly via `fetch` with `ANTHROPIC_API_KEY`. Both fall back gracefully if the key is missing.
- `tasks`: `codingAgentSchema` and `updatePRSchema` — made `callbackThreadId` optional (backward compatible). Both tasks skip the Slack callback when `callbackThreadId` is absent (used when triggered programmatically by `agent-day`).
- `tasks`: 19 new files, 186/186 tests passing.
**PRs:** https://github.com/recoupable/tasks/pull/108 (target: `main`)
**Notes:** Requires `ANTHROPIC_API_KEY` and `GITHUB_TOKEN` env vars in the Trigger.dev deployment for the AI planning and GitHub merge steps. Falls back gracefully when `ANTHROPIC_API_KEY` is missing (uses a canned improvement prompt). Vercel preview testing only runs for `recoupable/api` and `recoupable/chat` repos.

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

## [2026-03-21] CLI — accounts and keys commands

**Prompt:** Add the ability for users to create an account, upgrade to pro, and create and delete their API keys via the CLI.
**Status:** completed
**Changes:**
- `cli`: New `src/commands/accounts.ts` — `recoup accounts create --email/--wallet` (POST /api/accounts, no auth required) and `recoup accounts upgrade` (prints https://chat.recoupable.com/settings). New `src/commands/keys.ts` — `recoup keys list` (GET /api/keys), `recoup keys create --name` (POST /api/keys), `recoup keys delete --id` (DELETE /api/keys). Added `del()` to `src/client.ts`. Commands registered in `src/bin.ts`. 18 new tests; 92 total passing.
- `api`: Updated `lib/keys/getApiKeysHandler.ts`, `createApiKeyHandler.ts`, `deleteApiKeyHandler.ts` to use `validateAuthContext` instead of `getAuthenticatedAccountId` so CLI users with `RECOUP_API_KEY` (x-api-key header) can manage keys.
**PRs:** Branches pushed — PRs need to be opened via GitHub (gh not available in sandbox):
- cli: `feature/accounts-and-keys-commands` → main: https://github.com/recoupable/cli/pull/new/feature/accounts-and-keys-commands
- api: `feature/keys-api-key-auth` → test: https://github.com/recoupable/api/pull/new/feature/keys-api-key-auth
**Notes:** Merge the `api` PR first (so x-api-key works on /api/keys), then the `cli` PR. `accounts upgrade` has no backend — it just prints the upgrade URL since no Stripe/subscription endpoint exists. `POST /api/accounts` returns `{ data: { account_id, email, ... } }` (nested shape — legacy behavior from existing handler).

---

## [2026-03-21] Artist Intelligence Pack — Spotify + MusicFlamingo AI + Perplexity → Marketing Copy

**Prompt:** Implement the wildest, most WOW demoable feature using underutilized API keys and services.
**Status:** completed
**Changes:**
- `api`: New domain `lib/artistIntel/` (7 files + 1 test file):
  - `generateArtistIntelPack.ts` — main orchestrator; fetches Spotify → runs MusicFlamingo + Perplexity in parallel → AI synthesis
  - `getArtistSpotifyData.ts` — artist profile + top tracks with 30-second Spotify preview URLs (public MP3s, no auth needed)
  - `getArtistMusicAnalysis.ts` — runs 4 MusicFlamingo NVIDIA 8B presets in parallel on the Spotify preview: `catalog_metadata` (BPM/key/genre/mood/instruments), `audience_profile` (demographics), `playlist_pitch` (target playlists), `mood_tags` (vibe tags)
  - `getArtistWebContext.ts` — Perplexity search for recent press, streaming news, trends
  - `buildArtistMarketingCopy.ts` — AI synthesizes all data into: playlist pitch email, Instagram/TikTok/Twitter captions, press release opener, key talking points
  - `validateArtistIntelBody.ts` — Zod validation (artist_name required)
  - `generateArtistIntelPackHandler.ts` — route handler with `validateAuthContext`
- `api`: New endpoint `POST /api/artists/intel` — takes `{ artist_name }`, returns complete intelligence pack
- `api`: New MCP tool `generate_artist_intel_pack` in `lib/mcp/tools/artistIntel/` — registered in `lib/mcp/tools/index.ts`, available in the AI agent chat UI
- 10 unit tests, all green. All 218 test files passing (1514 tests). No lint errors on new files.
**PRs:**
- api: `agent/-u0ajm7x8fbr-implement-the-wil-1774118338794` → test: https://github.com/recoupable/api/pull/328
**Notes:**
- **Why this is WOW:** Type an artist name → in ~30 seconds get a complete professional marketing package powered by NVIDIA AI audio analysis. Artists can use this immediately for playlist pitching, PR outreach, and social campaigns.
- **Key insight:** Spotify `preview_url` on tracks is a public 30-second MP3 clip — MusicFlamingo accepts any audio URL, so we can analyze ANY artist's music without auth or file uploads.
- **MusicFlamingo endpoint:** `https://sidney-78147--music-flamingo-musicflamingo-generate.modal.run` (Modal serverless, already live).
- **Demo flow:** In the chat UI, ask the agent: "Generate an artist intelligence pack for [artist name]" — `generate_artist_intel_pack` MCP tool fires automatically and returns the full pack.
- **Parallel processing:** Spotify first (required for preview URL), then MusicFlamingo + Perplexity fire simultaneously, then AI synthesis. Graceful degradation if any source fails.

---

## [2026-03-21] Artist Intel Pack — Output Design Improvements

**Prompt:** What would make this feature better? What is the output results and design?
**Status:** completed
**Changes:**
- `api`: Typed `ArtistMusicAnalysis` fields — replaced `unknown` with `CatalogMetadata`, `AudienceProfile`, `MoodTagsResult`, and `string` for playlist_pitch (`lib/artistIntel/getArtistMusicAnalysis.ts`).
- `api`: Upgraded `getArtistWebContext` from Perplexity search snippets joined with ` | ` to `chatWithPerplexity` (sonar-pro) — returns a researched narrative summary with citations.
- `api`: New `lib/artistIntel/formatArtistIntelPackAsMarkdown.ts` — formats the full pack as a structured markdown report with sections: Artist Profile, Music DNA (MusicFlamingo AI), Recent Web Context, Marketing Pack (pitch email, social captions, press release, talking points).
- `api`: `ArtistIntelPack` now includes `formatted_report: string` — the pre-formatted markdown is included in the REST API response.
- `api`: `generate_artist_intel_pack` MCP tool now returns `formatted_report` directly (via `getCallToolResult`) instead of raw JSON, so the chat AI renders beautiful formatted output without needing to reformat the data.
- `api`: 15 new formatter tests; 1529 total passing. All lint-clean on new files.
**PRs:** Pushed to existing branch `agent/-u0ajm7x8fbr-implement-the-wil-1774118338794` → PR #328 (target: `test`)
**Notes:** The MCP tool output design change is the biggest UX win — chat now shows a nicely formatted intelligence report instead of a raw JSON blob. The `formatted_report` field in the API response lets any REST consumer also display the pre-formatted version. `ArtistWebContext.results` (array of search results) was removed; it is now just `{ summary, citations }` — update any consumers that depended on `.results`.

---

## [2026-03-21] Tasks Popup — Show Last Runs and Upcoming Runs

**Prompt:** Task detail popup on /tasks page should show last runs and upcoming scheduled runs from the API (recent_runs / upcoming fields).
**Status:** completed
**Changes:**
- `chat`: Extended `Task` type in `lib/tasks/getTasks.ts` to include `recent_runs?: TaskRunItem[]` and `upcoming?: string[]` (fields already returned by the API). Updated `useScheduledActions`, `TasksList`, `TaskDetailsDialog`, `TaskDetailsDialogContent` to use `Task` instead of `Tables<"scheduled_actions">`. Created `TaskRecentRunsSection.tsx` (shows last N runs with status badge, timestamp, duration) and `TaskUpcomingRunsSection.tsx` (shows next run datetimes). Both sections are hidden when data is absent.
**PRs:** https://github.com/recoupable/chat/pull/1593
**Notes:** The API already returns `recent_runs` and `upcoming` in the tasks array. The `Task` type extends the DB row type so all existing components remain compatible.

---

## [2026-03-21] Chat - last and next runs in task popup
**Prompt:** Show last / upcoming runs when clicking a scheduled task on /tasks page
**Status:** completed
**Changes:**
- chat: Added `TaskRecentRunsSection` and `TaskUpcomingRunsSection` components; extended `Task` type to include `recent_runs` and `upcoming`; surfaced these fields in `TaskDetailsDialogContent`
**PRs:** https://github.com/recoupable/chat/pull/1593
**Notes:** API already returns `recent_runs` and `upcoming` — only UI changes needed. Both sections hidden when empty.

---

## [2026-03-21] Artist Intel Pack — Gatsby Grace test + pre-market A&R fix

**Prompt:** Test it with artist Gatsby-Grace and show me results
**Status:** completed
**Changes:**
- `api`: Fixed A&R rationale bug in `computeArtistOpportunityScores.ts` — artists with <1000 followers AND <10 popularity (e.g. Gatsby Grace: 2 followers, 0 popularity) were incorrectly labeled "established/saturated". They now get the "Pre-market artist — highest early-discovery upside" rationale with a +10 discovery bonus (arScore goes from 40 → 50 for pre-market acts).
- `api`: Added `lib/artistIntel/__tests__/computeArtistOpportunityScores.test.ts` — 6 tests covering pre-market detection, high-follower/low-popularity distinction, music analysis paths, and weighted overall score.
- `api`: Added 8 Gatsby Grace integration tests to `generateArtistIntelPack.test.ts` using real Spotify data (ID: `7ljukJB2Ctl0T4vCoYfb2x`, 2 followers, 0 popularity, no genres). Mocks now include `getRelatedArtistsData`.
- `api`: Fixed `formatArtistIntelPackAsMarkdown.test.ts` — `basePack` mock was missing `peer_benchmark`, `opportunity_scores`, `catalog_depth` fields added in earlier iterations; all 21 tests now pass.
- Total: 45 artistIntel tests passing (was 31).
**PRs:** Pushed to `agent/-u0ajm7x8fbr-implement-the-wil-1774118338794` → PR #328 (target: `test`)
**Notes:**
- **Gatsby Grace real Spotify data:** Spotify ID `7ljukJB2Ctl0T4vCoYfb2x`, name "Gatsby Grace", 2 followers, 0 popularity, no genres, top tracks "Stay" and "Running" (both 0 popularity, no preview URLs). This is a genuinely pre-market artist.
- **Expected Intel Pack output for Gatsby Grace:** Sync 30/100 (weak), Playlist 35/100 (weak), A&R 50/100 (moderate — pre-market bonus), Brand 35/100 (weak), Overall 37/100. Catalog type: Emerging. No music DNA (no preview URL). No peer benchmark (no Spotify related artists). AI copy focuses on early-discovery angle.
- **Test could not run live** because preview deployment (`recoup-api-git-agent-u0ajm7x8fbr-imp-a4ba93-recoupable-ad724970.vercel.app`) returns 401 for the sandbox's RECOUP_API_KEY — the preview environment likely uses a different PRIVY_PROJECT_SECRET hash than production. Production API (`recoup-api.vercel.app`) doesn't have this endpoint yet (unreleased branch).

---

## [2026-03-23] Coding Agent Slack Tags Analytics — Admin + API + Docs

**Prompt:** @U0AJM7X8FBR Admin + Docs + API - we want a new admin page to view analytics for the coding-agent task triggered by slack tags. The first analytic which should be focused on is the number of times "Recoup Coding Agent" is tagged on slack. Shows both a graph and a table of who tagged the agent, what the prompt was, and the timestamp.
**Status:** completed
**Changes:**
- docs: Added `GET /api/admins/coding-agent/slack-tags` to `openapi.json`; new `api-reference/admins/coding-agent-slack-tags.mdx` page; updated `docs.json` navigation
- api: `lib/admins/coding-agent/fetchSlackMentions.ts` — pulls from Slack API (auth.test → conversations.list → conversations.history → users.info); `validateGetSlackTagsQuery.ts`, `getSlackTagsHandler.ts`, `route.ts`; 11 tests passing
- admin: New `/coding-agent` page with period selector, total tag count, line chart of tags per day, sortable table (Tagged By with avatar, Prompt, Channel, Timestamp); "Coding Agent Tags" button on Admin Dashboard
**PRs:** pending (see PR_CREATED lines in agent output)
**Notes:** Ensure `SLACK_BOT_TOKEN` has `channels:history`, `groups:history`, `conversations:history`, and `users:read` OAuth scopes.

---

## [2026-03-23] Admin + Docs + API — Coding Agent Pull Request Tracking

**Prompt:** Update the /coding admin page to show pull requests opened by the coding agent. For each Slack tag (prompt), show which PRs were opened, which codebase, and the original prompt. Add a PR line to the chart and a PR column to the table.
**Status:** completed
**Changes:**
- `api`: Updated `lib/admins/slack/fetchSlackMentions.ts` — added `pull_requests: string[]` to `SlackTag` interface. For each mention, fetches thread replies via `conversations.replies` Slack API and extracts GitHub PR URLs from bot responses using regex (`https://github.com/.../pull/\d+`). Updated `__tests__/getSlackTagsHandler.test.ts` mock data to include `pull_requests`.
- `docs`: Added `pull_requests` array field to `GET /api/admins/coding/slack` response schema in `openapi.json`.
- `admin`: Added `pull_requests: string[]` to `SlackTag` type. Updated `getTagsByDate` to return `pull_request_count` per date alongside `count`. Updated `AdminLineChart` to support optional `secondLine` prop (renders second recharts Line with legend). Added "Pull Requests" column to `SlackTagsColumns` (clickable #N links). Updated `CodingAgentSlackTagsPage` to render Tags vs PRs dual-line chart and updated loading skeleton.
**PRs:** Branches pushed to `feature/coding-agent-pr-tracking` — PRs need to be opened via GitHub:
- api: `feature/coding-agent-pr-tracking` → `test`: https://github.com/recoupable/api/pull/new/feature/coding-agent-pr-tracking
- admin: `feature/coding-agent-pr-tracking` → `main`: https://github.com/recoupable/admin/pull/new/feature/coding-agent-pr-tracking
- docs: `feature/coding-agent-pr-tracking` → `main`: https://github.com/recoupable/docs/pull/new/feature/coding-agent-pr-tracking
**Notes:** PR URLs are extracted from Slack bot reply text using the pattern `https://github.com/[owner]/[repo]/pull/[number]`. Slack wraps URLs in `<URL>` or `<URL|label>` format — the regex handles this because `>` is excluded from the match. The `AdminLineChart` now supports an optional `secondLine` prop; the `PrivyLoginsPage` that also uses `AdminLineChart` is unaffected (backward compatible).
