# Agentic Engineering Template

A project-agnostic scaffold for **agentic engineering** — building software with coding agents — on any codebase.

It is the connective tissue that makes heavy AI workflows reliable: a single source of truth agents read (`AGENTS.md`), a decision/knowledge system that survives closed pull requests (`docs/`), a **design → epic → ship** pipeline that turns a design into merged code one ticket at a time, and the **Claude Design** step that produces the design in the first place.

Drop it into a new repo (or click **Use this template**), fill in the handful of project-specific placeholders in `AGENTS.md`, and your project inherits the whole workflow.

> Everything here is **language- and framework-agnostic**. There is no application code, no build tool, and no reference to any specific project — only the practices and the documents that carry them.

## Why this exists

Heavy AI workflows fail in predictable ways: an agent re-derives context that was already decided, reinvents a mechanism that already exists, ships a plausible-but-wrong change, or makes a model/scope choice nobody reviewed. The reasoning behind decisions evaporates when the PR that produced it closes.

This template fixes that with **written, discoverable institutional memory** and a **deterministic delivery loop** an agent can follow without supervision — so the human reviews the *finished* work, not every keystroke.

## The workflow at a glance

```
  a design brief       Claude Design        AGENTS.md          /epic skill
  (<project>-ds)  -->  draws the page  -->  the rules     -->  design -> GitHub epic
                       (<project>-ds)       every agent        -> phased sub-issues
                                            obeys              -> one ticket at a time
                                                               -> branch, test, PR, merge
                                                                        |
                                                                        v
                              docs/  (bounded memory)  <-------  tests state the rules;
                              adr/ one record per theme          themes amended at close-out
                              guide-<topic> + slides-<topic>
```

1. **Design.** For UI, a short **brief** goes to a **Claude Design** project, which draws the page. Briefs, pages and the export live in a sibling **`<project>-ds`** repository; one generated artefact crosses into the application. For backend work, write a markdown design — an input, deleted when it ships.
2. **Decompose & ship.** Run **`/epic`** on the design. It opens a GitHub epic, splits the design into dependency-ordered sub-issues, pauses once for your approval, then implements them **one ticket at a time** — branch → tests → PR → squash-merge.
3. **Remember, within a bound.** Behaviour is stated by tests. The *why* amends one of at most ten **themed decision records**, once, at close-out. A mechanism worth explaining amends its **topic guide**. Nothing in `docs/` grows one file per ticket, decision or feature.

The human's only mid-run touch point is the single approval gate before issues are created; the finished work is reviewed at the end.

## What's in the box

### 1. `AGENTS.md` + `CLAUDE.md` — the single source of truth

`AGENTS.md` is the one file every agent reads before doing anything. It states the project overview, the build/test/lint gate, the architecture map, the documentation and testing rules, the design workflow, and the development workflow. `CLAUDE.md` is a one-line pointer (`@AGENTS.md`) so Claude Code loads the same rules. **You fill in the project-specific placeholders once; everything else is portable.**

### 2. Model selection & task tracking

Every task carries an explicit `complexity · model · why` tag, so which model runs which work is a *deliberate, reviewable* choice — not a silent default. Correctness-critical, interdependent, or context-heavy work defaults to the most capable model; cheaper/faster models are an escalation you justify. This is what keeps a large autonomous run from quietly downgrading the hard parts.

### 3. `docs/` — institutional memory, bounded by design

An agent reads the repository at the start of every task, and its context is finite. So every kind of document here grows with the product's **areas**, never with its **work items**:

| Home | Answers | Grows with |
| ---- | ------- | ---------- |
| tests | **What** does the code do? | the code |
| `docs/adr/NNNN-<theme>.md` | **Why** is it built this way? | themes — capped at ten, amended in place |
| `docs/guide-<topic>.md` + `docs/slides-<topic>.md` | **How** does this work here, and how do I operate it? | topics |
| GitHub issues | What is still open? | the tracker, not the repository |
| `docs/SECURITY.md` | How are secrets handled? | — |

- **Decision records are themed.** A decision amends the record that owns its theme; it never opens a new file. The superseded reasoning moves to the theme's decision-log issue, and git keeps the text. `docs/adr/0001-decision-records.md` records why — one project using this workflow reached 64 per-decision records in three months before consolidating them into thirteen themes.
- **Inputs are deleted when what they produced ships** — briefs, backend designs, reviews.
- **`.github/workflows/docs.yml` enforces the bound**: more than ten records, a record over sixty lines, or a folder that grows per work item fails the build.

### 4. The `/epic` workflow skill

`.claude/skills/epic/SKILL.md` is a complete, user-invoked orchestration for taking one design doc to shipped code:

- opens a GitHub **epic** issue and decomposes the design into **self-contained, phased sub-issues**;
- **one approval gate**, then runs autonomously;
- implements **strictly one ticket at a time** — branch → implement per `AGENTS.md` → the project's **test/lint gate** → PR → squash-merge;
- carries every pragmatic decision forward on the epic's **Decisions Log** (the shared memory between tickets), and promotes architectural ones to **ADRs**;
- **re-diff / resume modes** reconcile against the *current code*, never a stale checklist, so re-running on an edited design finds exactly what changed;
- **design fidelity is verified, not assumed** — every behaviour the design specifies must have a test.

The skill names no language or tool: it defers to the gate and conventions in *your* `AGENTS.md`.

### 5. Claude Design — where the design comes from

**Claude Design is the first stage of the workflow, and `AGENTS.md` enforces it: you do not hand-build UI without a design.** [`docs/guide-design-handoff.md`](docs/guide-design-handoff.md) is the procedure, with its diagrams in `docs/slides-design-handoff.md`.

- **Design content lives in `<project>-ds`**, a sibling repository — briefs, the pages Claude Design returns, and a mirror of its export. It grows without bound, and an application repository carrying it stops being code.
- **Exactly one generated artefact crosses** into the application — a token set or a stylesheet bundle — and code never cites a page or a brief.
- **Three routes reach the design project**, each started by a person: a pasted **brief** carries one ask; **`/design-sync`** writes named files, including the project's own `readme.md` for rules that must hold in every export; and the downloaded **export** brings the whole project back to be mirrored.
- **A brief is deleted when its surface ships.** The `brief-closer` agent verifies each ask before it deletes anything.

### 6. Documentation style

- **ASCII diagrams only** (`+ - | v ^ >`) — they render identically in every terminal, editor, and diff.
- **Markdown prose is one line per paragraph** (or semantic line breaks), never fixed-column hard wraps — so diffs stay word-level and readable.

### 7. Testing philosophy (framework-neutral)

Test the real thing; don't mock the object under test. Prefer real collaborators and fixtures over test doubles — a test that stubs what it's checking proves the stub, not the code. Reserve doubles for genuine boundaries (the network, external services, infrastructure you can't stand up, forced-error injection). And when a change has a runtime surface, **drive it and observe the behaviour** — passing tests are necessary, not sufficient.

### 8. `.claude/` settings

`.claude/settings.local.json.example` is a committed template for local Claude Code permissions and attribution; the real `.claude/settings.local.json` is git-ignored. Copy the example to opt into an allowlist and to control commit/PR attribution.

### 9. The `template-feedback` skill — a self-improvement loop

A template only gets better if the improvements people discover while *using* it flow back. `.claude/skills/template-feedback/SKILL.md` is that return path: when an agent (or you) finds a **reusable, project-agnostic** improvement to the workflow — a rule that should exist in `AGENTS.md`, a skill step that misfires, a docs-taxonomy gap — the skill surfaces a concrete proposal and, on your OK, opens a GitHub **issue on this template repo** so every adopter inherits the fix. It never edits the template silently, and it's scoped to *generalizable* improvements (project-specific rules stay in that project's `AGENTS.md`). `AGENTS.md` primes agents to reach for it — the "raise the hand" rule under **Improving this workflow**.

## Applying the template to a new project

1. **Create the repo** from this template (GitHub **Use this template**, or clone and re-init git).
2. **Fill in `AGENTS.md`** — every `<!-- FILL: … -->` marker: project overview, the build/test/lint gate commands, the architecture map, and any project-specific rules. Delete sections that don't apply (e.g. the design workflow for a headless service).
3. **Keep `CLAUDE.md`** as `@AGENTS.md`.
4. **Name your first themes** in `docs/adr/README.md` as the first decisions in each area are made, and open a `decision-log` issue per theme.
5. **For a UI**, create the `<project>-ds` repository and fill in the names in `docs/guide-design-handoff.md`; otherwise delete the guide and its slides.
6. Copy `.claude/settings.local.json.example` → `.claude/settings.local.json` and adjust.

## Layout

```
.
+-- AGENTS.md                          the rules every agent reads (fill in the placeholders)
+-- CLAUDE.md                          -> @AGENTS.md
+-- .github/workflows/docs.yml         the bound on docs/, enforced
+-- .claude/
|   +-- settings.local.json.example    committed template; the real file is git-ignored
|   +-- agents/brief-closer.md         closes a brief once its surface ships
|   +-- skills/
|       +-- epic/SKILL.md              design -> epic -> ship
|       +-- template-feedback/SKILL.md raise reusable workflow improvements upstream
+-- docs/
    +-- SECURITY.md                    secret and key handling
    +-- adr/                           one record per theme, at most ten
    +-- guide-design-handoff.md        the Claude Design procedure
    +-- slides-design-handoff.md       its diagrams
```

## License

[MIT](LICENSE) © David Saenz
