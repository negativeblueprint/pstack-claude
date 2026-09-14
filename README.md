# pstack for Claude Code

[![verify](https://github.com/negativeblueprint/pstack-claude/actions/workflows/verify.yml/badge.svg)](https://github.com/negativeblueprint/pstack-claude/actions/workflows/verify.yml)

> **This is a port, not original work.** pstack was designed and written by
> [poteto](https://github.com/poteto) and published in
> [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack).
> Every skill, playbook, and principle here is hers. This repository only
> translates them to run on Claude Code. Not affiliated with poteto or Cursor.

If you want to go fast, go deep first. That is pstack's whole argument. It is a set of skills for writing less code of higher quality, and for parallelizing agents you can actually trust. The goal is not to maximize lines of code. It is the opposite.

What changed in the port is everything that names a tool, a model, or a config path. The `Task` tool became the `Agent` tool. Cursor's model roster became Claude's. Cursor's hosted Automations became GitHub Actions. Read [PORTING.md](./PORTING.md) for the full translation table, what got better, and the one thing that genuinely does not survive the move.

If you find a bug here, check whether it exists upstream before reporting it. A porting mistake is mine. A design question is poteto's.

## Install

Clone, then run the installer for your shell.

**macOS, Linux, Git Bash**

```bash
git clone https://github.com/negativeblueprint/pstack-claude.git && cd pstack-claude && ./install.sh
```

**Windows PowerShell**

```powershell
git clone https://github.com/negativeblueprint/pstack-claude.git; cd pstack-claude; .\install.ps1
```

This copies 47 skills into `~/.claude/skills/` and 2 agents into `~/.claude/agents/`. **Restart Claude Code** afterward, since skills are discovered at session start.

The installer is safe to re-run. It compares content, so a second run reports everything already current and changes nothing. If you already have a skill with one of our names (`how`, `why`, `teach`, `swarm` and `bro` are the plausible collisions), it refuses rather than overwriting, and tells you which ones. Pass `--force` (bash) or `-Force` (PowerShell) once you've backed those up.

To install somewhere else, set `CLAUDE_HOME`.

To check the installer on your own machine before trusting it with your config, `./verify-install.sh` runs the whole thing against a temp directory and never touches `~/.claude`.

**Uninstall** by deleting what it copied.

```bash
cd pstack-claude && ls skills | xargs -I{} rm -rf ~/.claude/skills/{} && rm -f ~/.claude/agents/poteto-agent.md ~/.claude/agents/comment-sicko.md
```

### Claude Code on the web

Web sessions start from a fresh container, so nothing is in `~/.claude` yet. A
`SessionStart` hook in [`.claude/hooks/session-start.sh`](./.claude/hooks/session-start.sh)
runs the installer for you when a session opens on this repo, so the skills and
agents are there without a manual step. It also installs `shellcheck`, which is
what lints the shell in here. It does nothing outside a remote session, so your
local clone is still yours to install by hand.

### Installing as a plugin instead

The repo is also a self-contained plugin marketplace, which gets you `/pstack:` namespacing and one-command removal. It needs Claude Code's interactive plugin panel, so it works in the terminal but not in every client.

```
/plugin marketplace add ./pstack-claude
```

```
/plugin install pstack@pstack-claude
```

Pick a scope when the details view opens. If the summary says `Run /reload-plugins to activate.`, run that.

Use one method or the other, not both. Two copies of the same skill name is exactly the collision the installer is built to avoid.

## Get started

Two steps.

1. Run `/setup-pstack` and choose which models fill which roles.
2. Use `/poteto-mode` whenever you're doing anything that needs rigor.

The [guide](./docs/guide/README.md) walks through a first real task, from setup and prompting through verification and overnight runs.

Everything else is situational. `/poteto-mode` routes to the other skills as its steps need them.

## The main entry point

`/poteto-mode` reads your request, matches it to a playbook, and runs the other skills as the steps fire.

```
/poteto-mode this pr has a subtle bug where the scroll drifts every 750ms even when idle. repro
first, then fix and verify.
```

When invoked it opens a todo list whose first item is reading the inline principles index, copies the matched playbook's steps in verbatim, routes to the other skills as steps fire, and writes an unslopped reply framed for both the consumer and the maintainer.

Twenty-two playbooks ship with it, covering investigation, bug fixes, perf, hillclimbing, runtime and trace forensics, features, refactors, prototypes, visual parity, skill authoring, evals, babysitting a PR to green, shipping a stack, autonomous runs, orchestration, autopilot, session pickup, pausing safely, multi-phase plans, and worktree cleanup. They live in [`skills/poteto-mode/playbooks/`](./skills/poteto-mode/playbooks/).

`/poteto-mode` pairs well with Claude Code's built-in `/loop`, which is how you get long unattended runs without dropping rigor.

## Skills

47 skills. `/poteto-mode` runs most of them for you. Reach for one directly when you want just that.

| skill | use it when |
|---|---|
| `/poteto-mode` | default entry point for any non-trivial task. |
| `/how` | you want a walkthrough of how a subsystem works. |
| `/why` | you want to know why something was built this way, from source control, tickets, docs, chat, and observability. |
| `/recall` | you're resuming work and want your recent context on a topic rebuilt into a current-state brief. |
| `/blast-radius` | a small-looking change, and you want to know what else it could break, proven by running code. |
| `/architect` | you're about to write code crossing a function boundary and want types and module shape settled first. |
| `/arena` | you want N parallel attempts at the same thing, then the best parts of each. |
| `/swarm` | you want N parallel workers across slices or races, then one aggregated report. |
| `/interrogate` | you have a diff and want several reviewers trying to break it. |
| `/reflect` | you want the session's own transcript reviewed for lessons worth encoding. |
| `/figure-it-out` | no bundled playbook fits and you want a rigorous one designed for the task. |
| `/unslop` | any prose surface. cuts AI tells. |
| `/no-comments` | you want the narrating comments gone before review. |
| `/technical-writing` | docs, RFCs, readmes, PR descriptions, commit messages. |
| `/teach` | you want a body of work explained so a person actually understands it. |
| `/tdd` | you explicitly want a failing test first, or the bug has an obvious regression test. |
| `/show-me-your-work` | long or unattended work that needs an auditable decision trail. |
| `/create-verification-skill` | your project has no way for an agent to drive the real app and prove a change works. |
| `/maintain-verification-skill` | that skill has drifted from the app. |
| `/automate-me` | you want your own working style mined out of your history into a personal mode skill. |
| `/setup-pstack` | you want to change which model fills which role, or cap the budget they run under. |
| `/p-update` | you want to pull upstream pstack changes into this fork and reinstall. |
| `/bro` | the last message was jargon. say it like a human. |

Plus `/typescript-best-practices`, and twenty-two `principle-*` skills that the mode's principles index navigates into.

## Principles

The principles are the load-bearing part. Each is a leaf skill that `/poteto-mode` navigates into when it applies, grouped as core, architecture, verification, delegation, and meta. They cover things like biasing to deletion, modeling the domain in a structure instead of scattered conditionals, making illegal states unrepresentable, proving work against the real artifact rather than a proxy, tracing symptoms to root causes, guarding the context window, and not blocking on the human for reversible work.

The index lives inline in [`skills/poteto-mode/SKILL.md`](./skills/poteto-mode/SKILL.md).

## Agents

`poteto-agent` runs the full style end to end. Spawn it with `subagent_type: "poteto-agent"`. It reads `poteto-mode` in full, principles index included, before doing any work. Substituting `general-purpose` skips that read and drifts.

`comment-sicko` is a read-only comment reviewer. Usually reached through `/no-comments` rather than directly.

## Automations

[`automations/benny/`](./automations/benny/) is a separate pack, not part of the installed plugin. It triages Slack issue reports and reproduces confirmed bugs. Upstream it ran on Cursor's hosted Automations product; here it runs as GitHub Actions workflows invoking Claude Code headlessly. Read [`automations/benny/FOR_AGENTS.md`](./automations/benny/FOR_AGENTS.md) to install it into a target repository.

## Contributing

[CONTRIBUTING.md](./CONTRIBUTING.md) has the rules. The short version is that design questions go upstream, porting mistakes go here, `./verify-install.sh` has to pass, and `/p-update` owns syncing with upstream rather than anyone doing it by hand.

## Credits

pstack is by [poteto](https://github.com/poteto). The skills, the playbooks, the principles, the twenty-two-playbook router, the whole idea of encoding engineering judgment as leaf skills an agent navigates into, all of it is her design. Read the [original](https://github.com/cursor/plugins/tree/main/pstack) first if you want the source of the ideas.

This port exists because the ideas are good and the format is portable. Anthropic's `SKILL.md` spec is what both editors read, so most of pstack moved across unchanged. That is a nice property of an open format, and it is worth saying out loud that the port was easy because someone else did the hard part.

Upstream is MIT licensed and that license is preserved in [LICENSE](./LICENSE), with poteto's copyright first and a second line covering the port. Same terms either way. The original README is kept verbatim at [README.upstream.md](./README.upstream.md) so you can compare. Fork it, improve it, make it yours.
