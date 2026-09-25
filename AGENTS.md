# AGENTS.md

Instructions for AI agents working on this codebase. This is the single source of truth agents read before doing anything; keep it current.

> This file is a **template**. Replace every `<!-- FILL: … -->` with your project's specifics and delete any section that doesn't apply. The principle sections (model selection, documentation, testing, design workflow, development workflow) are portable as-is.

## Model selection & task tracking

Every task you plan or pick up carries an explicit **complexity** rating and the **model** it runs on — state both (`complexity · model · why`) in the plan, the epic ticket, or the task list so the choice is deliberate and reviewable, not implicit. When you decompose work, tag each piece; don't leave the model a running default nobody chose.

- **Default to the most capable model.** Correctness-critical, interdependent, or context-heavy work — schema/data changes, multi-file refactors, anything where a subtle mistake compounds across the change — stays there even when it is large. Delegating hard work to a cheaper run because it's tedious is a false economy.
- **Escalate to a cheaper/faster model only when the complexity genuinely pays off there** and the task isn't the correctness-critical / interdependent / context-heavy kind above. When it's a close call, stay on the capable model.
- **Record the call, one clause of why.** e.g. `complexity: complex · model: <capable> · why: interdependent state machine`. The rating is about consequence and coupling, not line count.

## Improving this workflow (raise the hand)

This project runs on the [ai-engineering-template](https://github.com/dsaenztagarro/ai-engineering-template). When you discover a **reusable, project-agnostic** improvement to the workflow itself — a rule that should exist here, a skill step that misfires, a docs-taxonomy gap, a principle worth stating — don't silently apply it only to this repo. **Raise the hand:** run the **`template-feedback`** skill (`.claude/skills/template-feedback/`) to surface a concrete proposal and, on the maintainer's OK, open an issue on the upstream template so every adopter benefits. Keep project-specific rules in this repo; send generalizable ones upstream.

## Project Overview

<!-- FILL: 2-3 sentences — what this project is, who uses it, the core domain. Link the README. -->

## Tech Stack

<!-- FILL: language(s), framework(s), datastore, key libraries, deploy target. -->

## Common Commands

<!-- FILL: the real commands. These are what the test/lint gate and the /epic skill rely on. -->

```bash
# build:   <!-- FILL -->
# test:    <!-- FILL -->
# lint:    <!-- FILL -->
# run:     <!-- FILL -->
```

## Architecture

<!-- FILL: the mental model in a paragraph, then a "Key files" list mapping subsystems to paths.
     For any non-trivial mechanism, link its topic guide, docs/guide-<topic>.md. -->

## Documentation Conventions

- **Decision records** live in `docs/adr/` — **one record per theme, capped at ten, amended in place.** A decision amends the record that owns its theme; it never opens a new file. A decision that fits no theme is the maintainer's call — stop and ask. The bar, the themes and the procedure are in [`docs/adr/README.md`](docs/adr/README.md); the reasoning is [`docs/adr/0001-decision-records.md`](docs/adr/0001-decision-records.md).
- **Tests are the specification.** What the code does is stated by tests named for the rules they hold. Before writing a behaviour rule in prose, name the test that would fail if it were broken — then write that test and stop.
- **A topic that needs explaining gets one pair**: `docs/guide-<topic>.md`, the procedure and the mechanism in this project's terms, and `docs/slides-<topic>.md`, the diagrams. A new mechanism amends the guide for its topic rather than adding a file; topics grow with the product's areas, never with its tickets.
- **An input is deleted when what it produced ships** — a brief, a backend design, a review. Its durable half moves to a record, a test or an issue first.
- **Never a document per work item.** A generator that writes one file per decision, feature, ticket or brief is a defect; `.github/workflows/docs.yml` fails the build on the folders that used to grow that way.
- **Markdown prose is one line per paragraph** (or semantic line breaks), never fixed-column hard wraps.

## Documentation Style

When creating diagrams in documentation or code comments:
- Use simple ASCII characters (`+`, `-`, `|`, `v`, `^`, `>`) instead of Unicode box-drawing characters.
- This ensures consistent rendering across all fonts, terminals, and editors.

```
Good (ASCII):
+--------+     +--------+
| Box A  |---->| Box B  |
+--------+     +--------+
```

## Design workflow (Claude Design)

**Do not hand-build UI without a design.** Design content — briefs, the pages Claude Design returns, the export mirror — lives in the **`<project>-ds`** design repository, and exactly one generated artefact crosses into this one. The procedure, and the three routes into the Claude Design project, are [`docs/guide-design-handoff.md`](docs/guide-design-handoff.md).

- **Build to the page, with the vendored artefact only.** No colour, spacing or component outside it.
- **Code never cites a design page or a brief**, in any form — a path, a section label, or the same thing in words. A page regenerates and a brief is deleted; cite the decision record for *why* and the test for *what*.
- **Validate the design against the codebase before building — raise the hand if it's wrong.** If it brings consistency, build it faithfully. If it does **not**, neither implement it silently nor diverge from it silently: a **comment** on the ticket for something localised, a **brief** in the design repository for something structural.
- **A behaviour a page draws that nothing here has settled is an open question**, answered by a test and, where it is a real fork, the theme's decision record — then sent back through a brief.

If this project has no UI, delete this section and the handoff guide.

## Testing Guidelines

### Test the real thing; don't mock the object under test

A test that stubs the very thing it is checking proves the stub, not the app — an over-mocked test stays green while the real code breaks. Default to **real collaborators and fixtures**: instantiate the actual units, let them exercise real (test) infrastructure, and assert on real outcomes.

Reserve test doubles for **genuine boundaries**, never the object under test or its in-process collaborators:
- **The network / external services.**
- **Infrastructure you cannot stand up in a unit test.**
- **Forced-error injection you cannot otherwise reproduce.**

The tell for an over-coupled test: refactoring a method's implementation, without changing its behaviour, breaks the test. Rewrite it against real objects and observable outcomes.

### Verify the runtime surface

When a change has a runtime surface, **drive it and observe the behaviour** before considering it done — passing tests are necessary, not sufficient.

### Smoke-test every interactive surface

Every interactive frontend surface gets at least one end-to-end test proving the wiring connects — from the interaction through to the rendered result. Navigate to the page (via a real interaction, not a direct URL, when possible), trigger the interaction, and assert the **expected rendered outcome**. The goal is to confirm the gears connect, not to exercise every backend permutation — that belongs in unit/integration tests.

**Assert what should render, not the absence of an error.** Prefer a positive assertion (the content, option, or row that should now be present or gone) over a negative one tied to a specific failure string. A positive assertion describes what the feature is supposed to do and still fails when the wiring breaks; negative error-string assertions are brittle regression guards that don't document the feature.

## No fallbacks to legacy values

Read a fact from its **current owner only** — never with a `|| <legacy_source>` fallback. When a fact has moved to a new home, reads point at the new owner and stop there.

A fallback to the retired source is a defect, not a safety net: it keeps the dead field alive, hides that the migration is incomplete, and silently serves stale data whenever the two disagree.

- **Read the new owner, full stop.** If the new owner has no value, render empty — do not reach back to the legacy source.
- **Don't write the legacy field either.** New create/update paths write the fact to its current owner, never to the retired one.
- **A legacy field with no readers is a field to drop.** The lifecycle is **re-point reads → stop writing → drop the field**, in that order — never leave it parked as a dormant fallback. "It still has data" is not a reason to keep reading it; migrate the data to the owner, then drop.

## CI / gate

<!-- FILL: what must be green before a change ships (tests, lint, security scan) and where it runs.
     The /epic skill defers to this gate. -->

## Development Workflow

For any new feature or significant change:

1. **Create a GitHub issue** documenting the change (summary, acceptance criteria, technical notes).
2. **Create a feature branch** named after the issue: `git checkout -b <issue>-<slug>`.
3. **Implement & test** — write tests alongside the change; run the gate frequently; drive the runtime surface.
4. **Record decisions** — a decision that clears the bar amends its theme's record in `docs/adr/`; a new or changed mechanism amends its topic guide.
5. **Open a PR** with `gh pr create`, body ending `Closes #<issue>`; merge with `gh pr merge --squash` once the gate is green.

For larger, multi-ticket work, drive it with the **`/epic`** skill (`.claude/skills/epic/`): one design doc → a GitHub epic → phased sub-issues → shipped, one ticket at a time.

### Incidental minor findings → the `chore` accumulator

While doing a task you'll notice **minor, unrelated** defects — a stale label, a typo, a dead file, a tiny inconsistency — out of scope for what you're shipping. Don't fix it inline (bloats an unrelated diff), don't drop it (it's lost), and don't open a dedicated issue for a one-line fix (pure ceremony). Instead capture it in one rolling paper-cuts list and keep working.

One open **`chore`**-labelled issue pools these. Find it, append the finding, move on (mirroring the `epic` skill's find-or-create-by-label):

```bash
gh issue list --label chore --state open        # find the open accumulator
# none yet? create the label once, then the issue.
```

Append **one self-contained `- [ ]` item per finding** — enough for a later run to fix it without rediscovery: `file:line` — the symptom — the fix — provenance (found while doing #NNN).

- **Belongs here:** minor, unrelated, low-urgency paper cuts.
- **Does not:** a real bug or security issue gets its **own** issue — don't bury it in the list.
- **Already in your blast radius:** a trivial fix in a file you're *already* editing just gets fixed and reported as a distinct change; the accumulator is only for what's **out of scope**.

When worth a pass, the list ships as **one** PR that closes many items at once.
