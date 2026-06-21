# Errors Log — `chat` App Feature Audit

Phase 2 (test every user story) verified each statically-flagged concern against the
real implementation. Phase 3 fixed the safe, self-contained logistical/UX defects.
Phase 4 re-verified (typecheck of changed files + full unit suite + code re-read).

**Objective signals (whole app):**
- `pnpm test` (vitest): **59/59 pass** (before and after fixes).
- `tsc --noEmit` on changed files: **clean**. (Whole-project `tsc` shows only
  pre-existing false positives: a Next-generated `*.png` module decl and test-file
  `UIMessage.content` typing — neither is a runtime/user defect.)
- `pnpm build`: **compiles successfully**; only fails at the "collect page data"
  stage because runtime secrets (Supabase / Arweave / Twilio) are absent in the audit
  sandbox — environmental, not a code defect.
- Note: `pnpm lint` is broken under Next 16 (`next lint` was removed upstream). Tooling
  regression, not a user feature; flagged for the team.

## Summary

| Result | Count |
|--------|------:|
| Features cataloged | 159 |
| Statically flagged for review | 57 |
| Confirmed defects **fixed this pass** | 13 |
| Confirmed defects **deferred** (architectural / product / risk) | 21 |
| **False positives** (code already handles it) | 23 |

## Fixed this pass (Phase 3) — all re-verified PASS

| ID | Defect | Fix |
|----|--------|-----|
| CHAT-08 | Clipboard copy failure swallowed (console only) | Toast error on failure (`CopyAction.tsx`) |
| CHAT-15 | Reasoning panel collapsed instantly on stream end | 1.2s delayed auto-collapse with cleanup (`useAutoCollapse.ts`) |
| NAV-07 | Rename modal had no length feedback despite 50-char cap | `maxLength={50}` + live `n/50` counter (`RenameModal.tsx`) |
| AUTH-02 | Access token shown in full plaintext | Masked by default + Reveal/Hide toggle; copy still copies full token (`app/access/page.tsx`) |
| KEY-01 | Unclear the full API key is shown only once | Reworded modal description (`ApiKeyModal.tsx`) |
| KEY-02 | Ambiguous key-list mask | Clear "hidden — shown only at creation" + aria-label (`ApiKeyList.tsx`) |
| KEY-03 | Delete API key fired instantly (destructive, no confirm) | Inline two-step Confirm/Cancel (`ApiKeyList.tsx`) |
| AGT-10 | Invalid/duplicate share emails rejected silently | Toast feedback for both (`EmailShareInput.tsx`) |
| AGT-11 | Removing a shared email had no confirmation | Inline confirm (check/cancel) before removal (`ExistingSharedEmailsList.tsx`) |
| CAT-03 | ISRC search accepted any string | Format validation + toast; normalizes hyphens/case (`useSearchIsrc.ts`) |
| CAT-07 | Hide-incomplete toggle didn't define "complete" | Tooltip listing required fields (`HideMissingItemsToggle.tsx`) |
| TASK-03 | Create-Task only errored via toast after click | Button disabled + helper text when no artist (`CreateTaskButton.tsx`) |
| UI-05 | PWA close-listener leaked (no cleanup, anon fn) | Named handler + `removeEventListener` cleanup (`usePWADownload.tsx`) |

## Deferred (confirmed, but out of safe one-pass scope)

These are real but need either an architectural change, a product/backend decision, or
runtime reproduction that the static sandbox can't provide. Each is recorded in the
spreadsheet with `FIX_STATUS = DEFERRED` and a reason.

- **Architectural:** SESS-01 (transport type-safety), SESS-02 (persist indicator),
  CHAT-01 / CHAT-03 (provisioning/stream error toasts).
- **Product/backend decision:** CONN-02 (connector whitelist vs displayed metadata),
  SMS-03 (SMS AI reply not yet wired), FILE-04 (file editing not wired).
- **Risk / needs runtime repro:** NAV-06 (shift-select across virtualized scroll),
  NAV-11 (org-switch refetch / query key), AGT-05 (shared-email race), ART-04 (URL
  validation schema).
- **Minor polish:** CHAT-06, CHAT-07, CHAT-11, NAV-08, AGT-02, AGT-12, CAT-05,
  FAN-04, POST-04, FARC-01.

## False positives (no defect — code already handles it)

CHAT-05, CHAT-09, CHAT-10, CHAT-12, CHAT-13, CHAT-17, NAV-01, NAV-02, NAV-03, NAV-04,
NAV-05, NAV-09, ACCT-07, ORG-06, CAT-01, FAN-01, FAN-05, FAN-06, SBX-05, CRED-01,
PULSE-02, DOC-01, DOC-02. See each row's `ERRORS_FOUND` in `features.csv` for the
specific evidence.
