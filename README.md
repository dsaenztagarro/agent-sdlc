# AI Engineering Template

A project-agnostic scaffold for running **AI-first, agent-driven engineering** on any codebase.

It is the connective tissue that makes heavy AI workflows reliable: a single source of truth agents read (`AGENTS.md`), a decision/knowledge system that survives closed pull requests (`docs/`), a **design → epic → ship** pipeline that turns a design into merged code one ticket at a time, and the **Claude Design** step that produces the design in the first place.

Drop it into a new repo (or click **Use this template**), fill in the handful of project-specific placeholders in `AGENTS.md`, and your project inherits the whole workflow.

> Everything here is **language- and framework-agnostic**. There is no application code, no build tool, and no reference to any specific project — only the practices and the documents that carry them.

## Why this exists

Heavy AI workflows fail in predictable ways: an agent re-derives context that was already decided, reinvents a mechanism that already exists, ships a plausible-but-wrong change, or makes a model/scope choice nobody reviewed. The reasoning behind decisions evaporates when the PR that produced it closes.

This template fixes that with **written, discoverable institutional memory** and a **deterministic delivery loop** an agent can follow without supervision — so the human reviews the *finished* work, not every keystroke.

## The workflow at a glance

```
                        ┌──────────────────────────────────────────────┐
                        │                 docs/  (memory)              │
                        │  decisions (ADRs) · explainers · guides ·    │
                        │  designs · features · SECURITY               │
                        └──────────────────────────────────────────────┘
                             ^            ^                    ^
          write the "why"    │            │ read before work  │  write the "how"
                             │            │                    │
   design brief        Claude Design      AGENTS.md          /epic skill
   (docs/designs/  ──▶  UI canvas OR  ──▶ (the rules    ──▶  design → GitHub epic
    briefs/*.md)        md backend        every agent        → phased sub-issues
                        design doc         obeys)            → one ticket at a time
                                                             → branch · test · PR · merge
```

1. **Design.** For UI, write a short **design brief**, then use **Claude Design** to generate a high-fidelity, self-contained design **canvas** under `docs/designs/`. For backend/architecture, author a markdown design under `docs/architecture/` or `docs/features/`. Either way you now have a **design doc** that is the source of truth for what to build.
2. **Decompose & ship.** Run the **`/epic`** skill on that design doc. It opens a GitHub epic, splits the design into self-contained, dependency-ordered sub-issues, pauses once for your approval, then implements them **one ticket at a time** — branch → tests → PR → squash-merge — until done.
3. **Remember.** As tickets land, the *why* becomes **ADRs**, new mechanisms get **how-it-works explainers**, and reusable know-how becomes **guides**. Pragmatic per-ticket decisions accumulate on the epic issue as shared memory.

The human's only mid-run touch point is the single approval gate before issues are created; the finished work is reviewed at the end.

## What's in the box

### 1. `AGENTS.md` + `CLAUDE.md` — the single source of truth

`AGENTS.md` is the one file every agent reads before doing anything. It states the project overview, the build/test/lint gate, the architecture map, the documentation and testing rules, the design workflow, and the development workflow. `CLAUDE.md` is a one-line pointer (`@AGENTS.md`) so Claude Code loads the same rules. **You fill in the project-specific placeholders once; everything else is portable.**

### 2. Model selection & task tracking

Every task carries an explicit `complexity · model · why` tag, so which model runs which work is a *deliberate, reviewable* choice — not a silent default. Correctness-critical, interdependent, or context-heavy work defaults to the most capable model; cheaper/faster models are an escalation you justify. This is what keeps a large autonomous run from quietly downgrading the hard parts.

### 3. `docs/` — institutional memory, with a clear taxonomy

Each kind of knowledge has exactly one home, so nothing blurs:

| Folder | Answers | Immutable? |
| ------ | ------- | ---------- |
| `docs/architecture/decisions/` | **Why** is it built this way? (ADRs) | Accepted ADRs are immutable — supersede, never rewrite |
| `docs/architecture/*.md` | **How** does this mechanism work today? (explainers) | Living |
| `docs/guides/` | **How do I** do X? (how-to) | Living |
| `docs/features/` | What does this feature do, end to end? | Living |
| `docs/designs/` | What should it look like? (Claude Design canvases + briefs) | Living |
| `docs/SECURITY.md` | How are secrets/keys handled? | Living |

- **ADRs** capture one decision each — what, why, the rejected alternatives, the consequences — numbered and immutable once accepted. A changed decision is a *new* ADR that supersedes the old. `docs/architecture/decisions/` ships with the conventions, a `template.md`, and the meta-ADR `0001` that establishes the practice.
- **How-it-works explainers** are the complement to ADRs: an ADR records *why a fork was chosen*; an explainer records *how the thing actually works now*, so a maintainer (or a future agent) rebuilds the mental model without reverse-engineering the code. `AGENTS.md` requires writing/updating the explainer in the *same* change that builds or alters a non-trivial mechanism.

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

**Claude Design is the first stage of the workflow, and `AGENTS.md` enforces it: you do not hand-build UI without a design.**

- **Brief → canvas.** A UI change starts as a **design brief** (`docs/designs/briefs/proposed/<name>.brief.md`) — a short markdown statement of the surface, states, and intent. **Claude Design** turns that brief into a **high-fidelity, self-contained HTML design canvas** in `docs/designs/`, rendered against your **design system** (tokens, components, typography). The canvas is the visual source of truth.
- **Enforced before implementation.** `AGENTS.md`'s design rules require that, before building any UI, an agent (a) has a design canvas for the surface, (b) references the design system, and (c) **matches it exactly** — no ad-hoc colors, spacing, or components outside the token set. UI shipped without a design is an open gap, not done.
- **Fed to `/epic`.** The design canvas is a first-class **design doc**: `/epic` decomposes its sections/workflows into tickets and verifies each against a test. Backend designs (plain markdown) flow through the same pipeline.
- **Promoted to memory.** The brief moves `proposed/ → shipped/` when built; a design decision worth keeping becomes an ADR; the design system stays the canonical reference.

This closes the loop: **Claude Design** produces the *what-it-looks-like*, `AGENTS.md` enforces *build to it*, `/epic` drives *build it*, and `docs/` records *why and how*.

### 6. Documentation style

- **ASCII diagrams only** (`+ - | v ^ >`) — they render identically in every terminal, editor, and diff.
- **Markdown prose is one line per paragraph** (or semantic line breaks), never fixed-column hard wraps — so diffs stay word-level and readable.

### 7. Testing philosophy (framework-neutral)

Test the real thing; don't mock the object under test. Prefer real collaborators and fixtures over test doubles — a test that stubs what it's checking proves the stub, not the code. Reserve doubles for genuine boundaries (the network, external services, infrastructure you can't stand up, forced-error injection). And when a change has a runtime surface, **drive it and observe the behaviour** — passing tests are necessary, not sufficient.

### 8. `.claude/` settings

`.claude/settings.local.json.example` is a committed template for local Claude Code permissions and attribution; the real `.claude/settings.local.json` is git-ignored. Copy the example to opt into an allowlist and to control commit/PR attribution.

## Applying the template to a new project

1. **Create the repo** from this template (GitHub **Use this template**, or clone and re-init git).
2. **Fill in `AGENTS.md`** — every `<!-- FILL: … -->` marker: project overview, the build/test/lint gate commands, the architecture map, and any project-specific rules. Delete sections that don't apply (e.g. the design workflow for a headless service).
3. **Keep `CLAUDE.md`** as `@AGENTS.md`.
4. **Adapt `.claude/skills/epic/SKILL.md`'s gate** to your project's commands if you want them inlined; otherwise it already defers to `AGENTS.md`.
5. **Start writing memory**: your first real decision → an ADR (copy `docs/architecture/decisions/template.md`); your first UI → a brief + a Claude Design canvas.
6. Copy `.claude/settings.local.json.example` → `.claude/settings.local.json` and adjust.

## Layout

```
.
├── AGENTS.md                         # the rules every agent reads (fill in the placeholders)
├── CLAUDE.md                         # -> @AGENTS.md
├── .claude/
│   ├── settings.local.json.example   # committed template; real file is git-ignored
│   └── skills/epic/SKILL.md          # the design -> epic -> ship workflow
└── docs/
    ├── SECURITY.md                   # secret/key-handling note (template)
    ├── architecture/
    │   ├── README.md                 # explainers vs decisions
    │   ├── EXPLAINER-TEMPLATE.md      # how-it-works explainer scaffold
    │   └── decisions/                # ADRs: README + template.md + 0001 meta-ADR
    ├── designs/
    │   ├── README.md                 # the Claude Design workflow
    │   └── briefs/                    # brief conventions + template
    ├── guides/README.md              # how-to guide convention
    └── features/README.md            # feature-doc convention
```

## License

[MIT](LICENSE) © David Saenz
