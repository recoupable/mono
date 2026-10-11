# Errors Log — `chat` App Feature Audit

Phase 2 (test every user story) verified each statically-flagged concern against the
real implementation. Phase 3 fixed the confirmed logistical/UX defects (two rounds).
Phase 4 re-verified (typecheck of changed files + full unit suite + code re-read).

**Objective signals (whole app):**
- `pnpm test` (vitest): **59/59 pass** (before and after all fixes).
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
| Confirmed defects **fixed** | **22** |
| **False positives / by-design** (no defect) | 33 |
| Open **feature gaps** (not logistical/UX errors) | 2 |

Every confirmed logistical/UX error has been fixed. The only two remaining `FAIL`
rows are **missing features**, not errors (see below).

## Fixed (Phase 3) — all re-verified PASS

Round 1 (13):

| ID | Defect | Fix |
|----|--------|-----|
| CHAT-08 | Clipboard copy failure swallowed (console only) | Toast error on failure (`CopyAction.tsx`) |
| CHAT-15 | Reasoning panel collapsed instantly on stream end | 1.2s delayed auto-collapse with cleanup (`useAutoCollapse.ts`) |
| NAV-07 | Rename modal had no length feedback despite 50-char cap | `maxLength={50}` + live counter (`RenameModal.tsx`) |
| AUTH-02 | Access token shown in full plaintext | Masked by default + Reveal/Hide; copy still copies full token (`app/access/page.tsx`) |
| KEY-01 | Unclear the full API key is shown only once | Reworded modal description (`ApiKeyModal.tsx`) |
| KEY-02 | Ambiguous key-list mask | Clear "hidden — shown only at creation" + aria-label (`ApiKeyList.tsx`) |
| KEY-03 | Delete API key fired instantly (no confirm) | Inline Confirm/Cancel (`ApiKeyList.tsx`) |
| AGT-10 | Invalid/duplicate share emails rejected silently | Toast feedback for both (`EmailShareInput.tsx`) |
| AGT-11 | Removing a shared email had no confirmation | Inline confirm before removal (`ExistingSharedEmailsList.tsx`) |
| CAT-03 | ISRC search accepted any string | Format validation + toast; normalizes hyphens/case (`useSearchIsrc.ts`) |
| CAT-07 | Hide-incomplete toggle didn't define "complete" | Tooltip listing required fields (`HideMissingItemsToggle.tsx`) |
| TASK-03 | Create-Task only errored via toast after click | Button disabled + helper text when no artist (`CreateTaskButton.tsx`) |
| UI-05 | PWA close-listener leaked (no cleanup, anon fn) | Named handler + cleanup (`usePWADownload.tsx`) |

Round 2 (9):

| ID | Defect | Fix |
|----|--------|-----|
| CHAT-06 | Pending uploads not visually distinct in preview | Dim + "Uploading…" label (`preview-attachment.tsx`) |
| CHAT-07 | Message editor had no saving indicator | Inline "Saving…" using existing in-flight signal (`message-editor.tsx`) |
| NAV-08 | Bulk-delete error didn't say which chats failed | Names failed chats + reason (`DeleteConfirmationModal.tsx`) |
| AGT-12 | `fetchAgentTemplates` gave no error context | Clear network/HTTP error messages (`fetchAgentTemplates.ts`) |
| AGT-02 | Action tags filtered from UI with no rationale | Explanatory comment (`useAgentData.ts`) |
| CAT-05 | Artist filter silently fell back to full catalog | One-time toast on fallback (`useArtistCatalogSongs.ts`) |
| FAN-04 | Fan info hidden on touch devices | Always-visible caption on small screens (`FanAvatar.tsx`) |
| FARC-01 | BaseBuilder address hardcoded | Env-configurable with same default (`farcaster.json/route.ts`) |
| ART-04 | Artist URL fields had no format validation | Lenient http(s) URI validation (`lib/utils/setting.tsx`) |

## Open feature gaps (FAIL, but not logistical/UX errors)

These two are **unbuilt features**, not defects in existing behavior — fixing them
means building new functionality, which is outside an audit/fix pass. Recorded in the
spreadsheet with `FIX_STATUS = FEATURE`.

- **FILE-04** — the Files preview is intentionally read-only; inline file editing/save
  is not implemented.
- **SMS-03** — inbound SMS currently replies with a static fallback; the AI reply
  pipeline is not yet wired.

## False positives / by-design (no defect — code already handles it)

Verified against code; each row's `ERRORS_FOUND` in `features.csv` has the specific
evidence. Includes: CHAT-01, CHAT-03, CHAT-05, CHAT-09, CHAT-10, CHAT-11, CHAT-12,
CHAT-13, CHAT-17, SESS-01, SESS-02, NAV-01, NAV-02, NAV-03, NAV-04, NAV-05, NAV-06,
NAV-09, NAV-11, ACCT-07, ORG-06, AGT-05, CAT-01, CONN-02, CRED-01, FAN-01, FAN-05,
FAN-06, POST-04, SBX-05, PULSE-02, DOC-01, DOC-02.
