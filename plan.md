# Realtime Trigger.dev Run Logs — Implementation Plan

## Current State

| Layer | What exists today |
|-------|-------------------|
| **tasks** | `logger.*` calls at key milestones; no `metadata.*` or `streams.*` usage; SDK v4.3.3 |
| **api** | `GET /api/tasks/runs` polls run status (pending/complete/failed) via `runs.retrieve()`; no realtime/SSE endpoints; SDK v4.2.0 |
| **chat** | `app/tasks/[runId]/page.tsx` is a stub (`<h1>{runId}</h1>`); `useActivities` returns `[]`; no `@trigger.dev/react-hooks` package |
| **docs** | `runs.mdx` documents the existing polling endpoint |

**Key constraint:** `logger.*` output is NOT available via Trigger.dev's realtime API — it only shows in the dashboard. To surface logs to the frontend we must use `metadata` or `streams`.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  Chat (Frontend)                                                │
│                                                                 │
│  1. User triggers a task (or views a running task)              │
│  2. GET /api/tasks/runs/token?runId=xxx  →  publicAccessToken   │
│  3. useRealtimeRun(runId, { accessToken })                      │
│     └─ receives live: status, metadata.logs[], metadata.progress│
│  4. RunPage renders logs as ChainOfThought steps                │
└──────────────────────────┬──────────────────────────────────────┘
                           │ HTTPS
┌──────────────────────────▼──────────────────────────────────────┐
│  API (Backend)                                                  │
│                                                                 │
│  NEW: GET /api/tasks/runs/token                                 │
│    → auth.createPublicToken({ scopes: { read: { runs: [id] }}})│
│    → returns { token }                                          │
│                                                                 │
│  EXISTING: GET /api/tasks/runs (polling fallback - no changes)  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  Tasks (Trigger.dev Workers)                                    │
│                                                                 │
│  Replace logger.* calls with metadata.append("logs", {...})     │
│  Add metadata.set("progress", N) at key milestones              │
│  Trigger.dev automatically publishes updates to subscribers     │
└─────────────────────────────────────────────────────────────────┘
```

---

## Changes by Submodule

### 1. `tasks` — Emit realtime metadata from task runs

**Files to modify:**
- `src/tasks/customerPromptTask.ts`
- `src/tasks/sendPulsesTask.ts`
- `src/tasks/proArtistSocialProfilesScrape.ts`
- `src/tasks/runSandboxCommandTask.ts`

**What to do:**
- Import `metadata` from `@trigger.dev/sdk/v3` (already in the SDK, no new dependency)
- At each existing `logger.*` call site, add a corresponding `metadata.append()` call to publish a structured log entry:
  ```ts
  import { metadata, logger } from "@trigger.dev/sdk/v3";

  // Before (invisible to frontend):
  logger.log("Fetching task config", { externalId });

  // After (visible to frontend + still in dashboard):
  logger.log("Fetching task config", { externalId });
  metadata.append("logs", {
    level: "info",
    message: "Fetching task config",
    timestamp: Date.now(),
  });
  metadata.set("status", "Fetching task config");
  ```
- Add `metadata.set("progress", 0..1)` at key milestones for progress bar support
- Keep `logger.*` calls as-is (they still appear in the Trigger.dev dashboard)
- No new dependencies needed — `metadata` is already in `@trigger.dev/sdk`

**Structured log entry shape:**
```ts
type TaskLogEntry = {
  level: "info" | "warn" | "error";
  message: string;
  timestamp: number;
  data?: Record<string, unknown>;  // optional structured context
};
```

---

### 2. `api` — New public token endpoint

**New file:** `app/api/tasks/runs/token/route.ts`

**What to do:**
- Create `GET /api/tasks/runs/token?runId=xxx`
- Validate auth (reuse existing `validateAuthContext`)
- Validate `runId` query param
- Call `auth.createPublicToken({ scopes: { read: { runs: [runId] } }, expirationTime: "1hr" })`
- Return `{ token: string }`

**Supporting files:**
- `lib/trigger/createPublicToken.ts` — thin wrapper around `auth.createPublicToken()`
- `lib/tasks/getRunTokenHandler.ts` — request handler
- `lib/tasks/validateGetRunTokenQuery.ts` — Zod validation for query params

**No changes to existing endpoints.** The current `GET /api/tasks/runs` polling endpoint stays as a fallback.

---

### 3. `chat` — Realtime run log viewer

**New dependency:**
```bash
pnpm add @trigger.dev/react-hooks
```

**New/modified files:**

| File | Action | Purpose |
|------|--------|---------|
| `hooks/useRunToken.ts` | **New** | Fetches public access token from API via React Query |
| `hooks/useRealtimeTaskRun.ts` | **New** | Wraps `useRealtimeRun` from `@trigger.dev/react-hooks` with token fetching |
| `components/TasksPage/Run/RunPage.tsx` | **New** (replace stub) | Main run detail page with live log viewer |
| `components/TasksPage/Run/RunLogViewer.tsx` | **New** | Renders logs as ChainOfThought-style steps (modeled after EnhancedReasoning) |
| `components/TasksPage/Run/RunProgress.tsx` | **New** | Progress bar driven by `metadata.progress` |
| `components/TasksPage/Run/RunStatusBadge.tsx` | **New** | Status badge (queued/executing/completed/failed) |
| `app/tasks/[runId]/page.tsx` | **Modify** | Pass `runId` to `RunPage` component |
| `lib/tasks/getRunToken.ts` | **New** | API call to `GET /api/tasks/runs/token?runId=xxx` |

**UI approach — reuse existing patterns:**
- Use `ChainOfThought` / `ChainOfThoughtStep` components (already built for reasoning display)
- Each `metadata.logs[]` entry renders as a `ChainOfThoughtStep`
- Shimmer animation while task is executing (reuse `Shimmer` component)
- Auto-scroll to bottom as new logs arrive (reuse `use-stick-to-bottom`)
- Duration tracking (reuse `useDurationTracking`)

**Data flow:**
```
app/tasks/[runId]/page.tsx
  → RunPage({ runId })
    → useRunToken(runId)           // GET /api/tasks/runs/token
    → useRealtimeRun(runId, token) // Trigger.dev realtime subscription
    → RunStatusBadge({ status })
    → RunProgress({ progress })
    → RunLogViewer({ logs })
       → ChainOfThoughtStep per log entry
```

---

### 4. `docs` — Document the new token endpoint

**New file:** `api-reference/tasks/runs/token.mdx`
```mdx
---
title: 'Get Run Access Token'
openapi: 'GET /api/tasks/runs/token'
---
```

**Modify:** `docs.json` — add the new page to the Tasks nav group

**Modify:** `api-reference/openapi.json` — add the `GET /api/tasks/runs/token` path with:
- Query param: `runId` (required, string)
- Response 200: `{ token: string }`
- Response 400: missing runId
- Response 401: unauthorized

---

## Implementation Order

1. **tasks** — Add metadata emission (no downstream dependencies)
2. **api** — Add token endpoint (tasks changes are independent, but chat needs this)
3. **chat** — Build the UI (depends on the API token endpoint existing)
4. **docs** — Document the new endpoint (can be done in parallel with chat)

---

## What's NOT in scope

- **Streams v2 (`streams.define/pipe`)** — overkill for log entries; `metadata.append` is simpler and sufficient. Can upgrade later if we want to stream LLM output from tasks.
- **`useRealtimeTaskTrigger`** — tasks are triggered via schedules or API, not from the chat frontend directly. The chat just views runs.
- **Run history list** — this plan covers viewing a single run's logs. A run history page (list of past runs for a task) would be a separate feature.
- **WebSocket/Supabase Realtime** — Trigger.dev's built-in realtime (ElectricSQL-backed) handles the subscription; no need for a separate realtime layer.
