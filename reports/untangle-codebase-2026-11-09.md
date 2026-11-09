# Recoup monorepo untangle — 2026-11-09

## Result

Eight owning-repository refactors are implemented and independently reviewed on
feature branches. Seven PRs are open for review; Open-agents remains draft because
its complete local CI has reproduced pre-existing failures. **Nothing is merged
or deployed to production.** Remote checks and preview builds run on the linked PRs;
local verification below is not a claim that every remote check is green.

Applied the user-selected [untangle-codebase workflow](https://github.com/caldoai/skills/blob/f3cf47774975a7d9fca45730babf4ff7ad765ada/skills/untangle-codebase/SKILL.md):
inventory/import analysis and Git evidence, a pre-edit decision log, root-cause
refactors, behavioral checks, then independent follow-up review. No broad comment
or test-pruning add-on was selected. Tests were retained, adapted to moved imports,
or added; only the dedicated tests for a proven superseded, unreachable image
adapter were removed with that adapter.

## Review queue

| Repository | PR | Change |
| --- | --- | --- |
| api | [Review](https://github.com/recoupable/api/pull/1237) | Separate public Context schema from orchestration; share title/abort policies; retire unreachable copies. |
| chat | [Review](https://github.com/recoupable/app/pull/2395) | Own workspace, connector, membership and catalog-result contracts in domain modules. |
| marketing | [Review](https://github.com/recoupable/marketing/pull/246) | Own valuation contracts in valuation; bind OpenAPI descriptions to named tools. |
| admin | [Review](https://github.com/recoupable/admin/pull/29) | One authenticated JSON transport beneath 11 resource-specific adapters. |
| cli | [Review](https://github.com/recoupable/cli/pull/33) | One request/error transport beneath existing GET and POST interfaces. |
| docs | [Review](https://github.com/recoupable/docs/pull/37) | Separate pure OpenAPI interpretation from filesystem/caching. |
| skills | [Review](https://github.com/recoupable/skills/pull/271) | One explicit resolver inventory and table-token grammar for both gates. |
| open-agents | [Draft](https://github.com/recoupable/open-agents/pull/48) | Pure usage/provider policies, shared USD formatting, removal of unreachable UI. |

## Decisions and evidence

### Stable contracts own themselves

- API's Context request schema previously lived with execution orchestration. The
  contract catalog and validators loaded that execution graph just to read a
  schema. The schema now has one domain owner; source and exported request JSON
  are byte-identical. A regression test failed on the old dependency boundary
  and passes after extraction.
- Chat's lifecycle, connector, organization-membership and catalog-result shapes
  were owned by hooks or components that consumed them. Moving types removes
  backward dependencies and type-only cycles without changing emitted runtime JS.
- Marketing's valuation types similarly move out of components; named tool
  definitions remove array-position coupling from OpenAPI generation.
- Docs' reference resolution, example generation and curl construction no longer
  import the filesystem reader. Their function bodies remain unchanged.

### Repeated policies change in one place

- API chat-title generators and AbortError predicates had identical implementations.
  One canonical implementation now serves their distinct callers. Cancellation
  consequences remain owned by those callers.
- Admin's 11 adapters and CLI's GET/POST paths repeated transport behavior. Shared
  transport preserves URLs, bodies, response projections, empty-query shortcuts,
  token headers and historical error precedence. No retry framework was added.
- Open-agents workflow and agent usage accounting duplicated all nested AI SDK
  usage fields. A pure package subpath owns accumulation without pulling in agent
  execution. Provider parsing/order lives below SVG presentation, while grouping
  and rendering stay with consumers. Existing USD precision behavior is shared.
- Skills' two routing gates duplicated slug parsing and inventory. Commit
  `faa5469` had to change both when user-named skills were added. The extracted
  module preserves table-row-only parsing, dotted names and explicit path inputs.

### Remove verified surplus, not heuristic guesses

- API's duplicate billing validator had no importers. The old Higgsfield image
  adapter was replaced by active AI/Fal image generation; repository reference
  scans and replacement history proved it and its exclusive tests unreachable.
- Open-agents' 749-line old usage section and unused badge had no live consumers.
  The old section was still co-edited with the real UI during model API changes.
  A one-caller identity wrapper and a redundant identical formatting branch also
  disappear. No active lifecycle or authorization helper was removed.

## Verification

| Repository | Local result |
| --- | --- |
| API | 2,334 tests passed before retiring the unused adapter; 239 active Sites/Higgsfield tests passed afterward. Lint and response-contract typecheck pass. Full project typecheck has exactly the same 214 diagnostics as pristine main. |
| Chat | 56 targeted existing tests, typecheck and instruction-path check pass; 18/18 changed runtime modules emit identical JS. |
| Marketing | 40 tests, typecheck and production build pass; 5/5 valuation runtime modules unchanged; new registry-order regression fails old code and passes new code. |
| Admin | 25 actual-adapter tests pass on old and new implementations; typecheck and production build pass. Test harness uses Node 24. |
| CLI | 94 tests / 14 files and build pass; independent reviewer repeated 17 transport tests. |
| Docs | 154 tests / 46 files, typecheck, lint and build pass; 538 pages generated; independent reviewer repeated 32 migration/playground tests. |
| Skills | Five required gates pass: 129 skills, 144 copies in 51 vendored groups, 8 manifests. Eight focused routing tests, 116 catalog tests, 3 ownership tests, 15 package tests and 1 Claude package test pass. Distribution packages build. |
| Open-agents | Lint/format and all 4 package typechecks pass; 558 tests pass. Eight failures across five files reproduce on pristine main; missing `db:check` also predates this work. Draft retained. |

Counts are per command and may overlap; do not sum them into a fabricated suite
total. Existing skipped API tests remain skipped. Python 3.13 was used for Skills'
broader suite because the host's default 3.9 lacks a method already used by an
existing fixture. API dependencies were installed from the lockfile in isolation;
a broken older shared installation was not treated as a source regression.

Open-agents baseline failures: sandbox mock missing `refreshBaseSnapshot` (four),
file-content sandbox lifecycle update, post-finish usage timing, chat auto-commit,
and archive snapshot refresh. Root CI also calls absent `apps/web` `db:check`.
Those tests were not weakened or deleted. This pass does not claim full CI green.

Independent reviews found no actionable regressions in the changed areas.
Verification used local tests, synthetic fetches/build configuration and source
comparison; authenticated production workflows were not exercised.

## Coverage and retained boundaries

The current Mono main has 15 submodules. Its old Blog checkout is retired and was
preserved. Audits used fresh main snapshots for changed repositories instead of
resetting older local checkouts. Docs' rewritten remote history was isolated;
no attempt was made to merge it into the preserved historical checkout.

- **API, Chat, Marketing, Admin, CLI, Docs, Open-agents, Skills:** structural
  inventories and focused semantic review produced the accepted changes above.
  Large-file/import graphs are evidence for investigation, not proof of runtime
  reachability or an exhaustive absence of technical debt.
- **Tasks/GTM:** deprecated/retired ownership is respected. Different clip-selection
  fallbacks and runner credentials remain; no competing legacy framework added.
- **Database:** forward-only migrations and one-time repair history are not
  deduplicated or rewritten. No schema change or live database operation.
- **Plugins/Skills distribution:** different harness formats and self-contained
  vendored copies are intentional. No cross-skill imports or speculative manifest
  generator. Existing package/manifest checks preserve the boundary.
- **Private operating/project workspaces:** ownership and inventory inspected;
  confidential records, client source subtrees, operational evidence, persona
  engines and historical scripts are not folded into public platform refactors.
  This is not a semantic audit of every private client repository.
- **Mono sync:** repository-local trusted receiver and signed proposal checks are
  retained; no central cross-repository import, allowlist expansion or auto-merge
  policy change.
- **Required special cases:** durable workflow steps, provider polls/retries,
  ownership checks, legacy media read compatibility, session identity fencing and
  transport-specific auth/error behavior remain where requirements justify them.

Unproven static dead-code candidates, especially legacy Chat helpers, were not
blanket-deleted. A subsequent retirement needs exact entrypoint/dynamic-reference
checks and behavior coverage; a zero-inbound heuristic alone is insufficient.
This report documents completed accepted refactors, not a promise that every
possible structural improvement across all repositories has been exhausted.

## Landing order and continuation

Review and merge each owning-repository PR only with the required explicit user
approval. There are no cross-repository wire-format changes requiring lockstep
release. Resolve Open-agents' baseline CI separately before declaring its full
CI green. After child PRs merge, update Mono gitlinks to the resulting main commits
through a separate Mono PR; Business/Skills coordinator ownership remains intact.
This report PR deliberately does not point Mono at unmerged feature commits.

Full local pre-edit decisions, import inventories, baseline comparisons and test
logs are preserved under the ignored `.worktrees/untangle-2026-11-09/` task evidence
directory. Each changed repository remains in its own clean linked worktree.
