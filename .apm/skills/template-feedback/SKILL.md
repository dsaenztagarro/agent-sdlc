---
name: template-feedback
description: Raise a reusable, project-agnostic improvement to the agent-sdlc workflow itself — a rule AGENTS.md should state, a skill step that misfires, a docs-taxonomy gap — as one checklist item on the template's open feedback issue. Not for project-specific code, config or content. Surfaces the proposal first and writes upstream only on the user's OK. May be user-invoked as `/template-feedback [idea]`, or reached for when such an improvement surfaces during other work.
argument-hint: "[short description of the improvement]"
---

# Propose a template improvement upstream

An improvement to the workflow found while using it is worth something only if it reaches every adopter. This skill sends it to `dsaenztagarro/agent-sdlc`, or to the upstream the user names if this project tracks a fork.

## 1. Confirm it generalizes

Restate it in one sentence that names no project, language or framework. If you cannot, it is local: apply it to this repository's `AGENTS.md`, a rule, or the theme's decision record, and stop.

## 2. Surface the proposal

Show the user, in the conversation:

- **Problem:** what misfires today, with the one instance where it bit.
- **Change:** the wording or diff, ready to apply, and the template file it lands in.
- **Why it generalizes**, and any trade-off.

Finish the task at hand first; do not drop it to chase the idea.

## 3. On the user's OK, append it to the open feedback issue

Every proposal joins **one open issue labelled `template-feedback`** as a `- [ ]` item, never an issue of its own: the maintainer works the list in one pull request.

```bash
gh issue list --repo dsaenztagarro/agent-sdlc --label template-feedback --state open
# none open: create it once
gh issue create --repo dsaenztagarro/agent-sdlc --label template-feedback \
  --title "Template feedback" --body "Workflow improvements raised from downstream projects, one item each."
```

First search the issue and the closed ones for the same idea (`gh issue list --repo dsaenztagarro/agent-sdlc --search "<keywords>" --state all`); if it is there, add to that item instead.
Then append the item with `gh issue edit <n> --body-file`, keeping the body as it was: the problem, the change, the file, why it generalizes.

Report the issue URL. A pull request instead of an item is opt-in, only when the user asks for one.

## Guardrails

- Nothing is written upstream without the user's OK in the current turn.
- Never rewrite a decision record or a skill's contract as a "fix": propose it, and let the maintainer decide.
