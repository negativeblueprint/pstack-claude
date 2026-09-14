# Contributing

This repository is a port. pstack was designed and written by [poteto](https://github.com/poteto) and lives in [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack). What is here translates her work to Claude Code. That shapes every rule below.

## Report bugs upstream first

A design question about a skill belongs upstream. A porting mistake belongs here. Before filing, check whether the behaviour exists in the upstream skill. If it does, it is poteto's call, not ours.

The issue template asks you this, so answering it there is enough.

## Run the checks before opening a pull request

```
./verify-install.sh
cd skills/poteto-mode/scripts && bun install && bun test
```

`verify-install.sh` installs into a temporary directory and never touches your real `~/.claude`. It proves a fresh install, an idempotent re-run, collision refusal, forced recovery, that every skill names itself, that every `principle-*` leaf appears in `poteto-mode`'s index, and that the counts in `README.md` and `PORTING.md` match the tree. CI runs the same script, so a green local run is a green pull request.

## The skills are held to their own prose rules

`unslop` bans the em dash outright and `poteto-mode` repeats the ban. CI fails on a single one in `skills/`. Write the sentence twice rather than joining two thoughts with a dash.

The rest of `skills/unslop/SKILL.md` applies to any skill prose you write. Agent-facing text has a higher bar than human text, because an unhelpful sentence becomes an instruction.

## Adding a skill

A new skill is a directory under `skills/` holding a `SKILL.md` with `name` and `description` frontmatter, where `name` matches the directory exactly. Three things a new skill usually also needs.

- A `principle-*` leaf is invisible until it is listed in `poteto-mode`'s inline Principles index. The verifier checks this.
- The counts in `README.md` and `PORTING.md` change. The verifier checks these too.
- The skills table in `README.md` is hand-maintained. Nothing checks it.

## Syncing with upstream

Run `/p-update`. It reads `SYNC.md` for the last reconciled SHA, asks GitHub what changed since, ports what applies, and records what was skipped and why. Do not sync by hand, and do not reopen a verdict already recorded in `SYNC.md` unless its reason has stopped holding.

Not everything upstream can be ported. A change that depends on Cursor's UI, Cursor's endpoints, or a non-Claude model is a skip, and the reason goes in `SYNC.md`. Inventing a Claude equivalent that does not exist is worse than skipping.

## One thing to know before you open this repo in Claude Code on the web

`.claude/hooks/session-start.sh` runs when a remote session opens on this repository. It runs `install.sh`, which copies the skills and agents into your `~/.claude`. That is the point of the repository, but it is still a write to your personal config, so it should not surprise you. It exits immediately outside a remote session, and `install.sh` refuses to overwrite any skill of yours that differs from ours.

## Licence

Upstream is MIT and that licence is preserved in [LICENSE](./LICENSE). Contributions land under the same terms.
