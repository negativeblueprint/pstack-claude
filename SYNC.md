# Upstream sync state

Upstream is [`cursor/plugins/pstack`](https://github.com/cursor/plugins/tree/main/pstack). This file is the fork's memory of what has been reconciled. `/p-update` reads it first and rewrites it last.

```
upstream_sha: 5bf2b15
upstream_date: 2026-09-13
reconciled_on: 2026-09-15
```

`5bf2b15` is "feat(pstack): setup-pstack budget ask (max/xhigh/high/medium) (#366)", the newest commit touching `pstack/` at the time of writing.

## Decisions

Keyed by upstream path or commit. A verdict here is settled. Revisit one only when its reason stops holding.

| Upstream | Verdict | Notes |
|---|---|---|
| `skills/principle-attack-the-premise` | ported | Verbatim. No upstream-specific content, and all four cross-links resolve in this tree. Indexed under Core in `poteto-mode`, between Redesign from First Principles and Subtract Before You Add, matching upstream's order. |
| `skills/principle-test-behavior-not-implementation` | ported | Verbatim. Indexed under Verification, after Sequence Work into Verifiable Units. |
| `5bf2b15` setup-pstack budget ask | translated | Upstream tunes a reasoning-effort token inside the model slug (`claude-fable-5-1-thinking-max`). The `Agent` tool takes no effort argument, so the budget became a ceiling on the ladder `fable` > `opus` > `sonnet` > `haiku`. Same four labels, same idempotent config file. |
| `d7cde2b` prose pass on em dashes and semicolons | ported in spirit | This fork ran its own pass rather than taking the diff, since the prose had already diverged. 17 em dashes removed across five files. |
| `73f8be4` disable model invocation for five skills | translated | Applied to `how` and `why`, which spawn subagent panels and should not fire unasked. Declined for `unslop`, whose own description reads "must always apply", and for `typescript-best-practices`, a passive reference that costs little when it loads. The fifth upstream file was `make-bot-ui`, already skipped. |
| `f8abedd` every claim carries its evidence or its label | ported | One bullet added to `poteto-mode`'s Writing the reply section, verbatim. |
| `f5bdd68` operator-neutral pronouns, in-chat status tick | ported | Twelve gendered pronouns swept from four playbooks and the index, using upstream's "the operator" rather than a different neutral form. The tick prompt now posts to chat. Zero gendered pronouns remain in `skills/`. |
| `23a56e2` forge-neutral playbooks, Fable 5.1 defaults | translated | The 24-file Graphite-to-`gh` rewrite is declined. It rewrites stack mechanics this fork cannot test, and a broken shipping playbook is worse than an honest dependency. Instead `shipping.md` and `autopilot-stack.md` now open with an explicit "Requires Graphite" precondition and name the fallback. The Fable 5.1 slug bump does not apply, because this fork configures models by alias (`fable`), which already resolves to the current model. |
| `skills/make-bot-ui` | skipped | Built on Cursor's `update_state` routine target, `SendToUser` secret-request cards, `api2.cursor.sh/automations/webhook`, and Grok Bot wakes. Claude Code has no equivalent for any of the four. A rewrite would be an invention wearing a port's name. |
| `889ec4b` Grok 4.6 defaults for bug-fix, perf, hillclimb | skipped | No Grok on this roster. `PORTING.md` already maps the upstream panel to Claude models. |
| `efa2a53`, `7314f72` plugin logo | skipped | poteto's artwork. Shipping her branding inside a fork is the fork owner's call, not a translation decision. |
| `71ed0d1` version bump to 0.15.0 | skipped | This fork versions independently. |

## Not yet reviewed

Nothing. Every upstream commit through `5bf2b15` has a verdict above.

## Local-only

This fork carries skills upstream does not. These are never drift.

| Path | Why |
|---|---|
| `skills/p-update` | Upstream has no fork to reconcile. |
