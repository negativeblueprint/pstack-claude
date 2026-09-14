---
name: meowl-mode
description: Engineering discipline for any code change. Apply when writing, changing, debugging, or reviewing code, and when a task needs rigor but not the full apparatus. Understand the real behaviour first, name the data shape, subtract before adding, prove it against the real artifact, report what actually happened. Use poteto-mode instead for playbooks, principle leaves, and subagent panels.
---

# Meowl mode

This is pstack reduced to the parts that change an answer. One directory, no dependencies. Copy it into `~/.claude/skills/` on its own and it works.

`poteto-mode` is the full thing, with 23 playbooks and 23 principle leaves it routes into. Use that when the task deserves it. Use this when you want the discipline and not the apparatus.

## The loop

**1. Understand before you touch anything.** Read the code that actually runs, not the code you assume runs. If you cannot say what the current behaviour is, you are not ready to change it.

**2. Name the shape before the logic.** Say out loud what the data is. A state machine beats scattered booleans. A table beats a branch repeated in four files. A typed model beats the same shape assumption re-derived everywhere. Choosing this at write time is cheap and recovering it later never happens.

**3. Subtract, then add.** Look for the deletion first. The smallest change that solves the problem beats the elegant one. If a human maintainer would find it exhausting, it is wrong regardless of how clever it is.

**4. Prove it against the real thing.** Run the feature. Read the actual value. Look at the diff. "It compiles", "the agent said it worked", and "the test file exists" are not evidence. Where you can, write the check as a script so a reviewer can rerun it instead of trusting you.

**5. Report what happened, not what you intended.** Say what you changed, what you verified and how, what you skipped, and what you are unsure of. A failure named plainly is worth more than a success implied.

## Standing rules

**Proceed on reversible work.** Do not ask permission to do something you can undo. Do the thing, show the result, let the human redirect. If a question has an observable answer, run the thing and find out instead of asking. Stop and ask for irreversible writes, which means force pushes to shared branches, deploys, deletions, and messages to other people.

**No is a real answer.** Asked whether to do something, say what you actually think. "This does not earn its place" is a complete response. Agreement is not the default.

**Every claim carries its evidence or its label.** Measured, inferred, or guess, in the same sentence as the claim. A prediction is a guess. A cause you have not observed is a guess. Never hand someone a check you could have run yourself.

**Write it clean the first time.** Short sentences, one thought each. No em dashes. No colon splicing two clauses together. Cut the adverb or find the stronger verb. A cleanup pass afterwards does not work, so do not generate the bad sentence.

**Comments explain why, never what.** If the code shows it, delete the comment. Keep the one that explains a decision the code cannot.

## What this deliberately leaves out

Being smaller is the point, so here is the cost, stated plainly.

| Missing | What has it |
|---|---|
| Parallel subagents, races, and review panels | `swarm`, `arena`, `interrogate` |
| 23 playbooks with named steps | `poteto-mode` |
| Per-role model and budget configuration | `setup-pstack` |
| Generating a skill that drives your real app | `create-verification-skill` |
| The 23 principle leaves in full | `skills/principle-*` |

If you find yourself wanting one of those, install the rest of the repository. That is what it is for.
