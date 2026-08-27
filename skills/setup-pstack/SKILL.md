---
name: setup-pstack
description: Configure which models pstack uses per role. Detects the model values this session can pass to a subagent and writes a config file the skills read. Use for /setup-pstack, "configure pstack models", or changing pstack's model choices.
disable-model-invocation: true
---

# Setup pstack

Write `~/.claude/pstack/models.md`, a config file that sets pstack's model per role. The skills read it at the point of delegation and fall back to their inline defaults when a line is absent, so this is an override layer, not a requirement.

This is read on demand, not always-applied. Claude Code's always-applied surface is `~/.claude/CLAUDE.md`, and a full role table there would cost context on every session for a file only the delegating skills need. Do not move it there.

## Steps

### 1. Detect available models

The dependable source is the `model` field of the `Agent` tool in this session. Claude Code accepts `opus`, `sonnet`, `haiku`, `fable`, a full model ID such as `claude-opus-5`, and `inherit`. Read the `Agent` tool's own schema rather than assuming; the roster changes and an organization's `availableModels` allowlist can narrow it.

Never write a value you have not confirmed this session accepts. `inherit` is always valid.

### 2. Load current state

The default role-to-model mapping is the shape shown in step 5. If `~/.claude/pstack/models.md` already exists, read it and treat its values as the current choices. Otherwise start from those defaults.

### 3. Map and confirm

Show every role with its current model, marking any value not in the detected set as needing a choice. Ask whether to accept as-is or change specific roles, offering the detected models plus `inherit` (meaning: this role runs on the parent chat model, so omit `model` on the `Agent` call). Prefer `AskUserQuestion` over free text.

For panel roles (how critics, arena runners, architect runners, interrogate reviewers) the value is a list. One subagent runs per entry, `inherit` entries included, so the list length sets the fan-out. `arena cross-judge pool` is also a list, and Arena selects one value from it that differs from the parent's model when possible. `swarm workers` is the default model for every worker unless a race or comparison assigns another model per arm.

### 4. Validate

Every value written must be one the `Agent` tool accepts in this session; `inherit` always passes. If a chosen value is not available, stop and ask again. A config pointing at a model the user cannot use breaks every delegation that reads it.

### 5. Write the config

Write `~/.claude/pstack/models.md` with one line per role. Overwrite the whole file so re-runs stay idempotent. Create the directory if it does not exist. Shape:

```
# pstack model configuration. One line per role. Delete a line to fall back to the skill default.
# `inherit` as a value: the role runs on the parent chat model (omit the `Agent` call's `model`).
# `inherit` entries in a panel list still count toward its fan-out.
feature, refactoring: sonnet
bug-fix: opus
perf-issue: opus
hillclimb: opus
judgment and prose: fable
hardest tasks: opus
how explorer: sonnet
how explainer: fable
how critics: fable, opus, sonnet
why investigators: sonnet
why synthesizer: fable
reflect tooling: opus
reflect judgment, divergent, synthesizer: fable
arena runners: fable, opus, sonnet
arena cross-judge pool: fable, opus, sonnet
swarm workers: sonnet
architect runners: fable, opus, sonnet
interrogate reviewers: fable, opus, sonnet
```

### 6. Note the single-vendor caveat once

pstack's review panels were built on cross-vendor diversity, where disagreement between a Claude model and a non-Claude model is the adversarial signal. Every model here is a Claude model, so blind spots correlate more than the upstream design assumes. Tell the user this once, and that the panel skills compensate by assigning each reviewer a distinct lens in addition to a distinct model. Do not silently widen a panel to buy back diversity; more Claude reviewers on the same prompt mostly buys correlated agreement.

`haiku` is available as a cheap fourth lens where breadth matters more than depth (swarm workers, how explorers). It is not a good panel reviewer for contested design work.

### 7. Confirm

Tell the user the config was written and that skills pick it up on their next delegation. Re-running this skill updates it.

### 8. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill, or an existing harness). Claude Code's built-in `/run` skill covers launching and driving the app, and the Browser tools cover web and Electron UIs, so check whether those already suffice before generating anything.

If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /create-verification-skill." On yes, invoke `/create-verification-skill`. On no, move on without pushing.
