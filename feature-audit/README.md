# Recoupable `chat` App — Feature Audit

Canonical feature audit for the **`chat`** submodule (chat.recoupable.com — the flagship AI agent web app). This is the single source of truth tracking every feature through a four-phase loop.

## The canonical spreadsheet

- **`features.csv`** — the canonical spreadsheet (open in any spreadsheet tool). Generated from `features.psv`.
- **`features.psv`** — pipe-delimited source (human-editable; no commas-escaping headaches). Edit this, then regenerate the CSV with `make-csv.sh`.

### Columns

| Column | Meaning |
|--------|---------|
| `ID` | Stable feature id (e.g. `CHAT-03`) |
| `DOMAIN` | Feature area |
| `FEATURE` | Short feature name |
| `USER_STORY` | As a `<role>`, I want `<goal>`, so that `<benefit>` |
| `EXPECTED_BEHAVIOR` | Concrete expected behavior, derived from the code |
| `KEY_FILES` | Primary implementing files |
| `POTENTIAL_ISSUES` | Issues spotted during the static read (Phase 1) |
| `TEST_STATUS` | Phase 2 result: `PASS` / `FAIL` / `N/A` |
| `ERRORS_FOUND` | Phase 2: concrete defects confirmed |
| `FIX_STATUS` | Phase 3: `FIXED` / `WONTFIX` / `n/a` |
| `RETEST_STATUS` | Phase 4: `PASS` after fix |

## The four-phase loop

1. **Catalog** — derive a user story + expected behavior for every feature from the code. ✅ Done (159 features, 24 domains).
2. **Test & document** — verify each user story against the implementation; record confirmed defects. Verification is code-level (static): the app requires Privy, Supabase, Stripe, Twilio, Composio and many API keys to run end-to-end, so behavior is validated by reading the implementing code, plus the objective signals available in-repo: `pnpm lint`, `tsc` typecheck, and `pnpm test` (vitest).
3. **Fix** — fix every confirmed logistical (logic) or UX error.
4. **Re-test** — re-verify each fixed story.

## Errors & fixes

See **`ERRORS.md`** for the running list of confirmed defects (Phase 2) and their fix status (Phase 3/4).

## Feature count by domain

Run `python3 -c "import csv,collections;..."` or just open the CSV. As of Phase 1: 159 features across 24 domains, largest being Tasks & Runs (18), Chat Core (17), Sidebar & Navigation (12).
