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
     For any non-trivial mechanism, link its how-it-works explainer under docs/architecture/. -->

## Documentation Conventions

- **Architecture Decision Records** live in `docs/architecture/decisions/` — one decision per file, numbered, **immutable once accepted** (a changed decision is a new ADR that supersedes the old). Follow [`docs/architecture/decisions/template.md`](docs/architecture/decisions/template.md); the [README](docs/architecture/decisions/README.md) states the conventions. Record a decision that's architecturally meaningful (a data-model or interface contract, a cross-cutting integration choice, a security boundary) as an ADR — not local code choices.
- **How-to guides** live in `docs/guides/`; **feature docs** in `docs/features/`; **how-it-works explainers** in `docs/architecture/*.md`; **feature specs** in `docs/specs/*.md`. Keep them distinct: an ADR is *why we chose X*, an explainer is *how it works today*, a guide is *how you do X*, a spec is *the behaviour contract of one feature — what it does — cited by code*.
- **Markdown prose is one line per paragraph** (or semantic line breaks), never fixed-column hard wraps.

## Preserve Architectural Understanding

For any non-trivial mechanism — how a subsystem is wired, the request/response dance behind a behavior, a cross-cutting convention that isn't obvious from any single file — keep a *how-it-works* explainer under `docs/architecture/` (a plain `*.md`). This is **complementary to ADRs, not a substitute**: the ADR records *why*; the explainer records *how it actually works today* so a maintainer (or a future agent) can rebuild the mental model without reverse-engineering the code.

- **When you build or materially change such a mechanism, write or update its explainer as part of the same work** — don't wait to be asked, and cross-link the explainer and its ADR both ways. Use [`docs/architecture/EXPLAINER-TEMPLATE.md`](docs/architecture/EXPLAINER-TEMPLATE.md).

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

**Do not hand-build UI without a design.** UI work follows a design produced with **Claude Design**, generated inside a **Claude Design project bound to this repo's design system** — so every design inherits the system's components *by construction*. This is enforced:

0. **Bound project.** All UI designs are generated in the Claude Design project bound to this repo's design system. The project and design-system names, and the source of truth, are recorded in [`docs/designs/DESIGN-SYSTEM.md`](docs/designs/DESIGN-SYSTEM.md). Designs generated outside that project don't inherit the system and must not be used.
1. **Brief.** A UI change starts as a short **design brief** in `docs/designs/briefs/proposed/<name>.brief.md` (see [`docs/designs/README.md`](docs/designs/README.md)) — the surface, its states, and the intent.
2. **Canvas.** Use **Claude Design** (in the bound project) to generate a high-fidelity, self-contained HTML **design canvas** under `docs/designs/`, rendered against the design system. The canvas is the visual source of truth.
3. **Build to it.** Before implementing, (a) have the canvas for the surface, (b) reference the design system, and (c) **match it exactly** — reuse its components; no colors, spacing, radii, or components outside the token set. Follow the patterns the canvas shows.
4. **Verify & promote.** Every interactive workflow the design specifies gets a test (design fidelity is verified, not assumed). When shipped, move the brief `proposed/ → shipped/`; a design decision worth keeping becomes an ADR.

- **Validate the design against the codebase before building — raise the hand if it's wrong.** A design is the authority on *fidelity*, but it can contradict an established codebase convention, misname a pattern, or diverge from a sibling surface. Verify that what it proposes brings consistency with the existing code — it reuses the established component, matches sibling surfaces, respects the app's canonical names. If it does, build it faithfully. If it does **not**, do **not** silently implement a wrong design — and do **not** silently diverge from it in code either — surface it, sized to the discrepancy:
  - **Small / localized** (a mislabel, a control that should reuse an existing helper) → a **comment** on the ticket/PR naming the inconsistency and the convention it should follow, for the user to relay to the design step. Don't hand-edit the regenerated design file.
  - **Larger / structural** (a pattern that fights how a whole surface class works, a rename, a new grammar) → a **brief** in `docs/designs/briefs/proposed/` proposing the reconciliation for the design step to redraw, rather than baking the divergence into code.

Set up the binding once per project in [`docs/designs/DESIGN-SYSTEM.md`](docs/designs/DESIGN-SYSTEM.md). If this project has no UI, delete this section and `docs/designs/`.

## Feature specifications (`docs/specs/`)

A substantial feature's **behaviour** is consolidated into one hand-owned `docs/specs/<feature>.md` — its rules, contracts, invariants, verbs, transactions and edge/empty states as shipped. This draws a boundary: the **design** (`docs/designs/*.html`) is the *surface* — layout and states, regenerated from the design tool; the **spec** is the *behaviour* — hand-owned and stable. See [`docs/specs/README.md`](docs/specs/README.md).

- **Code cites the spec for behaviour, never a design file — universally.** Any comment explaining *why the logic behaves this way* points at `docs/specs/<feature>.md`; a design section anchor moves when the design is regenerated, a spec heading does not. No design reference appears anywhere in code.
  - **The form is a relative markdown link to the heading: `(docs/specs/<file>.md#<anchor>)`.** ASCII, concise, navigable — a *pointer* stating only the **current** behaviour. Do **not** re-list or paraphrase the spec's rules inline, and do **not** explain what the code *no longer* does or *instead of* what — the spec is the single source. Keep spec **headings short + anchor-friendly** so the `#anchor` stays short.
  - **Cross-cutting behaviour earns its own shared spec — don't inline the rule per surface.** When a rule holds across many surfaces, consolidate it in one `docs/specs/<shared>.md` that every instance cites; a per-feature spec links there for the shared rules and covers only what is specific to it.
  - **No design reference in code — ever, comment or user-facing copy.** A design section (a `§D`-style anchor, or spelled out in plain words) points at a moving mock a reader can't resolve. **Always cite the spec anchor instead** — and if the feature has no spec yet, **generating `docs/specs/<feature>.md` is mandatory**. There is no "legitimate `§` reference" exception; a reference is always a spec anchor.
- **Write or update the spec as part of shipping or materially changing the feature.** Keep it current — a stale spec is worse than none. It links out to the design (surface) and ADRs (why) rather than restating them.
- It borrows [spec-kit](https://github.com/github/spec-kit)'s per-feature *shape*, not its toolchain.

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
4. **Record decisions** — architecturally meaningful decision → an ADR; new/changed mechanism → its explainer.
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
