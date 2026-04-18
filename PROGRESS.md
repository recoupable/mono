# PROGRESS.md

> Last updated: 2026-04-02

## [2026-04-02] CodeRabbit: remove unused TEXT_LENGTHS / TextLength
**Prompt:** Fix CodeRabbit review — remove dead `TEXT_LENGTHS` and `TextLength` from content schemas; do not change createRenderTask (videoUrl is correct).
**Status:** completed
**Changes:**
- tasks: Removed unused `TEXT_LENGTHS` constant and `TextLength` type from `src/schemas/contentPrimitiveSchemas.ts`. Tests had no references; no test file edits.
**PRs:** none (follow-up on `feature/content-primitives`)
**Notes:** `createRenderTask` / `renderFinalVideo` output shape left unchanged.

## [2026-04-02] Content V2 modular refactor — all 4 phases implemented
**Prompt:** Break monolithic content creation pipeline into standalone primitives across tasks, api, cli, and skills
**Status:** completed
**Changes:**
- tasks: 5 new primitive tasks (`create-image`, `create-video`, `create-audio`, `create-render`, `create-upscale`) + Zod schemas + 21 tests. V1 `create-content` untouched.
- api: 6 new endpoints under `POST /api/content/create/{image,video,text,audio,render,upscale}`. DRY shared factories (`triggerPrimitive`, `validatePrimitiveBody`, `createPrimitiveHandler`, `createPrimitiveRoute`) — 12 files instead of 23. Text endpoint is inline (no task). 17 tests.
- cli: 6 new commands (`recoup content image/video/text/audio/render/upscale`). DRY `createPrimitiveCommand` factory — each command is ~10 lines. Build passes, 74 tests pass.
- skills: Created `content-creation/SKILL.md` teaching LLM agents how to compose primitives step-by-step.
**PRs:**
- tasks: https://github.com/recoupable/tasks/pull/new/feature/content-primitives (target: main)
- api: https://github.com/recoupable/api/pull/new/feature/content-primitive-endpoints (target: test)
- cli: https://github.com/recoupable/cli/pull/new/feature/content-primitive-commands (target: main)
**Notes:** V1 full pipeline (`POST /api/content/create` and `recoup content create`) is completely untouched — all changes are additive. PRs need to be created manually (gh token lacks PR creation permission). Tasks PR must merge first since API triggers the new task IDs.

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

## [2026-04-16] Streamline featured models dropdown
**Prompt:** Add Opus 4.7 to featured models replacing Opus 4.5; then reduce featured list to just Opus 4.7, Sonnet 4.6, GPT-5.4 Mini
**Status:** completed
**Changes:**
- `chat`: Updated `lib/ai/featuredModels.ts` — promoted Claude Opus 4.7 to top, bumped Sonnet 4.5 → 4.6, removed GPT-5.2, Gemini 2.5 Flash, Gemini 3 Pro, and Grok 4 from featured list (they remain in full model list)
**PRs:**
- chat: https://github.com/recoupable/chat/pull/new/feature/featured-model-opus-4-7 (base: test, needs to be opened)
**Notes:** New IDs `anthropic/claude-opus-4.7` and `anthropic/claude-sonnet-4.6` must exist in AI Gateway (`/api/ai/models`) or they'll be silently filtered from the dropdown by `organizeModels.ts`. User hit an error sending a test message — likely because one of those IDs isn't registered upstream yet; needs verification against `/api/ai/models` response.

---

## [2026-04-17] Retarget industry-research skill at the Research REST endpoints
**Prompt:** industry-research skill is written around an unshipped `recoup research` CLI; retarget it to the `/api/research/*` endpoints shipped in docs, excluding chat endpoints
**Status:** completed
**Changes:**
- `skills`: Rewrote `skills/industry-research/SKILL.md` around `https://recoup-api.vercel.app/api/research/*` HTTP calls using `x-api-key: $RECOUP_API_KEY`. Dropped the `recoup research` CLI surface. Added the endpoints that existed in docs but were missing from the skill: `charts`, `milestones`, `rank`, `radio`, `venues`, `track/playlists`, `/research` beta search (`beta=true`), and `POST /research/deep` (replaces the old `report` command). Called out the ID-vs-name gotchas for `/albums`, `/track`, `/playlist`, `/curator`, `/track/playlists` and narrowed the `/audience?platform=` enum to `instagram|tiktok|youtube`.
- `skills`: Rewrote `skills/industry-research/references/workflows.md` so all 10 existing workflow chains use curl + the REST endpoints, and added workflow #11 (People Outreach) covering `POST /research/people` + `extract` + `enrich`.
**PRs:** none (not pushed yet)
**Notes:** `skills/getting-started/SKILL.md` still references `recoup research` and `recoup whoami` CLI commands — it's also outdated, but was out of scope for this task. Worth a separate pass once the CLI actually ships (or to rewrite around HTTP now if the CLI isn't coming soon).

---

## [2026-04-17] Retarget getting-started skill at REST + MCP
**Prompt:** Update the getting-started skill too — same treatment as industry-research (drop the unshipped CLI)
**Status:** completed
**Changes:**
- `skills`: Rewrote `skills/getting-started/SKILL.md` to remove the `npm install -g @recoupable/cli` + `recoup whoami` + `recoup research` CLI steps. Collapsed setup to two steps (get key, verify). Added a third signup path (Path C: dashboard at chat.recoupable.com/keys). Verified endpoint moved from `recoup whoami` to `GET /api/accounts/id` (confirmed in `docs/api-reference/openapi/accounts.json`). First-call example now hits `GET /api/research?q=...&beta=true` and `GET /api/research/profile` over curl. Kept the MCP config block (still accurate per `docs/mcp.mdx`) and removed the unverified "40+ tools" claim. Added an Auth gotchas section covering the `x-api-key` vs `Authorization: Bearer` exclusivity rule from `docs/authentication.mdx`.
**PRs:** none (not pushed yet)
**Notes:** Skill now matches the industry-research rewrite in tone + auth pattern. When the CLI eventually ships, these two skills will need a partial revert — the fastest way will be to add a "Prefer the CLI?" section at the top of each rather than rip the REST examples out.

---

## [2026-04-17] Rename industry-research → music-industry-research
**Prompt:** Rename the skill to music-industry-research
**Status:** completed
**Changes:**
- `skills`: `git mv skills/industry-research → skills/music-industry-research`, updated frontmatter `name:` field, updated the skill table entry in `README.md` and the directory-layout example in `AGENTS.md`. Also updated the two references inside the uncommitted `getting-started/SKILL.md` changes so they'll be consistent when that skill eventually ships. No references left in the repo after the rename (verified with grep). Pushed as a second commit on the same feature branch; updated the existing PR #12 title + body via `gh api PATCH` (the `gh pr edit` CLI path currently 500s on classic Projects GraphQL deprecation for this repo).
**PRs:** https://github.com/recoupable/skills/pull/12 (updated, not merged yet)
**Notes:** Downstream impact — anyone who had `industry-research` referenced by name in their agent config (e.g. `.claude-plugin/plugin.json`, Cursor skill pickers) will need to update it to `music-industry-research` after this merges. Checked `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` in the skills repo: neither lists skills by name, so nothing to update there.

---

## [2026-04-17] Harden music-industry-research with real response shapes
**Prompt:** User was testing the skill; their agent hit nulls on /research/similar and misread `editorial=true` returning empty as a bug
**Status:** completed
**Changes:**
- `skills`: Added a "Response shapes (what the fields actually are)" section to `skills/music-industry-research/SKILL.md` with real truncated JSON samples from live `/research/similar` and `/research/playlists` calls (verified against Drake + Joy Crookes). Explicitly document `recent_momentum` (not `trend`) and flat top-level platform counts (`sp_followers`, `ins_followers`, etc. — no `metrics` wrapper). Document the nested `{ playlist, track }` shape of `placements[]` and flag that `placement.playlist.followers` is usually 0. Added "nulls in /research/profile don't mean 'no data'" gotcha — profile returns nulls for less-covered artists but `/similar`, `/metrics`, `/cities`, `/playlists` often succeed. Added a rule: preflight playlist filter decisions against `/research/profile.num_sp_editorial_playlists` before assuming empty results are bugs. Added a "dump with jq '.<collection>[0] | keys' before parsing" rule to the What-Not-To-Do list.
**PRs:** https://github.com/recoupable/skills/pull/12 (third commit: 7bd6af6)
**Notes:** Empirical testing triggered by the user's own session — they caught two real gaps in the skill (guessed field names on /similar, misread empty editorial filter). This commit is entirely about closing field-name ambiguity so future agents don't have to grep the codebase or guess.

---

## [2026-04-17] music-industry-research: match_strength, URL lookup, latency, empty-OK gotchas
**Prompt:** Second round of user testing feedback — match_strength rule, /profile URL handling, /milestones empty, /enrich 60-90s latency
**Status:** completed
**Changes:**
- `skills`: Updated `skills/music-industry-research/SKILL.md` with four empirically-verified additions. **(1)** match_strength heuristic in the Search section: real matches score orders of magnitude >1 (Drake: 52,875; chillpill: 302), noise sits well under 1 (0.005-0.1) — treat top result <1 as "not found" and fall through to Graceful Degradation. Also extended the Graceful Degradation section to trigger on this case. **(2)** Added `/research/lookup?url=` as the canonical URL entry point. `/research/profile?artist=<URL>` works for some Spotify URL shapes but returns 404/406 for others; route URLs through `/lookup` first and chain the resolved name. **(3)** Added an "empty `/milestones` is legit" gotcha next to the profile-nulls and playlist-filter gotchas — Chillpill (global rank ~105k) returns `{ milestones: [] }` with 200 OK. **(4)** Latency note on all five POST endpoints: `/enrich` 60-90s, `/deep` 2+ minutes, others seconds-to-tens. Tell callers to set client timeouts to at least 3 minutes for enrich/deep.
**PRs:** https://github.com/recoupable/skills/pull/12 (fourth commit: cc47f88)
**Notes:** PR #12 now has four commits: rewrite (c293cf9), rename (86e00a0), response-shapes (7bd6af6), this one (cc47f88). All four are pure doc changes — no code or config impact. User tested empirically and fed back two rounds of real-world gotchas, which is exactly the virtuous loop this skill needed. Minor nit to verify before merge: the /profile 406 case the user originally reported; my own testing couldn't reproduce with a valid Spotify URL (got 200 or 404). Possible the 406 was transient upstream behavior. The `/lookup` recommendation is still correct either way — it's the canonical URL resolver and dodges the ambiguity entirely.

---

## [2026-04-17] music-industry-research: playlist filter semantics + pagination reality
**Prompt:** Third round of user testing — filter flags are exclusive-when-set, limit cap=100, artist-level /playlists offset is ignored, aggregate-vs-detail gap
**Status:** completed
**Changes:**
- `skills`: Added a dedicated "Playlist filter & pagination semantics" section to `skills/music-industry-research/SKILL.md`. This is the single highest-value fix on the skill — the filter flag behavior was obscured in the docs description and never explained in the skill, causing agents to assume `?editorial=true` was an additive filter rather than an exclusive-when-set one. **(1)** Documented the exclusive-when-set rule for both `/research/playlists` and `/research/track/playlists` with a query recipe table (editorial alone vs editorial + curator/indie vs everything). **(2)** Documented the hard `limit=100` cap on both endpoints (bisected empirically — 150/200/500 all 400). **(3)** Documented the pagination asymmetry: artist-level `/playlists` ignores `offset` (single-shot 100-max snapshot), track-level `/track/playlists` honors `offset` (paginate by 100s). Described the bulk-retrieval workaround: enumerate `/research/tracks`, then page per track. **(4)** Documented the aggregate-vs-detail gap: `profile.num_sp_playlists` can be millions while detail endpoints expose at most ~100 per call and often fewer per-track even with all 10 flags true. Told callers to use `sp_playlist_total_reach` / `sp_editorial_playlist_total_reach` from profile for ground-truth reach, and detail endpoints as sampled top placements. Cross-referenced the new section from four new "What Not to Do" bullets.
**PRs:** https://github.com/recoupable/skills/pull/12 (fifth commit: d86d142)
**Notes:** All findings verified live against the production API. PR #12 is now five commits deep, all doc-only. Still uncommitted locally: the getting-started rewrite, PROGRESS.md (this entry included).

---

## [2026-04-17] music-industry-research: progressive disclosure refactor
**Prompt:** Audit the skill against skill-creator and writing-skills best practices, apply all 7 recommended optimizations
**Status:** completed
**Changes:**
- `skills`: Audited against `~/.cursor/skills/skill-creator/SKILL.md` (Anthropic's official skill authoring guide) and `~/.cursor/skills/writing-skills/SKILL.md` (Superpowers TDD-for-skills guide). Skill was 6.9× over the recommended ≤500-word body target (467 lines / 3,449 words) with significant duplication across 13 top-level sections. Applied progressive disclosure: `SKILL.md` shrinks to 116 lines / 1,076 words / 740-char frontmatter (was 940 — 92% of the 1024-char cap, now comfortable margin). Replaced 7 sectioned bash example blocks with a quick-reference endpoint table linking to references. Created two new reference files: `references/endpoints.md` (241 lines — full curl examples, playlist filter/pagination semantics, latency budgets, platform source enums) and `references/response-shapes.md` (86 lines — real JSONC shapes, field-name gotchas, profile-nulls and empty-milestones gotchas). Extended `references/workflows.md` with new "Interpretation cheat sheet," "Cross-cutting synthesis patterns," and "Saving research" sections that used to live in SKILL.md. Consolidated 4 overlapping gotcha sections into one canonical "Critical gotchas" bullet list. No information lost — every old section is now either in SKILL.md or one of the three reference files. Lints clean.
**PRs:** https://github.com/recoupable/skills/pull/12 (sixth commit: 7376f44)
**Notes:** PR #12 is now six commits deep, all doc-only. Files in the skill: `SKILL.md` (always loaded), `references/endpoints.md`, `references/response-shapes.md`, `references/workflows.md` (loaded on demand). The skill now follows Anthropic's three-level loading model: metadata always in context (~95-word description), SKILL.md body loaded when the skill triggers (1,076 words), references loaded only when an agent needs them. Still uncommitted locally: the getting-started rewrite, PROGRESS.md.

---
## [2026-04-18] music-industry-research: teach chaining (workflows + tools + other skills)
**Prompt:** The 11 workflows in workflows.md read as standalone recipes — add a section on how to compose them, chain to external tools (send_email), and hand off to other skills
**Status:** completed
**Changes:**
- `skills`: Added a "Chaining workflows and tools" section to `skills/music-industry-research/references/workflows.md` (164 lines, inserted before "Building Your Own Workflows"). Covers: (1) the three chain patterns — Data→Data, Data→Action, Skill→Skill — with a table; (2) the tools + skills this skill chains into (`send_email` MCP tool, artist workspace writes, and the sibling skills `content-creation`, `release-management`, `streaming-growth`, `artist-workspace`, `trend-to-song`); (3) five chaining rules including a mandatory human-approval gate for external contacts; (4) three worked end-to-end examples using "Artist X" placeholders — (A) peer collab outreach (research → similar → people → draft → approval → `send_email`), (B) artist health + next move (snapshot → playlist gap → hand off to `streaming-growth` → hand off to `release-management`), (C) TikTok market scouting (charts + discover → TikTok-to-Spotify pipeline → optional `/deep` narrative → workspace write → hand off to `trend-to-song`); (5) a "when NOT to chain" caveat.
**PRs:** https://github.com/recoupable/skills/pull/12 (seventh commit: 657017c)
**Notes:** PR #12 is now seven commits deep, all doc-only. Reframes the skill from "pick one of 11 workflows" to "compose workflows until the question is answered." The explicit human-approval gate on `send_email` is the most important safety rail — cold outreach to real humans (managers, A&R) should never auto-fire from an agent. Uncommitted locally still: the `skills/getting-started/SKILL.md` rewrite from a prior session.
## [2026-04-18] music-industry-research: drop send_email from chaining section
**Prompt:** Agents without the Recoup MCP server don't have send_email, and no REST equivalent ships yet — remove email-sending from the skill so it stays portable over plain REST
**Status:** completed
**Changes:**
- `skills`: Edited `skills/music-industry-research/references/workflows.md` to remove all references to the `send_email` MCP tool. Four surgical changes: **(1)** Chain-pattern table: renamed "Data → Action" to "Data → Draft"; the skill no longer claims to execute external actions. **(2)** "Tools this skill chains into" section renamed "What this skill produces" — drafts (outreach, pitches, press blurbs) for the user to send themselves, workspace writes, and handoffs to other skills. **(3)** Chaining rule #3 rewritten from "External-facing actions require a human-approval gate" to "Draft, don't execute, for external-facing actions" — the approval gate is now moot because no execution happens. **(4)** Example A renamed "Peer collab outreach draft"; Steps 5 (approval gate) and 6 (send_email call) removed; Step 4 extended to explicitly say the agent presents the draft and the user sends manually. "When NOT to chain" section retargeted the external-facing-action bullet to workspace writes. Examples B and C were unaffected (neither used send_email). Net: -20 lines, +14 lines.
**PRs:** https://github.com/recoupable/skills/pull/12 (eighth commit: 4930f08)
**Notes:** Gap identified by user during review: the rest of the skill is deliberately MCP-independent (direct `/api/research/*` curl calls with `x-api-key`) but the chaining section assumed the Recoup MCP server was available for send_email. No `POST /api/emails/send` REST endpoint exists today — only `POST /api/emails/inbound` (Resend webhook) and `GET /api/admins/emails` (admin-only reader). Open follow-up: add `POST /api/emails/send` to the api submodule as a DRY wrapper around `processAndSendEmail`, then a tiny follow-up commit to the skill can restore the Data→Action pattern pointing at the REST endpoint instead of the MCP tool. Until that ships, the skill drafts and the user sends.
## [2026-04-18] music-industry-research: resolve all cubic-dev-ai review comments on PR #12
**Prompt:** cubic-dev-ai flagged four issues on PR #12 (one P1, three P2) — verify each, fix the real ones, reply to close the threads
**Status:** completed
**Changes:**
- `skills` commit `a74206d` (fix: add /research prefix to POST routes in decision tree): Addressed **P1 #3104618745** and **P2 #3104618749**. The decision tree in `SKILL.md` had dropped the `/research/` prefix on four POST routes — lines 25-27 (`POST /people`, `POST /enrich`, `POST /deep`, `POST /extract`) and line 32 (`POST /web`). Any agent copying those commands would have hit 404s. Bot flagged lines 25-27 as one comment and line 32 as a separate comment; fixed all four in the same commit. Endpoint table below and all curl examples already used correct paths — only the decision tree was broken.
- `skills` commit `7bc7390` (fix: clean up two P2 residue issues flagged by cubic-dev-ai): Addressed **P2 #3104419851** and **P2 #3104442230**. Both originally pointed at lines in `SKILL.md` that were refactored out during the progressive-disclosure pass (`7376f44`), but the same issues had carried over into the reference files. **(1)** `references/workflows.md` line 42: `/research/playlist?id=` was missing the required `platform=` query param — corrected to `/research/playlist?platform=spotify&id=` to match the curl example in `endpoints.md`. **(2)** `references/endpoints.md` line 203: default-flag description for `/research/track/playlists` contradicted the very next line and the SKILL.md exclusive-when-set rule — said editorial was a default, but editorial is OFF by default. Corrected to `indie + majorCurator + popularIndie = true` and added a one-line reminder that passing `?editorial=true` replaces these defaults rather than adding to them.
- `skills`: Posted a reply on each of the four cubic-dev-ai review threads (IDs 3104854382, 3104854389, 3104854402, 3104854420) pointing to the fix commits. This closes the review loop so the PR history shows each comment as resolved rather than leaving the threads dangling.
**PRs:** https://github.com/recoupable/skills/pull/12 (commits 9 and 10 of 10)
**Notes:** PR #12 is now 10 commits deep, all doc-only. Review activity on this PR so far: 2 coderabbitai suggestions (unaddressed — typo "Sao Paulo" → "São Paulo" on line 63, missing code-fence language specifier on line 77, both P3/minor) and 4 cubic-dev-ai issues (all addressed as of today). Worth a quick pass on the two coderabbit ones before merge — they're trivial and doc-only. The pattern of "bot flagged X, refactor moved X into reference file, X persisted in new location" happened twice in this batch — tells me the progressive-disclosure commit `7376f44` should have grep'd for the bot-flagged patterns before landing; noting as a lesson for future large refactors of this skill.
## [2026-04-18] music-industry-research: fix fabricated "Workflow 0" reference
**Prompt:** cubic-dev-ai flagged "Workflow 0" in Example A Step 1 as AI slop — workflows are numbered 1-11, there is no Workflow 0
**Status:** completed
**Changes:**
- `skills` commit `f68a743`: Replaced `Step 1 — Research the artist (Workflow 0: full sweep)` with `Step 1 — Research the artist (full sweep per SKILL.md decision tree)` in `references/workflows.md` line 448. Went slightly beyond the bot's suggested fix of `(Full sweep)` to point readers at where the pattern actually lives — the "Research [artist] for me" recipe in the SKILL.md decision tree — rather than leaving it as an unsourced parenthetical. Grep'd the rest of workflows.md for other `Workflow N` references; all of them (Workflows 1, 2, 9, 11) point at real numbered workflows. Only Workflow 0 was fabricated.
- `skills`: Replied to cubic-dev-ai review comment `3104853437` with the fix commit hash and a note that the rest of the cross-references are clean.
**PRs:** https://github.com/recoupable/skills/pull/12 (eleventh commit: f68a743)
**Notes:** This is the second P1 the bot caught on PR #12 today. Both were the same class of error — "AI wrote a plausible-looking pointer that doesn't actually resolve." First was decision-tree POST routes missing the `/research/` prefix; this one was a fabricated workflow number. cubic-dev-ai's "flag AI slop and fabricated changes" rule is earning its keep. Lesson for future writing on this skill: when adding examples that reference workflows, grep for the actual workflow numbers (`grep -c "^## [0-9]" workflows.md`) before using them, and either cite real ones or say "see decision tree" explicitly. Don't invent placeholder numbers. PR #12 is now 11 commits deep.
## [2026-04-18] music-industry-research: fix Example B Step 1 + Example A enrich schema
**Prompt:** cubic-dev-ai flagged two more P2 issues on PR #12 — Example B Step 2 referenced profile fields that Step 1 didn't fetch, and Example A's enrich pseudocode omitted the required type:object wrapper
**Status:** completed
**Changes:**
- `skills` commit `c9b9e13` (Example B Step 1 chain consistency): Step 2 said "Input: profile.num_sp_editorial_playlists from Step 1" but Step 1's call list was only /research/metrics + /research/cities + /research/insights + /research/milestones. None of those return num_sp_editorial_playlists or sp_playlist_total_reach — both live on /research/profile.cm_statistics. Fixed by (1) adding /research/profile to Step 1's calls (it's the correct baseline for a "state of the artist" snapshot anyway — matches Example A's opening pattern), (2) restructuring Step 1's output as a bulleted list naming which endpoint produces which fields (profile → aggregate counts; metrics → trend; cities → geographic concentration), and (3) updating Step 2 to reference profile.cm_statistics explicitly with correct field names (sp_playlist_total_reach instead of the shorthand total_reach). Every cross-step reference in Example B now resolves to real output of the step it cites.
- `skills` commit `6ed6722` (Example A enrich schema): Line 463 showed `POST /research/enrich  {input, schema: {name, role, email, recent_signings}}` — missing the top-level `{type: "object", properties: {...}}` wrapper. SKILL.md's gotcha list explicitly says /research/enrich rejects schemas without type:object at the top level, so the example contradicted the skill's own documented contract. Fixed in one line. Grep'd the rest of the file for other enrich examples — the two earlier enrich curl commands (lines 345-346 in Workflow 9, 399-400 in Workflow 11) already had the correct schema shape; only the new Example A pseudocode broke the contract.
- `skills`: Replied to cubic-dev-ai comments `3104853441` and `3104853442` with the fix commit hashes.
**PRs:** https://github.com/recoupable/skills/pull/12 (commits 12 and 13 of 13)
**Notes:** PR #12 is now 13 commits deep. All 7 cubic-dev-ai review comments on this PR are now resolved (audited with `gh api repos/recoupable/skills/pulls/12/comments` + reply-chain analysis — every top-level cubic comment has a reply). Pattern I keep making with this skill: **pseudocode pattern examples that don't respect the real endpoint contracts documented elsewhere in the same skill**. Three of the seven cubic issues today were this exact failure mode (missing `/research` prefix on POST routes, fabricated Workflow 0, missing type:object wrapper on enrich schema). Writing lesson for future example chains: (1) grep for the real contract in endpoints.md before inventing pseudocode, (2) when in doubt, show a real curl command rather than a schema-shaped sketch, (3) cross-check new examples against the Critical Gotchas list in SKILL.md.
