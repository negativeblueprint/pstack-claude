# Porting pstack from Cursor to Claude Code

What changed, why, and what does not survive the move. Read this before trusting a skill that mentions a tool by name.

## Why the port is mostly mechanical

Cursor adopted Anthropic's `SKILL.md` format. Directory layout, frontmatter, and progressive disclosure through `references/` and `playbooks/` are the same in both. The 48 skills, 23 playbooks, and 23 principles are content, and content ported verbatim.

What did not port verbatim is everything that names a tool, a model, or a configuration path.

## Translation table

| Cursor | Claude Code | Note |
|---|---|---|
| `.cursor-plugin/plugin.json` | `.claude-plugin/plugin.json` | Plus a `marketplace.json` so the repo installs itself. |
| `skills/*/SKILL.md` | unchanged | Same format. |
| `disable-model-invocation: true` | unchanged | Supported natively. |
| `mode: true`, `icon`, `color`, `reminder` | dropped | No equivalent fields. See "Sticky mode" below. |
| `Task` tool | `Agent` tool | Same shape: `subagent_type`, `model`, `run_in_background`. |
| `subagent_type: generalPurpose` | `subagent_type: general-purpose` | |
| `AskQuestion` | `AskUserQuestion` | |
| `readonly: true` / agent mode | dropped | Claude Code subagents inherit the parent's tools, MCP servers included. There is no readonly tier stripping MCP, so the workarounds upstream needed for it are gone. To restrict a delegate, give its agent definition a `tools` list. |
| `environment: "cloud"` | `isolation: "remote"` | Availability is gated per account. |
| (no equivalent) | `isolation: "worktree"` | New. See "What got better". |
| `is_background: true` on an agent | `run_in_background` on the call | Moved from the definition to the call site. |
| `~/.cursor/rules/pstack-models.mdc` (`alwaysApply: true`) | `~/.claude/pstack/models.md` | Read on demand instead of always-applied. Claude Code's always-applied surface is `~/.claude/CLAUDE.md`, and a full role table there would cost context every session for a file only the delegating skills read. |
| `inherit-parent` / `auto` | `inherit` | Two aliases collapse to one. |
| `~/.cursor/projects/<slug>/agent-transcripts` | `~/.claude/projects/<slug>/*.jsonl` | Claude Code keeps the leading path separator as a dash; Cursor stripped it. `worktree-audit.sh` updated. |
| Cursor built-in `create-skill` | `anthropic-skills:skill-creator` | |
| `deslop` from `cursor-team-kit` | `/simplify` | Claude Code built-in. |
| `control-ui` / `control-cli` from `cursor-team-kit` | `/run` plus the Browser tools | `/run` launches and drives the app; the Browser tools cover web and Electron. |
| Cursor's `/loop` | Claude Code's `/loop` | Same name, same job. |
| Cursor's built-in `babysit` skill | (none) | The upstream note telling you not to route there was dropped; there is nothing to collide with. |
| Bugbot | kept, and generalized | Bugbot is a GitHub app, not an editor feature, so it still works on any repo. `watch-pr` now also detects Claude review bots. Prose about triaging it now reads as "an automated reviewer", covering `/code-review` and `/security-review` too. |
| Cursor Automations product | GitHub Actions + headless Claude Code | See "Benny". |

## Models: the real fidelity gap

This is the one place the port loses something that cannot be bought back.

pstack's review panels (`interrogate`, `arena`, `architect`, `how` critics, `reflect`) are built on **cross-vendor model diversity**. The upstream default panel is fable, sol, grok, and opus 5. The design says outright that the adversarial signal comes from model diversity rather than assigned personas, and that agreement across models is high-confidence signal.

Claude Code's `Agent` tool takes `opus`, `sonnet`, `haiku`, `fable`, a full Claude model ID, or `inherit`. Every reviewer is a Claude model. Blind spots correlate more than the upstream design assumes, so agreement is weaker evidence than it was.

Two changes follow:

1. **Panels are three wide, not four.** Default `fable, opus, sonnet`. `haiku` is available as a cheap fourth lens where breadth beats depth (swarm workers, `how` explorers), but it is not a good reviewer for contested design work. Widening a panel with more Claude models mostly buys correlated agreement.
2. **Reviewers get an explicit lens.** `interrogate` now assigns each reviewer an angle (adversarial correctness, design and blast radius, the maintainer's read) on top of its distinct model. This is a deliberate reversal of the upstream "no assigned personas" rule, and it is a compensation, not an improvement. The lens directs where to look, never what to conclude.

Role mapping used throughout:

| Upstream role | Upstream model | Here |
|---|---|---|
| fast mechanical code | `grok-4.6-fast-xhigh` | `sonnet` |
| precisely specified execution | `gpt-5.6-sol-max` | `opus` |
| prose and judgment | `claude-fable-5-thinking-max` | `fable` |
| panel fourth seat | `claude-opus-5-thinking-xhigh` | dropped, `haiku` optional |

Treat unanimous panel approval on a subtle correctness question as a prompt to go get runtime evidence, not as a verdict. That was good advice upstream. It is load-bearing here.

## What got better

**Worktree isolation is now enforced, not just prescribed.** pstack has a whole principle about this, `principle-separate-before-serializing-shared-state`, and playbook prose telling you one writer per worktree. Claude Code's `Agent` tool takes `isolation: "worktree"`, which gives the subagent its own git worktree and cleans it up if unchanged. Every writing delegate now gets it. The principle is the same; the enforcement is real instead of advisory.

**Subagents can be resumed.** `SendMessage` continues a named agent with its context intact, and `ListAgents` finds it. Upstream had to warn that interrupt-chained resumes silently drop directives and to fire a fresh subagent instead. That warning is narrowed here to the case it actually covers: scope drift.

**MCP access no longer forces a mode choice.** Several upstream skills carry careful instructions to avoid readonly mode because it strips MCP servers, which would disable MCP-backed investigators outright. Claude Code subagents inherit MCP servers, so that whole consideration is gone.

**The model config is cheaper.** Read on demand rather than injected into every session.

## Sticky mode

Upstream `poteto-mode` uses `mode: true` and a per-turn `reminder` string to stay on across turns. Claude Code has neither field.

The behavior is preserved in prose: a "Staying in the mode" section at the top of the skill, holding the same test the reminder encoded. A loaded skill's content stays in context across turns, so this works, but it is a weaker mechanism than a harness-enforced flag. If you want it enforced, a `UserPromptSubmit` hook is the Claude Code way to do it; that is not shipped here.

## Dropped

**`make-bot-ui`.** Built entirely on Cursor primitives with no Claude Code analogue: webhook Routines, the `update_state` tool, `SendToUser` secret-request cards, and `api2.cursor.sh` webhook URLs. Nothing to translate it into. Removed rather than shipped as a skill referencing tools that do not exist.

That is the only skill dropped. The other 44, all 23 playbooks, all 23 principles, and the guide carried over.

## Benny

[`automations/benny/`](./automations/benny/) triages Slack issue reports and reproduces confirmed bugs. Upstream it runs as two Cursor Automations, created through a reviewed Automations editor.

Claude Code has no hosted trigger product. Benny's two runners become two GitHub Actions workflows invoking Claude Code headlessly, woken by a `repository_dispatch` from a Slack bridge that forwards the channel id, root `thread_ts`, and message text. The `thread_ts` is the correlation key for thread safety and must survive the bridge. A degraded form triggers on GitHub issue events instead, with no Slack at all.

Sections 1 through 6 of `setup-benny` are unchanged. Only section 7, the runner wiring, was rewritten.

Two hazards worth naming, because a hosted product handled them and a workflow does not. Secrets belong in GitHub Actions secrets, never in workflow files or prompts. And Slack reports, issue bodies, and PR comments are data written by other people: a runner with repository write access that treats them as instructions is a prompt-injection hole. Both prompts say so explicitly.


## Deliberately not ported

`make-bot-ui` is upstream and is not here. It builds a page that wakes a Grok Bot through a Cursor webhook, and every mechanism it names is Cursor's. The `update_state` routine target, the `SendToUser` secret-request card, the `api2.cursor.sh/automations/webhook` endpoint, and the `[routine]` wake. Claude Code has no equivalent for any of them, so a translation would be an invention wearing a port's name.

`/setup-pstack`'s budget question did port, but not as written. Upstream sets a reasoning-effort token inside the model slug. The `Agent` tool takes no effort argument, so the same four labels became a ceiling on the ladder `fable` > `opus` > `sonnet` > `haiku`.

`SYNC.md` records these and the rest of the reconciliation, and `/p-update` maintains it.

## Not verified

The skills are ported and internally consistent, but they have not been run end to end against a real task.

The TypeScript under `skills/poteto-mode/scripts/` (`orch`, `watch-pr`) was restored from upstream and edited minimally. Its suites do run clean here. `bun install && bun test` from `skills/poteto-mode/scripts/` gives 52 passing tests and 206 assertions across four files, on bun 1.3.11.
