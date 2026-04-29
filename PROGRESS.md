# PROGRESS.md

> Last updated: 2026-04-26

---

## [2026-04-26] skills + open-agents + docs — drive create-artist from a RECOUP.md checklist file
**Prompt:** Latest create-artist workflow only ran 1–2 of the 8 steps sporadically. Fix with minimal architecture: make the artist's `RECOUP.md` the workflow state — scaffold with one checkbox per step, tick + persist values after each step, resume from the first unchecked item.
**Status:** in_progress (3 PRs open, awaiting review)
**Changes:**
- skills: PR #17 — `skills/artist-workspace/SKILL.md` adds new "Creating a new artist" section (Step-0 scaffold template with kebab-case slug + frontmatter slots for `artistId`/`spotifyArtistId`/`spotifyProfileUrl`/`imageUrl`, per-step tick + persist rule, resume-from-first-unchecked rule), broadens description triggers to fire on create/onboard/add intents, updates path intro and inventory commands to handle org-scoped layout (`orgs/$RECOUP_ORG_ID/artists/{slug}/`); `recoup-api/SKILL.md` rewrites the multi-step workflows section so the create-artist row points at artist-workspace as the driver and adds an explicit "invoke artist-workspace first" instruction.
- open-agents: PR #18 — `apps/web/lib/recoup-api-skill-prompt.ts` extends the always-on system-prompt nudge so create-artist intents ("create artist", "onboard X", "add an artist", "set up a new artist") route through `artist-workspace` first before falling through to `recoup-api`. JSDoc updated. `bun run check` + `bun run --cwd apps/web typecheck` pass.
- docs: PR #166 — `workflows/create-artist.mdx` rewritten so RECOUP.md is the workflow state: new "Step 0: Scaffold the workspace BEFORE any API call" section with the full template, new "Resuming a partial setup" section right under it, per-step "After this step" reminders on steps 1–8 (what to persist into frontmatter / Notes + which checkbox to tick), Step 8 appends KB report into the same `RECOUP.md` under `## Knowledge base`, "What this workflow doesn't enforce" rewritten to reflect honor-system reality + 3 constraints.
**PRs:** https://github.com/recoupable/skills/pull/17, https://github.com/recoupable/open-agents/pull/18, https://github.com/recoupable/docs/pull/166
**Notes:** Architecture choice ruled in/out before landing: (a) chose file-as-state over a Vercel Workflow because the chain is honor-system pure HTTP and the workflow engine is overkill for a 7–8 step chain; (b) chose to keep the checklist in the existing artist-workspace skill rather than a new `create-artist` skill because artist-workspace already owns the `RECOUP.md` filesystem contract; (c) deliberately kept changes inside skill content + the static recoupApiSkillPrompt nudge and did NOT touch `buildSystemPrompt`, `ensureSetupSandbox`, or add a new MCP tool — those are heavier escalations if the file-state approach drifts. Merge order matters: skills #17 first (load-bearing), then open-agents #18 (nudge that points at the new behavior), docs #166 last/parallel (reference material). Trace-of-the-day: open-agents has its own `apps/web/app/api/chat/route.ts`; skill *content* only reaches the model when `skillTool` is invoked by name (sandbox.readFile at invoke time), so getting the routing nudge right is the only open-agents-side leverage point. Tradeoff accepted: agent still has to truthfully tick its own boxes — if drift persists, upgrade path is a Vercel Workflow with enforced step ordering. Branch state (skills/open-agents/docs submodules switched back to main locally — feature branches live on the remotes only).

## [2026-04-25] docs + skills — create-new-artist workflow playbook
**Prompt:** Step 2 of the migration plan — write the multi-step create-artist playbook in docs and update the recoup-api skill to point at it, so a sandbox can execute the same chain the chat agent runs internally
**Status:** completed (docs squash-merged to main as `b092f5d`; skills squash-merged to main as `1e5c7ae`)
**Changes:**
- docs: PR #165 — new `workflows/create-artist.mdx` (curl-by-curl playbook covering POST /api/artists → Spotify match → 4-in-1 PATCH for profile + socials → deep + web research → Spotify catalog → KB synthesis to `orgs/$RECOUP_ORG_ID/artists/$ARTIST_ID/RECOUP.md` per artist-workspace conventions); skips youtube_login (Composio handles it). New "Workflows" group at the top of the Artists nav tab. Every step links to the corresponding endpoint reference. Also fixes a defect from PR #164: `profileUrls` example keys are now uppercase (`SPOTIFY`, `INSTAGRAM`, …) since `getSocialPlatformByLink` returns uppercase and `updateArtistSocials` matches case-sensitively — lowercase keys would have created duplicate socials instead of replacing existing entries.
- skills: PR #16 — `recoup-api/SKILL.md` adds a "Multi-step workflows" section linking the new docs page; broadens description triggers to fire on "create new artist", "create artist", "onboard artist", "add artist" (same pattern as PRs #14/#15/#16 broadenings).
**PRs:** https://github.com/recoupable/docs/pull/165 (merged `b092f5d`), https://github.com/recoupable/skills/pull/16 (merged `1e5c7ae`)
**Notes:** Review iterations on docs #165: tightened frontmatter description (KISS), dropped Skipped/YouTube and Optional/KB-persist sections (KISS+YAGNI — the workflow's output is updated artist directories on the filesystem, no API knowledges PATCH needed), step 2 now exports SPOTIFY_ARTIST_ID/SPOTIFY_PROFILE_URL/SPOTIFY_IMAGE_URL with a runnable jq selector + guard (cubic P2 about undefined var), exact-name matches sort by popularity before picking first (cubic P2 about ambiguous match), `// empty` on jq -r extractions so guard catches null (cubic P1). Step 2 of three in the create-artist migration plan. Step 1 was PR #164 (`PATCH /api/artists/{id}` doc). Step 3 (optional) is adding `urls: string[]` to `validateUpdateArtistRequest` in api so the sandbox doesn't have to do URL→platform mapping itself — left as follow-up. Tradeoffs we accepted: no `prepareStep`-style determinism (the agent has to follow the doc in order), no per-step model switching, no per-step custom system prompts. The skills PR's published URL `developers.recoupable.com/workflows/create-artist` resolves now that docs has merged.

## [2026-04-25] docs — document PATCH /api/artists/{id}
**Prompt:** Working out how to bring open-agents' create-new-artist flow to chat-level quality via the skill+docs path; first prerequisite is closing the gap where the workhorse PATCH endpoint shipped in api but was never documented
**Status:** completed (squash-merged to main as `1486245`)
**Changes:**
- docs: PR #164 — adds the `PATCH /api/artists/{id}` operation to `api-reference/openapi/releases.json` (covers name, image, label, instruction, knowledges, profileUrls map, pinned), six new schemas (`UpdateArtistRequest`, `UpdateArtistResponse`, `UpdateArtistErrorResponse`, `UpdatedArtist`, `UpdatedArtistSocial`, `ArtistKnowledge`), frontmatter-only `api-reference/artists/update.mdx`, and a nav entry under the Artists group between create and pin. Tightened PATCH description per review (`48c69ec`): "Update mutable fields on an artist accessible to the authenticated account." → "Update an artist."
**PRs:** https://github.com/recoupable/docs/pull/164 (merged `14862453`)
**Notes:** The endpoint already exists in code (`api/app/api/artists/[id]/route.ts` → `updateArtistHandler` → shared `updateArtistSocials` + `upsertArtistInfoFields`) and is JWT-callable via `validateAuthContext` + `checkAccountArtistAccess`. The chat tool chain treats updates as ~4 separate MCP tools (`update_artist_socials` ×2, `update_account_info` ×2 for profile + knowledges) but they all collapse to this one PATCH. Open-agents/sandbox can already call it — only the public-docs visibility was missing, which the `recoup-api` skill needs to surface it. Body schema enforces "at least one field provided" (Zod `.refine` in `validateUpdateArtistRequest.ts`); doc'd as `minProperties: 1` + description note. Response shape matches `getFormattedArtist` exactly: `{ artist: { account_id, name, image, instruction, label, knowledges, account_socials: [{ id, profile_url, username, link, type }], pinned } }`. Did NOT add a `urls: string[]` adapter to mirror the MCP tool's URL→platform inference — left as a follow-up if agents struggle with the platform-mapping step.

## [2026-04-24] skills + open-agents — sandbox-scoped artist inventory
**Prompt:** "What artists do I have" returned a cross-org list from the user-scoped API instead of the sandbox's `orgs/*/artists/*/RECOUP.md` tree — fix the filesystem-first behavior AND org-scope API calls when they do happen
**Status:** completed (both PRs open, awaiting review)
**Changes:**
- skills: PR #15 — expand `skills/artist-workspace/SKILL.md` description to trigger on inventory phrasings ("what artists do I have", "list my artists", "which orgs am I in"); add "Listing what's in the sandbox" section with `ls -d orgs/*/artists/*/` + `find orgs -type f -name RECOUP.md`; document `RECOUP_ORG_ID` in a new "Org scoping" section of `recoup-api/SKILL.md` with the `/api/organizations/{id}/...` + `--org $RECOUP_ORG_ID` patterns (no endpoint changes, skill guidance only)
- open-agents: PR #16 — new `apps/web/lib/recoupable/extract-org-id.ts` (tail-match UUID-v4 from repo name / clone URL; Recoupable repos are `org-<slug>-<uuid-v4>` so no schema change needed); derive `recoupOrgId` from `sessionRecord.cloneUrl` in `apps/web/app/api/chat/route.ts` and thread through `experimental_context` mirroring the `recoupAccessToken` plumbing; `packages/agent/tools/build-recoup-exec-env.ts` now merges both into the exec env as `RECOUP_ACCESS_TOKEN` + `RECOUP_ORG_ID`; add `artist-workspace` to `apps/web/lib/skills/default-global-skills.ts` so it auto-installs alongside `recoup-api`; rewrite `apps/web/lib/recoup-api-skill-prompt.ts` nudge to route by intent (artist-workspace for inventory, recoup-api for live data, scope list endpoints to `$RECOUP_ORG_ID`)
**PRs:** https://github.com/recoupable/skills/pull/15, https://github.com/recoupable/open-agents/pull/16
**Notes:** Design rationale we ruled in/out before landing: no new skill (artist-workspace already owns the filesystem contract — the fix was auto-install + broaden description trigger); no DB schema column for organizationId (clone URL already encodes the org UUID in the trailing 36 chars — derive on the fly); kept `recoup-api` portable by putting RECOUP_ORG_ID in its Environment section as an API-scoping concern (non-sandbox consumers just have it unset). Pre-existing `apps/web/app/api/pr/route.test.ts` failures (server-only import + 403) still reproduce on unmodified main — unrelated.

## [2026-04-24] open-agents — broaden recoup-api skill nudge
**Prompt:** Debug why first-prompt "What tasks do I have?" didn't load the recoup-api skill; implement the broadened-trigger fix and open a PR
**Status:** completed
**Changes:**
- open-agents: PR #15 opened against `main` — widens `apps/web/lib/recoup-api-skill-prompt.ts` keyword list (adds tasks, chats, pulses, notifications, subscriptions), shifts trigger from "platform data" to "anything belonging to their Recoup account", and explicitly steers ambiguous phrasings ("my tasks / my artists / my notifications") away from repo-TODO interpretations. Cost stays ~1 sentence; skill body still lazy-loaded via `skillTool`.
**PRs:** https://github.com/recoupable/open-agents/pull/15
**Notes:** Root cause of the repro — "tasks" was not in the original nudge's noun list from PR #14, and "tasks" is heavily overloaded (TODOs, issues, background jobs), so the generic prior won turn 1. Only "check recoup" unblocked it. Follow-up: `recoupable/skills/recoup-api/SKILL.md` trigger-phrase list also omits "tasks" — worth a matching widening for the skill-auto-discovery path. Pre-existing `apps/web/app/api/pr/route.test.ts` failures reproduce on unmodified main and are unrelated.

## [2026-04-23] docs + api + chat — GET /api/songs migration promoted + synced
**Prompt:** Review/test/merge the songs migration across docs, api, and chat; promote each to main and resync test branches
**Status:** completed
**Changes:**
- docs: PR #154 squash-merged to `main` (`f45b4893`) — top-level `servers` in `releases.json` updated to `recoup-api.vercel.app`; `/api/songs` OpenAPI entry migrated. Left 21 per-operation `servers` overrides pointing at `api.recoupable.com` untouched per user's scope-narrow ask (7 in releases.json, 14 in social.json) — tracked as a separate cleanup if it becomes visible in UI.
- api: PR #466 squash-merged to `test` (`f185fa5f`) — new `app/api/songs/route.ts` + `getSongsHandler` + `validateGetSongsRequest`; auth-only (no `checkAccountArtistAccess`) since song metadata is DSP-public per validator docstring
- api: PR #474 opened & merged (`test` → `main`, `60f22f34`); `test` fast-forwarded to match `main` and pushed
- chat: PR #1693 squash-merged to `test` (`22b30956`) — `useSongsByIsrc` now gated on `authenticated` and passes `Authorization: Bearer <Privy JWT>`; `getSongsByIsrc` replaces hardcoded `api.recoupable.com` with `getClientApiBaseUrl()`
- chat: PR #1700 opened & merged (`test` → `main`, `86bd427c`); `test` fast-forwarded to match `main` and pushed
**PRs:** https://github.com/recoupable/docs/pull/154, https://github.com/recoupable/api/pull/466, https://github.com/recoupable/api/pull/474, https://github.com/recoupable/chat/pull/1693, https://github.com/recoupable/chat/pull/1700
**Notes:** Preview-verified api #466 with 9 cases (401/400/404/403/200 + populated-row shape + unfiltered 1000-row cap flag) — https://github.com/recoupable/api/pull/466#issuecomment-4307823592. Chat #1693 verified end-to-end via Chrome DevTools MCP on preview — request goes to `test-recoup-api.vercel.app/api/songs` with Bearer header, returns the expected row shape — https://github.com/recoupable/chat/pull/1693#issuecomment-4307932763. Cubic's `song_artists!inner` concern (orphan songs excluded) noted but skipped per user. On docs #154: copy-button on localhost was showing `api.recoupable.com` because Mintlify was reading per-operation `servers` overrides (POST /api/songs had one pointing at the old host); the narrow-scope fix would only strip the POST override but user chose to ship as-is.

## [2026-04-23] api + chat — GET /api/accounts/{id}/catalogs migration promoted + synced
**Prompt:** Review/test/merge the catalogs-migration PRs across api and chat; promote test→main and resync test on both
**Status:** completed
**Changes:**
- api: PR #464 squash-merged to `test` (`46a8e06`) — new `app/api/accounts/[id]/catalogs/route.ts` + `getCatalogsHandler` + `validateGetCatalogsRequest` pattern; MCP tool + evals updated; shrunk `selectAccountCatalogs`
- api: PR #473 opened & merged (`test` → `main`, `67bddf64`); `test` fast-forwarded to match `main` and pushed
- chat: PR #1691 squash-merged to `test` (`99a7feb6`) — `useCatalogs` gated on auth readiness; `lib/catalog/getCatalogs.ts` hits the new account-scoped endpoint
- chat: PR #1699 opened & merged (`test` → `main`, `ec68f618`); `test` fast-forwarded to match `main` and pushed
**PRs:** https://github.com/recoupable/api/pull/464, https://github.com/recoupable/api/pull/473, https://github.com/recoupable/chat/pull/1691, https://github.com/recoupable/chat/pull/1699
**Notes:** Preview-verified #464 at commit `79dd6ac` — 5-case smoke test (401/400/404/200 confirmed; 403 relied on arpit's earlier verification at `fe1e030` since I didn't have a second real account UUID). Cubic's two original findings (auth-context override making access check a self-check; raw exception in 500 body) had already been fixed by arpit in `d0900a8` and `e50913e` before I picked it up. The new access-check pipeline (`validateAuthContext` → `checkAccountAccess(callerId, targetId)`) is the intended security fix over the legacy `/api/catalogs?account_id=X` route which had no access check. Docs PR #153 (merged earlier today) is the third leg of the migration.

## [2026-04-23] docs — PR #153 merged (catalogs endpoint migration)
**Prompt:** Check out and merge docs PR #153
**Status:** completed
**Changes:**
- docs: migrate GET catalogs docs to `/api/accounts/{id}/catalogs`; delete the standalone POST/DELETE `catalogs-create.mdx` and `catalogs-delete.mdx` pages; shrink `releases.json` OpenAPI surface (+14/−71); drop two entries from `docs.json`
**PRs:** https://github.com/recoupable/docs/pull/153 (squash-merged as `a4ecdb8` on `main`)
**Notes:** Mintlify deploy check skipped (normal for docs-only PRs). Local branch deleted; local main is behind origin by 2 commits (the squash commit + whatever else landed) — normal until the next `git pull`.

## [2026-04-23] skills + open-agents — recoup-api skill + customInstructions nudge
**Prompt:** Make the agent always know to search the Recoup API docs when calling the Recoupable API, so the user doesn't have to include docs each time
**Status:** completed
**Changes:**
- skills: new `recoup-api/SKILL.md` (plain directory, matches precedent of `trend-to-song` / `skill-creator`) with playbook — base URL `recoup-api.vercel.app/api`, `RECOUP_ACCESS_TOKEN` Bearer auth, mandatory `/llms-full.txt` docs fetch as step 1, token-scope warnings, troubleshooting table, and a "when NOT to use" section so it doesn't shadow chartmetric/filesystem work
- skills: `README.md` skills table updated with the new entry
- open-agents: new `apps/web/lib/recoup-api-skill-prompt.ts` with a single-sentence nudge
- open-agents: `apps/web/app/api/chat/route.ts` composes both prompts (`[assistantFileLinkPrompt, recoupApiSkillPrompt].join("\n\n")`) into `customInstructions`; test expectation updated to match
**PRs:** https://github.com/recoupable/skills/pull/14 (squash-merged as `28f508f` on `main`), https://github.com/recoupable/open-agents/pull/14 (squash-merged as `e8b8f7f` on `main`)
**Notes:** Chose skill + nudge over inlining docs in the system prompt: full docs would always-on cost and not scale as we add more domain bundles (chartmetric, etc.), while a skill is loaded on demand via `skillTool`. The nudge is the belt-and-suspenders that makes sure oblique prompts still trigger the skill. Skill body explicitly reiterates the per-prompt token scope from PR #13 (no disk persist, no detached processes, no inline printing) so the two changes stay coherent. Sandboxes pick up the skill via `npx skills add recoupable/skills` at setup time — existing sandboxes would need a re-install or a fresh org base snapshot (PR #9) to see it.

## [2026-04-23] open-agents — per-prompt Privy access token forwarded into sandbox exec env
**Prompt:** Add authorization so the sandbox can call the Recoup API; pass the Privy access token per-prompt instead of minting a custom sandbox key
**Status:** completed
**Changes:**
- open-agents: `packages/sandbox/interface.ts` + `vercel/sandbox.ts` — `Sandbox.exec` / `execDetached` accept an optional per-call `env`; new `mergeCommandEnv` merges per-call entries on top of the persistent sandbox env (per-call wins)
- open-agents: `packages/agent/types.ts` + `open-harness-agent.ts` — `AgentContext` / `callOptionsSchema` accept `recoupAccessToken`; forwarded onto `experimental_context`
- open-agents: `packages/agent/tools/utils.ts` — new `getRecoupAccessToken` / `buildRecoupExecEnv` helpers
- open-agents: `bashTool` + `webFetchTool` inject `RECOUP_ACCESS_TOKEN` into their own exec env only (grep/glob/etc. never see it); new test asserts both `exec` and `execDetached` paths
- open-agents: `/api/chat` body accepts `recoupAccessToken` and plumbs into `agentOptions`; client transport uses `usePrivy().getAccessToken()` in a ref so the transport memo stays stable
**PRs:** https://github.com/recoupable/open-agents/pull/13 (squash-merged as `b170596` on `main`)
**Notes:** Picked this shape after ruling out minting a custom sandbox-scoped Recoup API key — Privy tokens are already short-lived (~1h) and auto-expire, p95 prompt <30min, so a fresh token per prompt always outlives the prompt that uses it. No DB schema, no mint/revoke endpoints, no cleanup workflow. Token lives in a single exec process env and dies with the command; idle sandboxes hold no credential. Server-side token verification intentionally skipped — Recoup API is the validation boundary. Client TTL pre-check (refresh if <35min remaining) deferred as follow-up. Pre-existing `apps/web/app/api/pr/route.test.ts` failures on `main` are unrelated.

## [2026-04-22] open-agents — PR #7 review: drop /api/orgs passthrough
**Prompt:** Check out PR #7, review the comments I left, and apply them
**Status:** completed
**Changes:**
- open-agents: Deleted `apps/web/app/api/orgs/route.ts` (internal Next.js route only forwarded the Privy access token)
- open-agents: `useOrgs` now calls `fetchAccountOrgs(accessToken)` directly against the Recoup API; `Org` re-exported as alias of `RecoupableOrg` so `OrgSelector` is unchanged
**PRs:** https://github.com/recoupable/open-agents/pull/7 (commit 4f97af1 on `feat/org-selector-faster-sandbox`)
**Notes:** `RECOUPABLE_API_BASE_URL` already uses `NEXT_PUBLIC_VERCEL_ENV`, so the client can reach it directly — no CORS or env changes needed. Lint + typecheck clean.

## [2026-04-22] open-agents — PR #7: clone org repo directly, drop account-repo path
**Prompt:** Selected org should change which github repo is cloned (current PR was wrong shape)
**Status:** completed
**Changes:**
- open-agents: New `lib/recoupable/build-org-repo-url.ts` builds `https://github.com/recoupable/org-<kebab(name)>-<organization_id>` (e.g. `org-rostrum-pacific-cebcc866-...`)
- open-agents: `OrgSelector.onSelectOrg(cloneUrl)` emits the constructed URL; `createBlankSession` persists it to existing `sessions.cloneUrl` (no new column)
- open-agents: Sandbox handler always uses service `GITHUB_TOKEN` (all repos are owned by `recoupable` per user instruction); removed user-token gating
- open-agents: Deleted `resolve-account-repo-source.ts`, `extract-bearer-token.ts`, `fetch-account-github-repo.ts` (+ test)
- open-agents: Rolled back the `org_slug` column and migration 0031 (deleted `0031_*.sql`, `0031_snapshot.json`, removed entry from `_journal.json`); `db:check` confirms migrations are in sync
- open-agents: Stripped `orgSlug` from `initSubmodules`, `Source` type, and `VercelSandboxConfig`
- open-agents: Sidebar `+` button now navigates to `/sessions` (org picker) instead of trying to create a blank session
**PRs:** https://github.com/recoupable/open-agents/pull/7 (commit ebb1af2 on `feat/org-selector-faster-sandbox`)
**Notes:** Net diff -1800/+72 lines. Per CLAUDE.md, every preview deploy forks a fresh Neon branch from production, so deleting the migration files (vs. adding a rollback) is safe — orphan column on the current preview DB is harmless. User confirmed: always service token, never check repo owner.

## [2026-04-21] open-agents — clone org submodules into sandbox
**Prompt:** Update open-agents so org submodules in each account github repo are also cloned into the sandbox
**Status:** completed
**Changes:**
- open-agents: New `packages/sandbox/vercel/init-submodules.ts` helper runs `git submodule update --init --recursive` after any git-sourced clone; when a token is present, uses a per-invocation `-c url."...".insteadOf="..."` rewrite so private `.gitmodules` URLs authenticate without mutating global git config
- open-agents: `packages/sandbox/vercel/sandbox.ts` calls `initSubmodules` once after the clone block — covers both SDK-managed clone (no `baseSnapshotId`) and manual post-snapshot clone paths
- open-agents: 3 new unit tests; throws on non-zero exit so sandbox create fails loudly
**PRs:** https://github.com/recoupable/open-agents/pull/6 (merged as squash commit 8091630 on main)
**Notes:** Account repos layout: org submodules mounted at `.openclaw/workspace/orgs/<slug>`, all private repos in `recoupable/*` org (same access as the parent), so the existing server `GITHUB_TOKEN` fallback suffices. Did not backfill existing sandboxes via `snapshot-refresh` — scope was just submodule init on new sandbox create (confirmed with user). Verified end-to-end on the preview deploy before merge: `ls` showed populated `.openclaw/workspace/orgs/recoup/` with `.git` gitlink + `.gitignore` + `artists/`, `git submodule status` showed all 6 submodules initialized with SHAs and `heads/main` refs, per-org listing confirmed content pulled from the private recoupable/org-* repos via the per-invocation `insteadOf` rewrite.

## [2026-04-21] open-agents — REC-70 PR #5 review: privy token + fallback guards + zod
**Prompt:** Check out PR #5, triage comments, apply the recommended fixes (skip AbortController)
**Status:** completed
**Changes:**
- open-agents: Replaced `RECOUPABLE_API_KEY` env var with the caller's Privy access token in `fetchAccountGithubRepo`; send as `Authorization: Bearer`
- open-agents: Added `accessToken` to `Session` type and surfaced it from `getSessionFromCookie` so the sandbox route can forward it
- open-agents: Applied `parseGitHubUrl` + `githubToken` guards to the account-repo fallback in `POST /api/sandbox`, matching the explicit-repoUrl path
- open-agents: Validated Recoupable `/api/sandboxes` response shape with a Zod schema (rejects non-string `github_repo`)
- open-agents: Tests updated for Bearer header + invalid-shape case; kebab-case filename kept per `unicorn/filename-case` lint rule
**PRs:** https://github.com/recoupable/open-agents/pull/5 (commits 76eb3dc + d1e5d85 + fe757ad on `feature/rec-70-clone-github-repo`)

Follow-up structural commit (fe757ad) per additional review: POST `/api/sandbox` body extracted to `lib/sandbox/create-sandbox-handler.ts`; client `createSandbox` helper moved from the chats page folder to `lib/sandbox/create-sandbox.ts`; `handleCreateNewSandbox` + `ensureSandboxReady` + their shared state extracted into `hooks/use-sandbox-create.ts`.
**Notes:** Owner's inline camelCase-filename request was deferred — repo CLAUDE.md and oxlint both enforce kebab-case (confirmed with user). AbortController timeout suggestion was explicitly skipped by user. Auth-token handoff was initially implemented via server-side cookie read; after discussion, reverted the `Session.accessToken` plumbing and switched to an explicit `Authorization: Bearer` header — frontend pulls the token via `usePrivy().getAccessToken()` and passes it to `createSandbox`, route reads it off the request. Token path is now visible end-to-end (client → our backend → Recoupable) with no implicit cookie forwarding.

---

## [2026-04-20] api — Merged REC-69 to main + synced test
**Prompt:** Merge PR #458, promote test→main, sync test with main
**Status:** completed
**Changes:**
- api: PR #458 squash-merged into `test` (commit `e62622d`)
- api: PR #460 opened & merged (`test` → `main`, merge commit `f276a5a`)
- api: `test` branch fast-forwarded to match `main` and pushed
**PRs:** https://github.com/recoupable/api/pull/458, https://github.com/recoupable/api/pull/460
**Notes:** Shared Google fallback + multi-owner routing now on main. Repaired the previously-broken artist connector execute path as a side-effect. Preview verification recorded at https://github.com/recoupable/api/pull/458#issuecomment-4284850953.

---

## [2026-04-20] api — Multi-owner Composio tool routing + shared Google fallback (PR #458)
**Prompt:** Address PR review; test shared fallback end-to-end; fix when it didn't work
**Status:** completed
**Changes:**
- api: Hardcoded shared Composio account ID `recoup-shared-767f498e-e1e9-43c6-a152-a96ae3bd8d07` (removed `COMPOSIO_SHARED_ENTITY_ID` env var)
- api: Wired `COMPOSIO_GOOGLE_{SHEETS,DOCS,DRIVE}_AUTH_CONFIG_ID` into `buildAuthConfigs()` so custom Google OAuth configs resolve
- api: Rewrote tool-router to multi-owner model — customer session (meta-tools only), artist tools via `composio.tools.get(artistId, {toolkits})`, shared tools via `composio.tools.get(SHARED_ACCOUNT_ID, {toolkits})`. Priority: customer > artist > shared, enforced by toolkit filtering in `resolveSessionToolkits`
- api: Defensive try/catch in `getSharedAccountConnections`; error log preserved, info log removed after validation
- api: Deleted obsolete `createToolRouterSession.ts` (singular), `createToolRouterSessions.ts`, `getArtistConnectionsFromComposio.ts` — all superseded
**PRs:** https://github.com/recoupable/api/pull/458
**Notes:** Key finding: Composio Tool Router V2 `session.tools()` only returns the 6 meta-tools — never explicit toolkit tools. `connectedAccounts` override at session-create is accepted but execute-time ownership check rejects cross-account connections. Solution: use `composio.tools.get(ownerId, ...)` instead. This also fixes the pre-existing artist connector flow which was silently broken at execute time. Verified e2e on preview: read a Google Doc (LIKE / "Today Sounds Good" project brief) via shared fallback ✓; routed TIKTOK_GET_USER_STATS against artist connection ✓ (TikTok returned 401 due to expired token, but our routing worked). 92 composio tests + 2137 total passing.

---

## [2026-04-18] tasks — Cut getArtistSocials over to /api/artists/{id}/socials
**Prompt:** Checkout and merge tasks PR #143
**Status:** completed
**Changes:**
- tasks: PR #143 squash-merged into `main` (commit `da35314`); helper now uses `NEW_API_BASE_URL` path-style endpoint with `x-api-key` header
**PRs:** https://github.com/recoupable/tasks/pull/143
**Notes:** Skipped the CodeRabbit/cubic nitpick to wrap `artistAccountId` in `encodeURIComponent()` — artist IDs are UUIDs, so no practical risk. Depends on api PR #456 (admin-key artist access) already merged to main today.

---

## [2026-04-18] api — Admin key bypass for artist access + promote test→main
**Prompt:** Test PR #456 on preview, merge it, then promote test→main and resync test
**Status:** completed
**Changes:**
- api: PR #456 squash-merged into `test` (RECOUP_ORG members bypass artist membership in `checkAccountArtistAccess`)
- api: PR #457 opened & merged (`test` → `main`)
- api: `test` branch fast-forwarded to match `main` and pushed
**PRs:** https://github.com/recoupable/api/pull/456, https://github.com/recoupable/api/pull/457
**Notes:** Preview-verified with admin `x-api-key` against `/api/artists/{id}/socials` — returned 200 for an artist with no direct or shared-org access. 401 still enforced for unauth requests.

---

## [2026-04-18] open-agents — Scaffold Privy auth alongside Vercel OAuth (PR #1 of auth migration)
**Prompt:** Update open-agents to use same auth as chat/admin (Privy), replacing Vercel auth; keep scope small per PR
**Status:** completed (PR open)
**Changes:**
- open-agents: Added `@privy-io/react-auth` + `@privy-io/node` deps in `apps/web`
- open-agents: New `components/providers/privy-provider.tsx` — no-ops when `NEXT_PUBLIC_PRIVY_APP_ID` unset
- open-agents: New `lib/privy/{config,client,verify-token}.ts` server helpers for future token verification
- open-agents: New `components/auth/privy-login-button.tsx` — test login button rendered alongside existing Vercel button on signed-out hero
- open-agents: Wrapped `app/providers.tsx` with `PrivyProvider`
**PRs:** https://github.com/recoupable/open-agents/pull/2
**Notes:** Zero behavior change — Vercel OAuth untouched. Agreed migration sequence: PR#2 adds `privy` to users schema, PR#3 upserts Privy users, PR#4 demotes Vercel OAuth to "connect Vercel" linking flow, PR#5 swaps direct DB lookups for Recoup API calls (developers.recoupable.com), PR#6 flips default sign-in to Privy, PR#7 removes Vercel-as-primary-identity.

---

## [2026-04-14] Tasks — AI overlay position for editorial templates (REC-67)
**Prompt:** Overlaid images always placed top-left; use AI to determine ideal corner
**Status:** in_progress (PR open, awaiting code review)
**Changes:**
- tasks: New `ToolLoopAgent` (`createOverlayPositionAgent`) analyzes editorial image to pick best overlay corner
- tasks: New `overlayPosition.ts` with shared type and coordinate calculation for top-left/top-right/bottom-left/bottom-right
- tasks: Updated `buildStaticImageArgs`, `buildFilterComplex`, `buildFfmpegArgs`, `renderFinalVideo`, `createContentTask` to accept `overlayPosition`
- tasks: 14 new tests for position calculation and filter complex positioning
**PRs:** https://github.com/recoupable/tasks/pull/138
**Notes:** Backward-compatible — defaults to top-left when position not provided. Independent of REC-66 overlay size changes.

---

## [2026-04-14] Tasks — Larger playlist cover images (REC-66)
**Prompt:** Playlist cover images overlaid on editorial template videos are too small for record label customers
**Status:** in_progress (PR open, awaiting code review)
**Changes:**
- tasks: Increased `OVERLAY_SIZE` from 150px to 250px in `buildStaticImageArgs.ts` and `buildFilterComplex.ts`
- tasks: Updated tests in both test files to reflect new dimensions
**PRs:** https://github.com/recoupable/tasks/pull/137
**Notes:** Depends on REC-65 (PR #136) being merged first. PR branches from `feature/rec-65-editorial-static-image`.

---

## [2026-04-14] Tasks/API — Editorial template static image (REC-65)
**Prompt:** Editorial content template should return both video and a static image with playlist covers overlaid
**Status:** in_progress (PRs open, awaiting code review)
**Changes:**
- tasks: New `buildStaticImageArgs.ts` — ffmpeg args for single-frame image render with overlays
- tasks: New `renderStaticImage.ts` — downloads base + overlays, runs ffmpeg, uploads PNG to fal.ai
- tasks: `createContentTask` renders static image when template uses overlay, returns `staticImageUrl`
- tasks: `pollContentRuns` extracts `imageUrl` from task output
- api: `contentRunResultSchema` accepts optional `imageUrl` field
- api: `postVideoResults` downloads and posts static images before videos in Slack threads
- 15 new tests across both submodules (all green)
**PRs:**
- https://github.com/recoupable/tasks/pull/136
- https://github.com/recoupable/api/pull/438
**Notes:** API PR targets `test` branch. Tasks PR targets `main`. Both submodules must be deployed together.

---

## [2026-04-14] API — Slackbot default no artist (REC-64)
**Prompt:** Remove hardcoded Gatsby Grace default from content agent Slack bot; require artist name in prompt
**Status:** in_progress (PR open, awaiting code review)
**Changes:**
- api: Removed hardcoded `artistAccountId` from `registerOnNewMention.ts`
- api: Added `artistName` to `contentPromptFlagsSchema` for AI extraction from prompts
- api: New `selectAccountByNameInOrg.ts` for case-insensitive artist name lookup within an organization
- api: Bot now prompts user if no artist specified, shows error if not found
- api: 38 tests passing (20 registerOnNewMention + 13 parseContentPrompt + 5 selectAccountByNameInOrg)
**PRs:** https://github.com/recoupable/api/pull/437
**Notes:** Related to REC-40 (artist name param) which had an unmerged PR#382. REC-64 supersedes by making null the default instead of Gatsby Grace as fallback.

## [2026-04-14] API/Tasks/Docs — DSP logo overlay for editorial template (REC-63)
**Prompt:** Add dsp enum parameter so editorial videos can include Spotify/Apple Music logo overlay
**Status:** in_progress (PRs open, awaiting code review)
**Changes:**
- api: Added `dsp` enum (`none`/`spotify`/`apple`) to validation schema, trigger payload, content prompt agent, and Slack mention handler
- api: New `dspValues.ts` constant file following `captionLengths.ts` pattern
- api: 4 new tests for dsp validation and prompt extraction
- tasks: Added `dsp` to content creation schema, new `resolveDspLogoUrl` utility
- tasks: `createContentTask` appends DSP logo URL to overlay images for ffmpeg render
- tasks: 5 new tests for DSP resolution and pipeline integration
- docs: Added `dsp` field to OpenAPI spec and Content Agent Slack bot docs
**PRs:**
- https://github.com/recoupable/api/pull/436
- https://github.com/recoupable/tasks/pull/135
- https://github.com/recoupable/docs/pull/131
**Notes:** API PR targets `test` branch. Tasks/docs PRs target `main`. DSP logo URLs are placeholders — actual images will be added by the user after PR merge. All three submodules must be deployed together.

---

## [2026-04-13] API/Tasks — Default captions to none (REC-62)
**Prompt:** Slack bot generates captions even when not requested; default should be no captions
**Status:** in_progress (PRs open, awaiting code review)
**Changes:**
- api: Added `"none"` to `CAPTION_LENGTHS` enum, changed default from `"short"` to `"none"` across all schemas
- api: Updated prompt agent to only set captions when explicitly requested by user
- api: Updated 4 test files to reflect new defaults
- tasks: Added `"none"` to content creation schema, changed default to `"none"`
- tasks: Skip caption generation API call when `captionLength === "none"`, pass empty string to ffmpeg render
- tasks: Added test for caption skip behavior
**PRs:**
- https://github.com/recoupable/api/pull/433
- https://github.com/recoupable/tasks/pull/132
**Notes:** API PR targets `test` branch. Tasks PR targets `main`. Both submodules must be deployed together.

---

## [2026-04-13] Admin/API — Track embedded Slack videos instead of URLs (REC-61)
**Prompt:** Admin page tracks embedded videos from Slack bot instead of extracted video URLs
**Status:** in_progress (PRs open, awaiting code review)
**Changes:**
- api: Replaced `extractVideoLinks` (URL text parsing) with `extractVideoFiles` (Slack file object extraction)
- api: Replaced `fetchThreadVideoLinks` with `fetchThreadVideoFiles` to read `files` array on bot messages
- api: 12 new tests for extraction logic
- admin: Renamed "Video Links" column to "Videos", display friendly labels instead of raw URLs
**PRs:**
- https://github.com/recoupable/api/pull/432
- https://github.com/recoupable/admin/pull/27
**Notes:** API PR targets `test` branch. Admin PR targets `main`.

---

## [2026-04-13] API — Add View Task button to content agent Slack response (REC-60)
**Prompt:** Add "View Task" button to content agent Slack response, matching coding agent behavior
**Status:** in_progress (PR open, awaiting code review)
**Changes:**
- api: Moved `buildTaskCard` from `lib/coding-agent/` to shared `lib/agents/` (DRY)
- api: Added "View Task" button card to content agent `registerOnNewMention` handler
- api: Updated coding agent imports to use shared location
- api: 18 tests pass (2 new for buildTaskCard, 2 new for content agent View Task)
**PRs:**
- https://github.com/recoupable/api/pull/430
**Notes:** Button links to `chat.recoupable.com/tasks/{runId}` using the first triggered run ID.

---

## [2026-04-13] Tasks — Editorial image detection in content pipeline (REC-59)
**Prompt:** Detect editorial press photos in attachments and skip AI image generation when one is found
**Status:** in_progress (PR open, awaiting code review)
**Changes:**
- tasks: Added `detectEditorialImage.ts` + `createEditorialDetectionAgent.ts` for AI-based editorial photo classification
- tasks: Updated `classifyImages`, `resolveFaceGuide`, `createContentTask` to support `editorialImageUrl`
- tasks: When editorial image detected, pipeline skips image generation and uses it directly for video gen
- tasks: 11 new tests, all 347 tests pass
**PRs:**
- https://github.com/recoupable/tasks/pull/131
**Notes:** Follows same pattern as face detection (few-shot AI classification). Editorial detection only runs when `usesImageOverlay` is true.

---

## [2026-04-12] Admin — Agent Sign-Ups page (REC-56)
**Prompt:** Add admin page for tracking agent API key signups with docs and API endpoint
**Status:** in_progress (PRs open, awaiting code review)
**Changes:**
- docs: OpenAPI spec and MDX page for `GET /api/admins/agent-signups` endpoint
- api: New admin endpoint querying `account_api_keys` joined with `account_emails` filtered by `agent+` email prefix, with period filtering
- admin: New `/agent-signups` page with line chart, stats bar, data table following `/content` page pattern
**PRs:**
- https://github.com/recoupable/docs/pull/127
- https://github.com/recoupable/api/pull/428
- https://github.com/recoupable/admin/pull/26
**Notes:** All 3 PRs created and pushed. TypeScript compiles cleanly. Awaiting Code Reviewer.

---

## [2026-04-02] Content creation V2 plan + caption bug investigation
**Prompt:** Investigate caption bug (captions not based on song lyrics), then iterate on V2 modular plan for content creation pipeline
**Status:** completed
**Changes:**
- tasks: Investigated caption generation bug by pulling Trigger.dev run data via SDK, triggered reproduction run with "Safe Boy Bestie" mp3. Confirmed lyrics DO flow through transcription → caption prompt. The template's caption-guide.json style rules overpower the lyrics context, but captions are loosely connected to the song — not a hard bug, more a prompt tuning issue.
- plans: Updated `.local/plans/content-creation/plan.md` — V2 modular plan with: API endpoints nested under `/api/content/create/`, clear api vs tasks repo split, renamed "caption" → "text" (text = content + style including font), renamed "clip" → "audio", clarified face guide is artist-specific (not template-level), added text-style.json and fonts/ to template structure
**PRs:** none (plan + investigation only)
**Notes:** Key architectural decisions: (1) generate-text is inline in api (2-5s LLM call), all other primitives are Trigger.dev tasks. (2) Text primitive returns content + style (font, color, size), render just draws it. (3) Templates define scenes, artists provide faces — the two are independent. (4) createContentTask becomes an orchestrator calling individual tasks via triggerAndWait. Remaining gaps to address during implementation: artist context fetching, text object schema, template renaming, partial retry UX, docs updates.

---

## [2026-04-02] Two new skills from Alexis x Sid meeting transcript
**Prompt:** Extract domain knowledge from Alexis x Sid meeting transcript (April 1) and create skills
**Status:** completed
**Changes:**
- skills: Created `trend-to-song/SKILL.md` — pipeline for turning trending cultural moments into songs and test campaigns in 72 hours. Covers trend spotting, emotional DNA extraction, AI song generation, burner page distribution, and monitoring. Based on the Bravo reality TV example discussed in the meeting
- skills: Created `artist-growth-threshold/SKILL.md` — playbook for getting new artists past streaming milestones (1K monthly listeners for Showcase, 5K for Marquee, Popularity 50 for algorithmic boosting). Includes three paths to 1K (playlist pitching, social-to-DSP ads, organic), real cost benchmarks ($500 playlist push, $0.34 CPC, ~30% click-to-listen), content strategy (relatable first lines, mouth movement for unmutes, posting cadence), and decision framework
- skills: Updated `README.md` — added both skills to the skills table and directory structure
**PRs:** none (local skill creation)
**Notes:** Domain knowledge extracted from Alexis (Rostrum Records) sharing music marketing expertise during the Gatsby Grace growth planning discussion. Key data points are from real campaigns (playlist pitching benchmarks, Spotify Popularity mechanics, content engagement patterns). The trend-to-song workflow is novel — reverse engineering from cultural moment to song using AI generation, which Alexis described as something he "never thought in practice" would work but was excited about.

## [2026-04-01] Financial docs for fundraise deck (cap table, P&L, projections)
**Prompt:** Jules asked for cap table, historical financials, and projections for the investor deck. Build all three.
**Status:** completed
**Changes:**
- strategy: Created `cap-table.md` — current ownership (Sid 99%, Jules 1% advisor), vesting schedule, pre-money valuation benchmarks, notes on LLC→C-Corp conversion for fundraise
- strategy: Created `financials.md` — historical revenue by month (Jan 2025→Apr 2026), current expense breakdown ($11,277/mo), P&L summary showing cash-flow positive with Seeker, pipeline detail, two 12-month projection scenarios (organic: exit $68k MRR; post-raise: exit $108k MRR), use of funds breakdown for ~$1M raise
- strategy: Updated `customers.md` — corrected MRR to ~$17,995 with full breakdown (added Atlantic $1k/mo, 300 $1k/mo, 5 B2C at $99/mo), added expense summary and net income
- strategy: Updated `investor-memo.md` — corrected MRR to ~$18K, added cash-flow positive status and $0 external funding raised
**PRs:** none (local strategy docs)
**Notes:** Several items marked [?] in financials.md need Sid to fill in: exact start dates for Atlantic and 300 pilot payments, and any missing expenses. Two projection scenarios model organic growth (no raise, exit $68k MRR) and post-raise acceleration ($750K-$1.25M raise, exit $108k MRR). Key insight for deck: company reaches cash-flow positive the month Seeker closes — raise is for acceleration, not survival.

---

## [2026-04-01] Strategy docs updated from Jules x Sid transcript (April 1)
**Prompt:** Process Jules x Sid meeting transcript (April 1) and route insights to strategy docs per AGENTS.md classification rules (DECISION / IDEA / SIGNAL / CONTEXT)
**Status:** completed
**Changes:**
- strategy: Saved structured transcript to `transcripts/jules-sid-2026-04-01.md` with 11 topic sections and action items table
- strategy: `pmf-journal.md` — appended 13 classified entries: 7 IDEAS (YC for Creators model, warrants, SAFR instrument, agent org chart product, parent entity restructuring, prove-then-raise path, accelerator expansion), 2 SIGNALs (Broke Records signing AI artists, cohort hustle vs. talent divide), 4 CONTEXT entries (EA resource, NYC trip logistics, Meng situation, Jules role evolution)
- strategy: `decisions-log.md` — appended 1 DECISION: keep initial artist signings lightweight (term sheet + email, no heavy legal)
- strategy: `roster.md` — expanded Meng/Alma entry with company context and NYC plans; added accelerator cohort observations (Pear, Amanda); added "Potential Partners" section with Broke Records and Nashville musicians-fundable group
- strategy: `roster.md` — rewrote "Acquired IP Deals" section to reflect evolving YC-for-creators model with warrants, SAFR, and prove-then-raise path (tagged as IDEA, not DECISION)
- strategy: `deals/README.md` — added "Emerging Framing" section for YC model, warrants, SAFR; noted potential v0.3 evolution
- strategy: `roadmap.md` — expanded label play table with 12 specific action items (advisor agreement, Slack invite, onboarding call, Claude setup, term sheets, podcast logistics, Broke Records meeting, NYC accelerator fall program)
- strategy: `mission-and-vision.md` — added "Emerging Ideas (April 2026)" subsection flagging YC for Creators frame, parent entity restructuring, agent org chart product, Jules's potential formal role; added 3 new resonant phrases
- strategy: `customers.md` — updated sales pipeline table with Jules agreement timeline, Broke Records intro, and NYC trip details
**PRs:** none (local strategy docs)
**Notes:** Per AGENTS.md rules: nothing from this transcript was treated as a firm decision except the lightweight legal approach for initial signings. All strategic shifts (YC model, warrants, SAFR, parent entity restructuring, agent org chart) are tagged [IDEA] in pmf-journal.md and flagged for human review in static docs. The transcript is a discussion, not a commitment. Key action items with deadlines: advisor agreement (this week), Jules onboarding (Apr 2), Broke Records coffee (Apr 7-8), podcast filming (Apr 22), NYC investor meetings (Apr 23).

---

## [2026-03-31] Deals template — Platform & Shopping Agreement for acquired IP
**Prompt:** Create a deals directory with a template for signing acquired IP, based on the Gatsby Grace/Rostrum agreement. Iterated through studio model, YC model, and landed on a lightweight "platform + shopping rights" approach.
**Status:** completed
**Changes:**
- strategy: Created `.local/strategy/deals/` directory with 3 files
- strategy: `analysis-gatsby-grace.md` — extracted all key concepts, language, and structure from the Rostrum/Recoupable Gatsby Grace agreement
- strategy: `template-ip-partnership.md` — v0.2 "Platform & Shopping Agreement." Two things: (1) onboard IP to Recoupable platform for content automation, (2) Recoupable gets exclusive right to shop the IP to upstream partners. Creator keeps ownership. No management obligations. No capital. If a deal lands, Recoupable gets an override and stays as platform provider.
- strategy: `README.md` — overview of created IP (Gatsby Grace JV model) vs acquired IP (lightweight platform + shopping model)
**PRs:** none (local strategy docs)
**Notes:** Key strategic insight from iteration: signing external IP and promising to manage it creates obligations Recoupable can't fulfill at this stage (no team, no capital, no bandwidth for artist management). What Recoupable CAN do: automate content and shop the IP. v0.1 was a full 14-section label-style term sheet — too heavy. v0.2 is 8 sections, fits on 1-2 pages. The override % on upstream deals is TBD — needs to be decided per deal. Jules is the key person for actually facilitating upstream partnerships.

---
> Purpose: Handoff notes for the next dev/agent picking up work.

---

## [2026-03-31] Fix template files not loading in production (esbuild __dirname)
**Prompt:** Debug why artist-bedroom-caption template pipeline produces wrong content via Slack content agent
**Status:** completed
**Changes:**
- tasks: `src/content/loadTemplate.ts` — replaced hardcoded `__dirname`-relative path with `resolveTemplatesDir()` that tries `__dirname` first, then falls back to `process.cwd()`-relative path. esbuild changes `__dirname` to the build output directory at bundle time, so template files (style guide, caption guide, moods, movements, reference images) were silently failing to load in production. Added diagnostic logging and distinguished ENOENT from parse errors in `loadJsonFile`.
**PRs:** https://github.com/recoupable/tasks/pull/117 (merged)
**Notes:** Deployed to Trigger.dev production as version `20260331.3`. Verified fix: before = bright outdoor portrait ignoring all template rules; after = dark bedroom with purple LED, deadpan expression, proper caption style. Pre-existing SRP violation in `loadTemplate.ts` (4 exported functions) noted for follow-up PR. The `loadTemplate.ts` file also has `console.log` debug lines removed — only `logger` calls remain for Trigger.dev dashboard visibility.

---

## [2026-03-30] Marketing web: globals.css visual utilities
**Prompt:** Append noise overlay, glass card, stagger animation delays, and scan lines utilities to `globals.css` without changing existing rules
**Status:** completed
**Changes:**
- marketing/apps/web: `app/globals.css` — appended `.noise-overlay`, `.glass-card`, `.stagger-1`–`.stagger-5`, `.scan-lines` (film grain SVG, glassmorphism, CRT-style lines)
**PRs:** none
**Notes:** Use `.noise-overlay` / `.scan-lines` on a `position: relative` container so pseudo-elements layer correctly. Pair `.stagger-*` with animated elements (e.g. `fade-in-up`).

---

## [2026-03-30] Marketing: Marquee + FigureLabel components
**Prompt:** Add brutalist keyword ticker (CSS marquee, inverted fg/bg) and Linear-style FIG labels for marketing web
**Status:** completed
**Changes:**
- marketing/apps/web: `components/home/Marquee.tsx` — duplicated keyword row, `animate-marquee`, monospace `+` separators, `border-y border-(--border)`, `aria-hidden` decorative strip
- marketing/apps/web: `components/ui/FigureLabel.tsx` — `FIG {number}`, monospace 10px, `tracking-widest`, `text-(--muted-foreground)` + `opacity-50`, `cn()` for `className`
**PRs:** none
**Notes:** Not imported on `app/page.tsx` yet — add `<Marquee />` / `<FigureLabel number="0.1" />` where needed. `pnpm build` from `marketing/` passed.

---

## [2026-03-30] Marketing home: VisionOverlay + StatusBar
**Prompt:** Add two server components from moodboard — B&W HUD bounding box + terminal readout (CSS-only); thin status bar with SYS.STATUS, version, MCP tools; use #c8ff00, animate-blink on green dot, staggered keyframes like AgentChat
**Status:** completed
**Changes:**
- marketing/apps/web: `components/home/VisionOverlay.tsx` — 60vh section, gradient “photo” mood, #c8ff00 frame + L-corner brackets, SUBJECT_08X pill, artist placeholder + silhouette SVG, staggered terminal lines + deployment badge
- marketing/apps/web: `components/home/StatusBar.tsx` — max-w-7xl row, dividers, monospace 10–11px caps, ONLINE + blinking green dot, version + MCP copy; `pnpm build` from `marketing/` passed
**PRs:** none
**Notes:** Components are not wired into `app/page.tsx` yet — import when replacing hero/section placeholders.

---

## [2026-03-30] Marketing homepage + header polish
**Prompt:** Hero border under proof; proof stat text glow; module card min-height + rounded; terminal label brand color + container rounding; segment left border; Blog nav plain link when no dropdown items; mobile nav comment; nav typing for empty learn items
**Status:** completed
**Changes:**
- marketing/apps/web: `app/page.tsx` — `border-b border-[var(--border)]` on hero; proof number `drop-shadow-[0_0_30px_rgba(200,255,0,0.3)]`; modules `min-h-[320px] rounded-lg`; terminal eyebrow `text-[var(--brand)]`; segments `border-l-2 border-[var(--brand)]/30 pl-4`
- marketing/apps/web: `components/layout/NavDropdown.tsx` — if `items.length === 0`, render a single `Link` (no empty hover panel)
- marketing/apps/web: `lib/nav.ts` — explicit `NavSection` / `NavItem` types so `learn.items: []` is `readonly NavItem[]` (fixes `/learn` page + copy `never` errors vs `as const` empty tuple)
- marketing/apps/web: `components/layout/Header.tsx` — mobile nav comment aligned to desktop order
**PRs:** none
**Notes:** `Terminal.tsx` root already has `rounded-lg overflow-hidden`. `/learn` index still renders zero cards while `nav.learn.items` is empty; add fallback links if that page should stay useful.

---

## [2026-03-30] Marketing home: AgentChat + SystemDiagram mockups
**Prompt:** Add CSS-only product mockups — fake agent chat UI with staggered fade-in; three-node CONNECT/PROCESS/DEPLOY diagram with SVG arrows and brand glow
**Status:** completed
**Changes:**
- marketing/apps/web: `components/home/AgentChat.tsx` — macOS chrome, Gatsby Grace sidebar, chat bubbles + 66% progress bar, scoped keyframes + animation-delay classes (no client JS)
- marketing/apps/web: `components/home/SystemDiagram.tsx` — 01–03 nodes, horizontal SVG connectors (vertical on mobile), `var(--brand)` numbers/arrows, color-mix glow shadow
**PRs:** none
**Notes:** `pnpm build` from `marketing/` passed. Wire into `app/page.tsx` or other sections when replacing placeholders.

---

## [2026-03-30] Marketing homepage: fade-in-up, proof strip, terminal polish
**Prompt:** Append globals.css utilities (view-timeline fade-in-up, glow-brand); refine Terminal colors and keyword highlighting; soften proof strip; add fade-in-up to major homepage sections
**Status:** completed
**Changes:**
- marketing/apps/web: `app/globals.css` — `@keyframes fade-in-up`, `.fade-in-up` (animation-timeline view), `.glow-brand`
- marketing/apps/web: `components/home/Terminal.tsx` — base text `#e5e5e5`, SUCCESS `#c8ff00`, error/warning tokens `#ff9f43`, `TerminalLine` split rendering
- marketing/apps/web: `app/page.tsx` — proof section dark bg, yellow stat + `glow-brand`, brand-tint borders; `fade-in-up` on proof, modules, terminal, segments, subscribe sections
**PRs:** none
**Notes:** `pnpm build` from `marketing/` passed. Scroll-driven animation needs browsers with `animation-timeline: view()` support; others show static content.

---

## [2026-03-29] Docs overhaul — full rewrite with positioning and developer experience
**Prompt:** Rewrite Recoup docs to properly communicate what the product is, inspired by Composio's clear documentation style
**Status:** completed
**Changes:**
- docs: Rewrote `index.mdx` — positions Recoup as autonomous music infrastructure with three integration paths (API, MCP, CLI); shows "Who It's For" (Artists, Labels, Developers); uses brand positioning from `marketing/content/brand/`
- docs: Rewrote `quickstart.mdx` — starts with Spotify search (works immediately, no data needed); shows CLI and MCP setup in same page; concise and value-focused
- docs: Created `how-it-works.mdx` — explains three layers (Entry Points, Agent Layer, Context Layer); covers agents, sandboxes, data flow, and integration options; "What Makes Recoup Different" comparison table
- docs: Rewrote `cli.mdx` — workflow-oriented structure (like Composio CLI docs); content creation workflow as primary path; command summary table at end
- docs: Rewrote `mcp.mdx` — config snippets for Claude Desktop, Cursor, VS Code; full tool list (43 tools in 12 categories); usage examples; TypeScript SDK connection
- docs: Rewrote `api-reference/introduction.mdx` — developer-focused with base URL, auth, response format, rate limits, and explore cards
- docs: Created `authentication.mdx` — unified auth guide covering API keys, MCP Bearer tokens, CLI env vars, org access, and admin auth
- docs: Restructured `docs.json` navigation — "Get Started" (Welcome, Quickstart, How It Works, Auth) + "Integrate" (MCP, CLI, Content Agent); updated anchors (Dashboard, API Keys, Website)
**PRs:** Branch `feat/docs-overhaul` pushed to `recoupable/docs` — PR targets `main`
**Notes:** Voice follows `marketing/content/brand/voice.md` — specific, no-BS, show-don't-tell. Positioning aligned with `marketing/content/brand/positioning.md` — "Run your music business with agents." Pre-existing broken nav references (admins/check, admins/sandboxes, etc.) were not introduced by this change.

---

## [2026-03-29] CodeRabbit: research POST Zod, playlists popularIndie, skill + CLI fixes
**Prompt:** Zod inline validation on research POST handlers; `popularIndie` overridable in playlists handler; recoup-research SKILL angle brackets + YouTube audience vs metrics note; CLI parseInt NaN checks for web/people
**Status:** completed
**Changes:**
- api: `postResearch{Web,Deep,People,Extract,Enrich}Handler.ts` — inline Zod body schemas + unified 400 handling; `getResearchPlaylistsHandler.ts` — `popularIndie` in explicit filter branch; minimal JSDoc `@returns` / param fixes where eslint required
- skills/recoup-research: `SKILL.md` — replaced `--genre <id>` pattern; clarified `youtube_channel` applies to `metrics` only, `audience` uses `--platform youtube`
- cli: `src/commands/research.ts` — validate `--max-results` / `--num-results` after `parseInt` (radix 10)
**PRs:** none
**Notes:** Extract `full_content` is strict boolean in Zod (no string coercion). Enrich `schema` uses `z.record(z.string(), z.unknown())` (object with string keys).

---

## [2026-03-29] MCP research tools: proxy status checks and platform validation
**Prompt:** After `proxyToChartmetric`, return tool errors when `result.status !== 200`; add `VALID_PLATFORMS` where platform is interpolated; charts tool validates alphanumeric platform (no path injection)
**Status:** completed
**Changes:**
- api: `lib/mcp/tools/research/registerResearch{Artist,Metrics,Audience,Cities,Similar,Playlists,Urls,InstagramPosts,Albums,Tracks,Career,Insights,Milestones,Venues,Rank,Lookup,Track,Playlist,Curator,Discover,Genres,Festivals,Charts,Radio}Tool.ts` — status guard before `getToolResultSuccess`; playlist/track search paths check proxy status too; `VALID_PLATFORMS` on playlists, playlist info, curator; charts uses `/^[a-zA-Z0-9]+$/` on `platform`
**PRs:** none
**Notes:** Ran `eslint --fix` on touched files. `registerResearchMilestonesTool` / `registerResearchRankTool` still have pre-existing `@typescript-eslint/no-explicit-any` on parsed bodies.

---

## [2026-03-29] Rename MCP research tool registerTool() names
**Prompt:** Rename the first argument to `server.registerTool()` in all 27 research MCP tool files; update descriptions for discography/URLs/tracks overlap with other tools
**Status:** completed
**Changes:**
- api: `lib/mcp/tools/research/registerResearch*.ts` — tool IDs now use `get_*` / `lookup_*` / `discover_*` / `find_*` / `extract_*` / `enrich_*` naming; `get_artist_tracks` description notes `get_spotify_artist_top_tracks`; albums and URLs descriptions were already aligned with the requested copy
**PRs:** none
**Notes:** JSDoc lines still mention old `research_*` names in some files; update separately if docs should match registered IDs. Any clients hardcoding old tool names must switch to the new strings.

---

## [2026-03-27] Create research-artist skill
**Prompt:** Turn artist deep research prompt into a skill for the Recoupable platform, with design thinking about research method, static vs dynamic data, and downstream use
**Status:** completed
**Changes:**
- skills/research-artist: Created `SKILL.md` — multi-source research pipeline that works in sandbox (MCP tools + Perplexity deep research) and Cursor/local (WebSearch + last30days). Produces timestamped research report with career-stage assessment, fan personas, competitive white-space, revenue opportunities. Respects artist-workspace static/dynamic context separation.
- skills/research-artist/references: Created `report-template.md` (full output template with YAML frontmatter, confidence markers, 8 report sections) and `research-queries.md` (3 research strategies: Perplexity deep research, multi-query WebSearch, MCP platform APIs)
**PRs:** none — local skill creation
**Notes:** Key design decisions: (1) Uses `web_deep_research` MCP tool (Perplexity sonar-deep-research) as the ChatGPT deep research replacement in sandbox. (2) Static context (artist.md, audience.md) is created but never blindly overwritten — suggests updates for human review. (3) Dynamic context (research report) is timestamped in `research/`. (4) Optionally chains with last30days skill for Reddit/X social pulse. (5) Structured output with confidence markers ([confirmed], [estimated], [inferred], [gap]) so downstream agents know what to trust.

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

## [2026-03-29] Add 5 new research endpoints across all layers
**Prompt:** Create milestones, venues, rank, charts, and radio research endpoints across API, MCP, docs, and CLI
**Status:** completed
**Changes:**
- api: Created 5 handler files (`lib/research/getResearch{Milestones,Venues,Rank,Charts,Radio}Handler.ts`) — milestones/venues/rank use `handleArtistResearch` pattern, charts/radio use non-artist direct proxy pattern
- api: Created 5 route files (`app/api/research/{milestones,venues,rank,charts,radio}/route.ts`)
- api: Created 5 MCP tool files (`lib/mcp/tools/research/registerResearch{Milestones,Venues,Rank,Charts,Radio}Tool.ts`) and updated `index.ts` to register all 5
- docs: Added 5 paths + 5 response schemas to `openapi.json`, created 5 MDX files, updated `docs.json` navigation, added CLI docs to `cli.mdx`
- cli: Added 5 commands to `src/commands/research.ts` (milestones, venues, rank, charts, radio) with examples and help text
**PRs:** none yet — changes on existing feature branches
**Notes:** Artist-scoped endpoints (milestones, venues, rank) use `handleArtistResearch` shared handler. Non-artist endpoints (charts, radio) follow the genres/festivals pattern (auth + deductCredits + proxyToChartmetric). Charts requires `--platform` flag; radio has no params. All lint-clean.

---

## [2026-03-29] Fix response normalization in research handlers
**Prompt:** Fix array-spreading bug in all research handlers — when Chartmetric returns an array as `obj`, the spread operator produces `{ "0": item, "1": item }` instead of wrapping under a named key
**Status:** completed
**Changes:**
- api: Added `transformResponse` to 8 artist handlers via `handleArtistResearch()`: albums→`{albums}`, tracks→`{tracks}`, insights→`{insights}`, career→`{career}`, similar→`{artists, total}`, playlists→`{placements}`, cities→transforms city map to sorted array `{cities}`, urls→`{urls}`
- api: Fixed 3 non-artist handlers (genres, festivals, discover) that manually spread `result.data` — replaced with named-key wrapping: `{genres}`, `{festivals}`, `{artists}`
**PRs:** none yet
**Notes:** `handleArtistResearch` already had the `transformResponse` parameter wired up (4th arg). Each handler now passes the appropriate transform. Cities handler is the most complex — converts Chartmetric's `{ "Chicago": [{timestp, code2, listeners}] }` map into a flat sorted array. Similar handler handles both `relatedartists` (returns array) and `by-configurations` (returns `{data, total}`).

---

## [2026-03-31] Marketing — Install coreyhaines31/marketingskills

**Prompt:** Install `npx skills add coreyhaines31/marketingskills` in the marketing repo.
**Status:** completed
**Changes:**
- `marketing`: Ran `npx skills add coreyhaines31/marketingskills --yes` — installed all 34 skills from the package. Skills live in `.agents/skills/`, symlinked to `.claude/skills/` and `skills/`. `skills-lock.json` also created. Committed and pushed directly to `main`.
**PRs:** none (pushed directly to `main`)
**Notes:** Skills installed: ab-test-setup, ad-creative, ai-seo, analytics-tracking, churn-prevention, cold-email, competitor-alternatives, content-strategy, copy-editing, copywriting, customer-research, email-sequence, form-cro, free-tool-strategy, launch-strategy, lead-magnets, marketing-ideas, marketing-psychology, onboarding-cro, page-cro, paid-ads, paywall-upgrade-cro, popup-cro, pricing-strategy, product-marketing-context, programmatic-seo, referral-program, revops, sales-enablement, schema-markup, seo-audit, signup-flow-cro, site-architecture, social-content.

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

## [2026-04-12] REC-57: Admin - Content - Missing Tags
**Prompt:** Fix /content page to show Content Agent mentions from Slack thread replies, not just top-level messages
**Status:** in_progress (awaiting code review)
**Changes:**
- api: Extended `fetchBotMentions` to scan `conversations.replies` for thread mentions with cutoff filtering
- api: Added 3 new test cases for thread mention scenarios
**PRs:** https://github.com/recoupable/api/pull/429
**Notes:** PR targets `test` branch. @Code Reviewer notified for review.

---

## [2026-04-18] Add open-agents submodule
**Prompt:** Add the open-agents codebase as a submodule to the monorepo
**Status:** completed
**Changes:**
- mono: Added `open-agents` submodule pointing to `https://github.com/recoupable/open-agents`
- mono: Added `open-agents` entry to AGENTS.md submodule table (External, reference app for background coding agents on Vercel)
**PRs:** pending (branch: feat/add-open-agents-submodule)
**Notes:** Submodule pinned to current `open-agents` main HEAD.

---

## [2026-04-29] Open-agents PR #23 review comment fixes
**Prompt:** Check latest PR comments and fix them locally for open-agents PR #23
**Status:** completed
**Changes:**
- `open-agents`: Simplified bootstrap prompt for existing artists to direct agent-driven `GET /api/artists` fetch via `recoup-api` docs; removed inline artist list logic and updated tests
- `open-agents`: Removed `sessionStorage` bootstrap persistence; now passes `bootstrapPrompt` in URL query and strips it after first auto-submit
- `open-agents`: Moved `fetchAccountArtists` call from `validateCreatePersonalSession` into `createPersonalSessionHandler` to keep validation focused
**PRs:** none
**Notes:** Ran `bun test lib/sessions/build-personal-session-bootstrap-prompt.test.ts` in `open-agents/apps/web` (3 passing).

---

## [2026-04-29] Open-agents bootstrap transport simplification
**Prompt:** Replace bootstrapPrompt URL param flow with existing client→server message mechanism
**Status:** completed
**Changes:**
- `open-agents`: `useCreatePersonalSession` now sends the bootstrap user message to `/api/chat` immediately after session/chat creation, then navigates to chat
- `open-agents`: Removed `useSearchParams`/bootstrap auto-submit wiring from `session-chat-content`
- `open-agents`: Deleted unused `use-personal-session-bootstrap` hook file now that URL-param handoff is gone
**PRs:** none
**Notes:** Verified with `bun test lib/sessions/build-personal-session-bootstrap-prompt.test.ts` and `bun run typecheck` in `open-agents/apps/web`.
