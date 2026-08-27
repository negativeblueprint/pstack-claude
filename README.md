# pstack for Claude Code

A port of [pstack](https://github.com/cursor/plugins/tree/main/pstack) by [poteto](https://x.com/poteto) from Cursor to Claude Code.

pstack's premise: if you want to go fast, go deep first. It is a set of skills for writing less code of higher quality, and for parallelizing agents you can actually trust. The goal is not to maximize lines of code. It is the opposite.

This repository is not affiliated with the upstream project. All design credit is poteto's. What is here is a translation: the skills, playbooks, and principles rewritten against Claude Code's tools, subagent model, and configuration surfaces. See [PORTING.md](./PORTING.md) for what changed, what improved, and what does not survive the move.

## Install

Clone this repo, then from its parent directory:

```bash
claude
```

Inside Claude Code:

```
/plugin marketplace add ./pstack-claude
```

```
/plugin install pstack@pstack-claude
```

If the install summary says `Run /reload-plugins to activate.`, run that.

Plugin skills are namespaced. `/poteto-mode` works when the name is unambiguous; `/pstack:poteto-mode` always works.

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

44 skills. `/poteto-mode` runs most of them for you. Reach for one directly when you want just that.

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
| `/setup-pstack` | you want to change which model fills which role. |
| `/bro` | the last message was jargon. say it like a human. |

Plus `/typescript-best-practices`, and twenty `principle-*` skills that the mode's principles index navigates into.

## Principles

The principles are the load-bearing part. Each is a leaf skill that `/poteto-mode` navigates into when it applies, grouped as core, architecture, verification, delegation, and meta. They cover things like biasing to deletion, modeling the domain in a structure instead of scattered conditionals, making illegal states unrepresentable, proving work against the real artifact rather than a proxy, tracing symptoms to root causes, guarding the context window, and not blocking on the human for reversible work.

The index lives inline in [`skills/poteto-mode/SKILL.md`](./skills/poteto-mode/SKILL.md).

## Agents

`poteto-agent` runs the full style end to end. Spawn it with `subagent_type: "poteto-agent"`. It reads `poteto-mode` in full, principles index included, before doing any work. Substituting `general-purpose` skips that read and drifts.

`comment-sicko` is a read-only comment reviewer. Usually reached through `/no-comments` rather than directly.

## Automations

[`automations/benny/`](./automations/benny/) is a separate pack, not part of the installed plugin. It triages Slack issue reports and reproduces confirmed bugs. Upstream it ran on Cursor's hosted Automations product; here it runs as GitHub Actions workflows invoking Claude Code headlessly. Read [`automations/benny/FOR_AGENTS.md`](./automations/benny/FOR_AGENTS.md) to install it into a target repository.

## Provenance

Upstream is MIT licensed and that license is preserved in [LICENSE](./LICENSE). The original README is kept verbatim at [README.upstream.md](./README.upstream.md) so you can see what the Cursor version says. Fork it, improve it, make it yours.
