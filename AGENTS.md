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
- **How-to guides** live in `docs/guides/`; **feature docs** in `docs/features/`; **how-it-works explainers** in `docs/architecture/*.md`. Keep them distinct: an ADR is *why we chose X*, an explainer is *how it works today*, a guide is *how you do X*.
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

Set up the binding once per project in [`docs/designs/DESIGN-SYSTEM.md`](docs/designs/DESIGN-SYSTEM.md). If this project has no UI, delete this section and `docs/designs/`.

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
