---
name: p-update
description: Reconcile this pstack port against upstream cursor/plugins and reinstall it. Reports what changed upstream since the last sync, ports what applies, records what was deliberately skipped, and refreshes ~/.claude. Use for /p-update, "update pstack", "sync with upstream", or "is pstack out of date".
disable-model-invocation: true
---

# Update pstack

Upstream is [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack) and it moves faster than this fork. This skill turns catching up into a bounded diff instead of an archaeology session.

`SYNC.md` at the repo root holds the state. It records the upstream SHA last reconciled against and a decisions table keyed by upstream path. Read it first and write it last. Every judgment already made about a path lives in that table, so a re-run never re-derives it.

Run from the repo root. Never edit `~/.claude/skills` directly. The repo is the source and `install.sh` is the only writer.

## Steps

### 1. Read the state

Read `SYNC.md`. Take `upstream_sha` as the baseline and the decisions table as settled judgment. A path marked `skipped` stays skipped unless its reason no longer holds.

If `SYNC.md` is absent, treat every upstream path as unreviewed and say so before doing anything else.

### 2. List what upstream changed

`WebFetch` `https://github.com/cursor/plugins/commits/main/pstack` and take every commit newer than `upstream_sha`. The GitHub REST API is not reachable for this repository from a session that has not attached it, so use the commits page rather than `api.github.com`.

Stop here and report if nothing is newer. An up-to-date fork needs no diff.

### 3. Diff the skill trees

`WebFetch` `https://github.com/cursor/plugins/tree/main/pstack/skills` for the upstream directory list. Compare against `ls skills`. Three buckets come out of it. Upstream-only paths, local-only paths, and paths present in both.

Local-only is not drift. This fork has skills upstream does not, `p-update` among them.

### 4. Fetch the sources byte-exact

`curl https://raw.githubusercontent.com/cursor/plugins/main/pstack/<path>` for each file you intend to port. Raw fetches give exact bytes. Do not port from a `WebFetch` summary, which paraphrases and will silently reword instructions.

### 5. Classify before editing

Put every changed or new path in one of three buckets, and write the verdict into the decisions table as you go.

- **ported.** Nothing upstream-specific. Copy it in.
- **translated.** It works here only after a rewrite. Name the substitution in `PORTING.md` as well.
- **skipped.** It has no meaning on this harness. Record the reason.

The translation table in `PORTING.md` is the precedent. Cursor's `Task` tool is the `Agent` tool, Cursor's model roster is Claude's, Cursor Automations are GitHub Actions. A change that depends on Cursor UI, Cursor endpoints, or a non-Claude model is a skip, not a rewrite. Inventing a Claude equivalent that does not exist is worse than skipping.

### 6. Apply

Copy or rewrite each ported path. Two things a naive copy misses.

- A new `principle-*` leaf is invisible until it is listed in `poteto-mode`'s inline Principles index, under the same grouping upstream uses.
- A new skill changes the counts in `README.md` and `PORTING.md`, which `verify-install.sh` asserts.

Check the port's own prose rules against anything you write. The `unslop` skill bans the em dash outright, and `poteto-mode` repeats the ban.

### 7. Verify

Run all three, and do not proceed while any fails.

```
./verify-install.sh
grep -rn "$(printf '\u2014')" skills --include='*.md' | wc -l
cd skills/poteto-mode/scripts && bun install && bun test
```

`verify-install.sh` proves a fresh install, an idempotent re-run, collision refusal, forced recovery, and that the documented counts match the tree. The em dash count must be 0. The suites must stay green.

### 8. Record the state

Rewrite `SYNC.md` with the new `upstream_sha`, today's date, and every decision from step 5. Overwrite the whole file so re-runs converge on the same state.

### 9. Install for the user

Run `./install.sh`. It compares content, so a second run reports everything already current and changes nothing.

If it refuses on a collision, do not reach for `--force`. A collision means a skill in `~/.claude/skills` differs from ours, which is usually the user's own work. Name the colliding skills, and let the user back them up and decide.

Tell the user to restart Claude Code afterwards. Skills are discovered at session start, so the running session keeps reading the old copies.

### 10. Report

Name what was ported, what was translated and into what, what was skipped and why, and the verification results. Link the upstream commits by SHA.
