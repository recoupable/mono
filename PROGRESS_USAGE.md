# PROGRESS.md — Usage Guide for Coding Agents

This document explains how `PROGRESS.md` works and how coding agents should interact with it.

## What It Is

`PROGRESS.md` is the mono repo's persistent memory file. It lives in the root of the monorepo and is pushed directly to `main` (not via PR) after every agent task. It gives the next agent instant context without re-deriving it from git history or CLAUDE.md.

Inspired by OpenClaw's `MEMORY.md` pattern: a curated, human-readable file that survives context resets.

## When to Read It

**Always read `PROGRESS.md` at the start of a task.** It may contain:
- Work in progress that overlaps with the current task
- Known blockers or decisions that affect your approach
- Submodule-specific notes not captured in CLAUDE.md

```bash
cat /vercel/sandbox/mono/PROGRESS.md
```

## When to Update It

Update `PROGRESS.md` **after completing work**, before the push step. Apply these rules:

| Situation | Action |
|-----------|--------|
| Starting a new task | Add a `[ ]` item under **Active Work** |
| Completing a task | Move item to **Recent Completions** with ISO date |
| Discovering a bug or blocker | Add to **Known Issues / Blockers** |
| Making an architectural decision | Add to **Key Decisions** |
| Learning something about a submodule | Add to **Submodule Notes** |

## How the File Gets Saved

`pushAndCreatePRsViaAgent` (in the Tasks repo) checks for changes to files in the mono repo root — including `PROGRESS.md` — and pushes them directly to `main` as part of the standard post-task flow. No PR needed.

**You do not need to manually push this file.** Just edit it before the push step runs.

## Style Rules

- Keep **Active Work** short (< 10 items). Archive stale items to **Recent Completions**.
- Keep **Recent Completions** to the last ~10 entries. Drop older ones.
- **Key Decisions** are permanent unless explicitly reversed — don't remove them.
- Dates use ISO 8601: `YYYY-MM-DD`.
- One line per item. No prose paragraphs.

## Example Agent Workflow

```
1. Read PROGRESS.md
2. Do the task
3. Edit PROGRESS.md (move [ ] → [x] / add new entries)
4. Let pushAndCreatePRsViaAgent handle the commit + push to main
```
