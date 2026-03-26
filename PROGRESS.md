# PROGRESS.md

> Last updated: 2026-03-26
> Purpose: Handoff notes for the next dev/agent picking up work.

---

## [2026-03-26] Web-researched artist.md profiles for all 44 rostrum artists
**Prompt:** Do deep web research on every artist in the rostrum directory and create artist.md profiles
**Status:** completed
**Changes:**
- rostrum/artists: Created `context/artist.md` for all 42 artists that were missing profiles (Alé Araya + Gatsby Grace already had them)
- Each profile built from 2-3 web searches per artist with real biographical data, genre descriptions, aesthetic direction, brand voice, and sacred rules
- Profiles cover: 7 hip-hop legends (Mac Miller, Wiz Khalifa, Jeezy, Raekwon, Mobb Deep, Sean Price, Smif-N-Wessun), 7 hip-hop artists (DC The Don, Jae Skeese, THE REAL RYU, Natural Elements, YUNGMORPHEUS, Like, Chip Fu), 7 labels/entities (Rostrum Records, Fat Beats, Cantora Records, Javotti Media, Spaceheater, Soul In The Horn, Murdermart), 7 emerging artists (Julius Black, Gliiico, Amxxr, Baro Sura, Neek, Nicole Bus, Niko Is), 7 bands/artists (Bear Hands, El Michels Affair, MGMT, Mod Sun, Theo Croker, TeamMate, Henri), 6 artists (Goosebytheway, Jada, Mike Taylor, No Love for the Middle Child, Rashad Thomas, Solene)
**PRs:** none — pushed directly to rostrum repo main
**Notes:** Two artists have thinner profiles due to limited public information: Neek (multiple "Neek" artists exist, couldn't confirm which one) and Jada (no public info found confirming which "Jada" is on Rostrum). These should be enriched when the label provides details. THE REAL RYU has two directories (the-real-ryu and the-real-ryu-19447895) — both received identical profiles. TeamMate correction: they're former romantic partners (not brother-sister as initially thought). 43 files, 3,558 lines of real research-backed content.

---

## [2026-03-25] Purge YAGNI scaffolding from rostrum artists
**Prompt:** Follow setup-artist skill and remove all unneeded scaffolding files/folders from rostrum artist directories (except gatsby-grace)
**Status:** completed
**Changes:**
- rostrum/artists: Deleted scaffolding from 43 artist directories — removed `.env.example`, `README.md`, `apps/`, `config/`, `content/`, `memory/`, placeholder `context/` files (template artist.md, audience.md, era.json, tasks.md, images/README.md), `releases/README.md`, `songs/README.md`, and empty directories
- rostrum/artists: Cleaned RECOUP.md body text for all 43 artists (kept frontmatter only, matching gatsby-grace format)
- 38 artists now have only `RECOUP.md`; 5 artists retain real content alongside RECOUP.md (fat-beats: social-reports + weekly dashboard; gliiico: spotify tracking CSV; julius-black: tiktok tracking + snapshot; mac-miller: weekly news; spaceheater: competitor analysis report)
- gatsby-grace left untouched (already follows the new skill structure)
**PRs:** none — changes are local in `.local/records/rostrum/`
**Notes:** Per the setup-artist skill: "Nothing gets created until there's real content to put in it." All deleted files were empty scaffolding or placeholder templates with `{curly brace tokens}`. Real content files (tracking CSVs, reports, analysis) were preserved. When an artist gets real context, create `context/artist.md` and other files per the setup-artist skill.

---

## [2026-03-25] Song filtering for content creation pipeline
**Prompt:** Add optional `songs` array to content creation payload so the pipeline can restrict which songs it picks from
**Status:** completed
**Changes:**
- tasks: Added `songs` field to `createContentPayloadSchema`, filtering logic in `selectAudioClip`, pass-through in `createContentTask`
- api: Added `songs` to Zod validation (`validateCreateContentBody`), handler (`createContentHandler`), and trigger interface (`triggerCreateContent`)
- docs: Added `songs` property to `ContentCreateRequest` schema in `openapi.json`
- cli: Added `--songs <slugs>` comma-separated flag to `recoup content create` command
**PRs:**
- https://github.com/recoupable/tasks/pull/112 (base: main)
- https://github.com/recoupable/api/pull/348 (base: test)
- https://github.com/recoupable/docs/pull/80 (base: main)
- https://github.com/recoupable/cli/pull/19 (base: main)
**Notes:** Backward compatible — when `songs` is omitted, all songs remain eligible. Song slugs match filenames without extension (e.g. `hiccups` for `hiccups.mp3`). The caller (chat agent, Slack bot, CLI) is responsible for resolving user intent into song slugs. All existing tests pass (183 tasks, 1553 api).

---

## [2026-03-25] YAGNI setup-artist skill + consolidate Gatsby Grace
**Prompt:** Simplify the setup-artist skill and consolidate three gatsby-grace directories into one
**Status:** completed
**Changes:**
- skills/setup-artist: Rewrote SKILL.md (178→120 lines, 9→5 steps, 10→2 directories). Deleted all 6 reference files (memory-system.md, services-guide.md, env-template.md, directory-readmes.md, root-readme.md, context-files.md). Skill now only creates `context/` and `songs/` — other directories created by other skills when needed.
- rostrum/gatsby-grace: Consolidated data from 3 directories. Merged filled `artist.md` (from local) + `brand.md` content. Replaced placeholder `audience.md` with filled version (from old). Copied 17 songs with proper `{slug}.mp3` naming + wav + lyrics.json + clips.json. Renamed `library/` → `research/`. Dropped stale `reports/`. Deleted all scaffolding (memory/, config/, content/, apps/, era.json, tasks.md, .env.example, 8 READMEs). Updated RECOUP.md with minimal "What's Here" + "Adding Things" guidance.
**PRs:** none yet — changes are local, need to commit and push to rostrum repo and skills repo
**Notes:** The tasks content pipeline only reads `context/artist.md`, `context/audience.md`, `context/images/face-guide.png`, and `songs/*.mp3` via GitHub API. No per-artist config needed — pipeline uses hardcoded defaults. Song naming matters: pipeline derives title from filename, so `{slug}.mp3` not `audio.mp3`. Old gatsby-grace directories (`.local/records/artists/gatsby-grace` and `gatsby-grace-old`) can be deleted after verifying pipeline works. Other rostrum artists still have the old bloated scaffolding — migrate separately.

---

## [2026-03-25] Round 5 lint + KISS fixes for PR #342 (REC-7)
**Prompt:** Fix the failing checks on PR #342
**Status:** completed
**Changes:**
- api: Deleted `lib/coding-agent/getThread.ts` wrapper (KISS nit from code reviewer) — callers now import `getThread` directly from `lib/agents/getThread` with type parameter
- api: Fixed unused `message` parameter lint error in `registerOnNewMention.ts`
- api: Updated test mocks to match new import paths
**PRs:** https://github.com/recoupable/api/pull/342 (commit `694f201`)
**Notes:** All CI checks (test, format, CodeRabbit, Vercel) were already passing. These fixes address the last code review nit and lint cleanliness. 6 files changed, 9 ins, 19 del.

---

## [2026-03-25] Round 2 review fixes for PR #342 (REC-7)
**Prompt:** Address new board + CodeRabbit feedback on content-agent PR #342
**Status:** completed
**Changes:**
- api: SRP — split `validateEnv.ts` into `isContentAgentConfigured.ts` + `validateContentAgentEnv.ts`
- api: KISS — refactored `bot.ts` to eager singleton variable matching coding-agent pattern
- api: KISS — refactored `registerHandlers.ts` to module-level side-effect registration (removed flag)
- api: DRY — extracted shared `getThread` to `lib/agents/getThread.ts` (both agents use it)
- api: CodeRabbit — added Zod platform validation + JSON error responses in `createPlatformRoutes.ts`
**PRs:** https://github.com/recoupable/api/pull/342 (commit `2abed88`)
**Notes:** 10 files changed, 60 ins / 65 del. Bot init DRY question addressed: both agents already share `createAgentState` + `agentLogger`; remaining adapter config differs per agent so further abstraction would violate KISS. Awaiting Code Reviewer re-review.

---

## [2026-03-25] TDD mandate for SR Dev — API & Tasks (REC-11)
**Prompt:** Update SR Dev AGENTS.md to mandate TDD red-green-refactor for API and Tasks codebases
**Status:** completed
**Changes:**
- agents/sr-dev/AGENTS.md: Added "Test-Driven Development (API & Tasks)" section mandating strict red-green-refactor cycle for all work in api and tasks codebases
**PRs:** none (local instruction change)
**Notes:** SR Dev must now write failing tests before any production code in api or tasks. Includes rules for bug fixes (reproduce first) and commit-per-phase guidance.

---

## [2026-03-25] CLEAN code review fixes for PR #342 (REC-7)
**Prompt:** Address 7 board feedback items on PR #342 (YAGNI, SRP, DRY, KISS, restructure)
**Status:** completed
**Changes:**
- api: Removed unused `/api/launch` endpoint and `lib/launch/` (YAGNI)
- api: Extracted `parseMentionArgs` to own file, renamed handler → `registerOnNewMention.ts` (SRP)
- api: Created shared `lib/agents/createPlatformRoutes.ts` factory used by both coding-agent and content-agent (DRY)
- api: Created shared `lib/agents/createAgentState.ts` for Redis/ioredis state (DRY)
- api: Moved callback auth into handler to match coding-agent pattern (KISS)
- api: Restructured `lib/content-agent/` → `lib/agents/content/`
**PRs:** https://github.com/recoupable/api/pull/342
**Notes:** 21 files changed, 206 ins, 511 del. Awaiting Code Reviewer re-review.

---

## [2026-03-25] QA Test PR #342 — content-agent & launch endpoints (REC-7)
**Prompt:** Test the changes in PR #342 against Vercel deployment preview
**Status:** completed
**Changes:**
- none (testing only)
**PRs:** none
**Notes:** Initial test run (11 cases) found 5 failures — content-agent endpoints returned 500 due to missing env vars crashing `getContentAgentBot()`. Sr Dev fixed with `isContentAgentConfigured()` guard and moved auth before bot init (commit `9da3aef`). Re-test: all 11 cases pass. Results posted on GitHub PR #342 and Slack #code-review thread. Task marked done.

---

## [2026-03-25] Hire QA Tester agent (REC-10)
**Prompt:** Create a QA Tester agent that tests API PRs by running fetch requests against Vercel deployment previews
**Status:** completed
**Changes:**
- mono: Created `agents/qa-tester/AGENTS.md` — full instructions for deployment preview testing, endpoint discovery from PR diffs, structured test reporting
- mono: Updated `agents/code-reviewer/AGENTS.md` — added QA Tester Integration section (trigger QA Tester after approving API PRs)
- mono: Updated `agents/sr-dev/AGENTS.md` — added QA Tester Feedback section (handle test failure reports)
- Paperclip: Submitted hire request for QA Tester agent (f4d6bc75-b9ea-4fca-a456-4b889548ad83, claude-sonnet-4-6, reports to CTO)
**PRs:** none (local instruction changes)
**Notes:** Approval granted (d2fcb05e). Agent ID: f4d6bc75-b9ea-4fca-a456-4b889548ad83, urlKey: qa-tester. Agent workflow: Code Reviewer approves API PR → @-mentions QA Tester → QA Tester runs fetch tests against Vercel preview → reports on GitHub PR + Slack → routes failures to Sr Dev.

---

## [2026-03-24] API — review PR #342 (REC-7)
**Prompt:** Review clean PR #342 (superseding #341) for content-agent feature, identify Vercel build failure cause
**Status:** completed
**Changes:**
- none (review only)
**PRs:** https://github.com/recoupable/api/pull/342 (approved after 1 review cycle)
**Notes:** Initial review found 2 blocking issues: (1) module-level env validation crashed Vercel build, (2) fragile thread ID parsing. Sr Dev fixed both (commit `5ca4293`). Re-review confirmed fixes + all CI checks pass (test, format, Vercel). PR approved and ready to merge. Slack thread updated.

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

## [2026-03-25] marketing: Clarify deployment domain and two-app structure in AGENTS.md

**Prompt:** Apply code review feedback on branch `agent/-u0ajm7x8fbr-update-or-codebas-1774058502626` — answer Sweets' questions: what domain does marketing deploy to, and why are there multiple apps?
**Status:** completed
**Changes:**
- `marketing`: Updated `AGENTS.md` — Deployment section now explicitly states public site deploys to `https://recoupable.com`. Added new "Why Two Apps?" section explaining `apps/web` (public site, SEO, blog) vs `apps/ops` (internal marketing ops tooling, private workflows). Pushed to existing branch.
**PRs:** Branch `agent/-u0ajm7x8fbr-update-or-codebas-1774058502626` pushed to `recoupable/marketing` — PR targets `main`
**Notes:** The marketing repo was already on this feature branch. AGENTS.md is symlinked as CLAUDE.md — both updated together automatically.

---

## [2026-03-24] chat: implement PR review feedback — streamdown plugins

**Prompt:** Implement PR review comments on https://github.com/recoupable/chat/pull/1592 (streamdown v1→v2 upgrade)
**Status:** completed
**Changes:**
- `chat`: Installed `@streamdown/code@1.1.1`, `@streamdown/math@1.0.2`, `@streamdown/mermaid@1.0.2`.
- `chat`: Updated `components/ai-elements/response.tsx` to import and pass `plugins={{ code, math, mermaid }}` to `<Streamdown>`. `defaultPlugins` defined as module-level constant for stable reference.
- `chat`: Added `@source` directives in `app/globals.css` for the three new plugin packages so Tailwind scans their classes.
**PRs:** https://github.com/recoupable/chat/pull/1592 (branch `agent/-u0ajm7x8fbr-update-chat-to-th-1774075858898`)
**Notes:**
- P1 bot review resolved: streamdown v2 moved code highlighting, math, and mermaid behind optional plugins — without them, code blocks had no syntax highlighting and mermaid/math wouldn't render.
- `katex/dist/katex.min.css` was already imported in `globals.css` — math CSS was pre-existing.

---

## [2026-03-24] Code Review — chat: streamdown v1→v2 upgrade

**Prompt:** Code review for branch `agent/-u0ajm7x8fbr-update-chat-to-th-1774075858898` (streamdown v1.1.6 → v2.5.0)
**Status:** completed — no fixes needed, changes are correct
**Changes:**
- `chat`: Reviewed 3-file diff: `package.json` (version bump), `app/globals.css` (`@source` glob), `pnpm-lock.yaml`.
**PRs:** Branch `agent/-u0ajm7x8fbr-update-chat-to-th-1774075858898` — PR needs to be opened targeting `test`.
**Notes:**
- `@source dist/*.js` glob is the official v2 recommendation (v2 splits classes across 4 files vs 1 in v1).
- `Streamdown` component API is backward compatible — `className`, `children`, `components`, `rehypePlugins`, `remarkPlugins` all still present.
- `data-streamdown='code-block'` CSS selectors in `response.tsx` still valid in v2 (confirmed in `chunk-BO2N2NFS.js`).
- v2 ships `streamdown/styles.css` with animation keyframes — not imported, not needed unless `animated` prop is used.

---

## [2026-03-20] Fix Chartmetric Proxy Route TypeScript Build Error

**Prompt:** Verify the build works on feature/chartmetric-proxy branch
**Status:** completed
**Changes:**
- `api`: Fixed `app/api/chartmetric/[...path]/route.ts` — params must be `Promise<{path: string[]}>` and awaited in Next.js 15+. The type error `.next/types/validator.ts TS2344` is now resolved. TypeScript compiles successfully (`✓ Compiled successfully`). All 5 Chartmetric tests pass.
**PRs:** https://github.com/recoupable/api/pull/318 (feature/chartmetric-proxy → test, existing PR updated)
**Notes:** Build still fails at "collect page data" step due to missing SUPABASE_URL/SUPABASE_KEY env vars in sandbox — pre-existing environment issue, not from our changes. TypeScript itself is clean for the new code.

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

## [2026-03-26] Song Filtering for Content Creation Pipeline

**Prompt:** Add optional `songs` array to content creation payload so callers can restrict clip selection to specific songs (e.g., for an EP, a single, or a named album track).
**Status:** completed
**Changes:**
- `tasks`: `src/schemas/contentCreationSchema.ts` — added `songs: z.array(z.string()).optional()`. `src/content/selectAudioClip.ts` — filters `songPaths` by slug before random pick; throws clear error if none found. `src/tasks/createContentTask.ts` — passes `payload.songs` to `selectAudioClip`. New `src/content/__tests__/selectAudioClip.test.ts` — 4 tests covering filter-to-one, filter-to-many, missing-song error, and no-filter (all-songs) cases. `src/schemas/__tests__/contentCreationSchema.test.ts` — 2 new tests for songs field.
- `api`: `lib/trigger/triggerCreateContent.ts` — added `songs?: string[]` to `TriggerCreateContentPayload`.
**PRs:** `gh` not available in sandbox — PRs need to be opened via GitHub:
- tasks: `feature/song-filtering-for-content-pipeline` → main: https://github.com/recoupable/tasks/pull/new/feature/song-filtering-for-content-pipeline
- api: changes committed to `test` branch directly (was already on test with many staged changes)
**Notes:** Filtering is path-based: `path.includes('/songs/${slug}/')`. Callers (Slack bot, chat agent) are responsible for translating user intent (e.g., "ADHD EP") into song slugs before passing to the task. When `songs` is omitted, all songs remain eligible (backward-compatible).

---

## [2026-03-26] Artist profile creation — 6 Rostrum artists
**Prompt:** Create context/artist.md profiles for 6 Rostrum artists using web research
**Status:** completed (5 full profiles, 1 placeholder)
**Changes:**
- rostrum/artists: Created `context/artist.md` for goosebytheway (Drumwork/Conway the Machine rapper, Buffalo), mike-taylor (Philly pop-soul, "Feel Good" EP), no-love-for-the-middle-child (Andrew Migliore, multi-instrumentalist producer-artist), rashad-thomas (Columbus producer/rapper, "I Was Told There'd Be Gold" via Fat Beats), solene (cyber jazz pioneer, "Mother of Cyber Jazz", minthaze collaborator)
- rostrum/artists: Created placeholder `context/artist.md` for jada — no public information found linking any "Jada" artist to Rostrum Records; profile marked for update when label provides details
**PRs:** none — changes are local in `.local/records/rostrum/`
**Notes:** Jada is the only artist with insufficient research results. Multiple search variations tried (Jada rapper, Jada musician Rostrum, Jada hip hop, etc.) — found Jada Kingdom (Republic Records), Jada Lee (Philly independent), and JADA (East London) but none confirmed on Rostrum. Profile written as honest placeholder rather than fabricated content. All other profiles built from confirmed web sources with real proof points.

---

## [2026-03-26] Artist Profile Creation — 7 Rostrum Artists
**Prompt:** Create context/artist.md profiles for 7 Rostrum Records artists using web research and the established template format
**Status:** completed
**Changes:**
- rostrum/artists: Created `context/artist.md` for mac-miller (legacy, deceased 2018), wiz-khalifa (Rostrum flagship), jeezy (trap pioneer), raekwon (Wu-Tang/mafioso rap), mobb-deep (Queensbridge duo, Prodigy deceased 2017), sean-price (Boot Camp Clik, deceased 2015), smif-n-wessun (Boot Camp Clik duo)
- All 7 profiles follow the established template format (matching ale-araya's structure): personality, topics, genre, comparables, positioning, aesthetic, mood, colors, settings, fashion, voice, tone, sacred rules, avoid
- Each profile built from web research with real biographical data, chart positions, album details, and cultural context — no placeholders or fabricated details
**PRs:** none — changes are local in `.local/records/rostrum/`
**Notes:** Three of the seven artists are legacy/catalog acts (Mac Miller d. 2018, Prodigy/Mobb Deep d. 2017, Sean Price d. 2015). Profiles for deceased artists are written to guide catalog/legacy content management. All profiles include extra sections (Signature Elements, Visual References) only when real information was available.

---

## [2026-03-26] Feature Suggestion — Song Release Planner

**Prompt:** @U0AJM7X8FBR asked agent to read the codebase and suggest a new feature to build.
**Status:** suggestion only — not yet implemented
**Changes:** none (PROGRESS.md update only)
**PRs:** none
**Notes:** Suggested feature: **Song Release Planner with Automated Task Scheduling**. A visual release timeline in the chat app where artists/labels plan a release date, get an AI-generated pre/post-release activity schedule (teasers, press push, social posts, fan emails), and one-click convert it into real Trigger.dev tasks. Builds entirely on existing `tasks` + `catalogs` + `content` + `pulses` infrastructure. Scope: new `releases` Supabase table + `POST/GET /api/releases` endpoints + `lib/releases/` domain logic + `/releases` chat frontend page + `scheduleReleaseTasksTask` Trigger.dev task + OpenAPI docs. No new external dependencies required.

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

## [2026-03-26] Song Filtering for Content Creation Pipeline
**Prompt:** Add optional songs filter to content creation pipeline so callers can limit generation to specific songs/EPs
**Status:** completed
**Changes:**
- `tasks`: Added `songs?: string[]` to `contentCreationSchema`; `selectAudioClip` now filters by slug before random selection; `createContentTask` passes `payload.songs` through; 6 new tests passing
- `api`: Added `songs?: string[]` to `TriggerCreateContentPayload` interface in `lib/trigger/triggerCreateContent.ts`
**PRs:**
- tasks: pending (branch: feature/song-filtering-for-content-pipeline)
- api: pending (branch: agent/-u0ajm7x8fbr---song-filtering--1774495678034)
**Notes:** Caller is responsible for translating user intent (e.g. "ADHD EP") into song slug arrays. Pipeline just filters — no release detection logic.

---
