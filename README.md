# agent-sdlc

A project-agnostic scaffold for **agentic engineering** — building software with coding agents — on any codebase.

It is the connective tissue that makes heavy AI workflows reliable: a single source of truth agents read (`AGENTS.md`), a decision/knowledge system that survives closed pull requests (`docs/`), a **plan → build → review → fix → close → release** delivery pipeline that runs on the issue tracker and turns a design into merged code one ticket at a time, and the **Claude Design** step that produces the design in the first place.

Drop it into a new repo (or click **Use this template**), fill in the handful of project-specific placeholders in `AGENTS.md`, and your project inherits the whole workflow.

> Everything here is **language- and framework-agnostic**. There is no application code, no build tool, and no reference to any specific project — only the practices and the documents that carry them.

## Why this exists

Heavy AI workflows fail in predictable ways: an agent re-derives context that was already decided, reinvents a mechanism that already exists, ships a plausible-but-wrong change, or makes a model/scope choice nobody reviewed. The reasoning behind decisions evaporates when the PR that produced it closes.

This template fixes that with **written, discoverable institutional memory** and a **deterministic delivery loop** an agent can follow without supervision — so the human reviews the *finished* work, not every keystroke.

## The workflow at a glance

```
  a design brief       Claude Design        AGENTS.md          the tracker pipeline
  (<project>-ds)  -->  draws the page  -->  the rules     -->  plan    -> the epic's description
                       (<project>-ds)       every agent        build   -> a worktree per ticket
                                            obeys              review  -> PR threads + QA: note
                                                               fix     -> a commit per finding
                                                               close   -> evidence per ticket
                                                               release -> CHANGELOG + tag
                                                                        |
                                                                        v
                              docs/  (bounded memory)  <-------  tests state the rules;
                              adr/ one record per theme          themes amended at close-out
```

1. **Design.** For UI, a short **brief** goes to a **Claude Design** project, which draws the page. Briefs, pages and the export live in a sibling **`<project>-ds`** repository; one generated artefact crosses into the application. For backend work, write a markdown design — an input, deleted when it ships.
2. **Deliver.** One pipeline takes the design to a release, through the issue tracker: the plan is published on an epic, its tickets are built **one worktree each** into a pull request, the pull request is reviewed and fixed, each ticket closes with evidence, and the release is versioned from the commits. §4 states what each step reads and leaves where.
3. **Remember, within a bound.** Behaviour is stated by tests. The *why* amends one of a few broad **themed decision records**, once, at close-out. Commands live in the README and procedures in skills. Nothing in `docs/` grows one file per ticket, decision or feature.

The human approves the plan and merges; the finished work is reviewed at the end.

## What's in the box

### 1. `AGENTS.md` + `CLAUDE.md` — the rules every task needs

`AGENTS.md` loads in every session, so it holds only what applies to every task — the rules an agent can break before it knows they exist — and a routing table to the rest: a procedure is a skill, loaded when invoked, and a rule for one kind of file is a path-scoped rule in `.claude/rules/`, loaded when a matching file is opened. It states the project overview, the build/test/lint gate, the architecture map, the documentation and testing rules, the design workflow, and the development workflow. `CLAUDE.md` is a one-line pointer (`@AGENTS.md`) so Claude Code loads the same rules. **You fill in the project-specific placeholders once; everything else is portable.**

### 2. Model selection & task tracking

Every task carries an explicit `complexity · model · why` tag, so which model runs which work is a *deliberate, reviewable* choice — not a silent default. Correctness-critical, interdependent, or context-heavy work defaults to the most capable model; cheaper/faster models are an escalation you justify. This is what keeps a large autonomous run from quietly downgrading the hard parts.

### 3. `docs/` — institutional memory, bounded by design

An agent reads the repository at the start of every task, and its context is finite. So every kind of document here grows with the product's **areas**, never with its **work items**:

| Home | Answers | Grows with |
| ---- | ------- | ---------- |
| tests | **What** does the code do? | the code |
| `docs/adr/<theme>.md` | **Why** is it built this way? | themes — a few broad ones, amended in place |
| the README, and `.claude/skills/` | **How** do I run, set up or operate it? | commands; one skill per procedure |
| GitHub issues | What is still open? | the tracker, not the repository |
| `docs/SECURITY.md` | How are secrets handled? | — |

- **Decision records are themed.** A decision amends the record that owns its theme; it never opens a new file. The superseded reasoning moves to the theme's decision-log issue, and git keeps the text. `docs/adr/decision-records.md` records why — one project using this workflow reached 64 per-decision records in three months before consolidating them into thirteen themes.
- **Inputs are deleted when what they produced ships** — briefs, backend designs, reviews.
- **Themes are drawn wide, and named rather than numbered.** A new record argues why no existing theme fits; nothing counts the files or their lines, because a count cannot tell a broad theme from a narrow one.

### 4. The delivery pipeline — required at user level

Work ships through one pipeline on the issue tracker: **plan, build, review, fix, close, release.** Its skills and workflows are **required at user level and never shipped in this package**: a copy per project drifts, and the pipeline works the same across projects and trackers (GitHub Issues or Jira). The tracker is the only record of what is planned and what is done; nothing in the pipeline writes a plan or a status file to the repository.

**The contract** — what holds whoever runs the step:

- **A plan is a marked section of the epic's description**, replaced in place when the design or the order changes.
- **Every ticket and every pull request opens with `## Sequence`:** the previous and the next, and the ticket's pull requests; the tracker's blocking link backs the order.
- **One worktree per ticket, one pull request per batch** of tickets; a person merges.
- **Review findings are pull request threads, each with a stable id,** plus one `QA:` comment on the ticket for what no line of the diff shows. A `QA:` comment is a correction a builder applies before its next commit, or rejects with a stated reason.
- **A ticket closes only with evidence:** each done-when line against a named test or a command's real output; a live check the agent cannot run goes to a person as exact commands.
- **A release versions from the Conventional Commit types** since the last tag into a CHANGELOG entry and an annotated tag whose message is that entry.

**An adopter without the pipeline follows that contract by hand.** Each command below states what it reads and what it leaves where, so a person can do the same step without it:

| | Reads | Leaves |
|---|---|---|
| `tracker-plan` | the confirmed plan, the tickets, the decision records | the epic's marked `Implementation plan` section; amended tickets and new sub-issues, each opening with `## Sequence` |
| `tracker-batch` (workflow) | the epic's plan and tickets, the gate `AGENTS.md` names | a worktree and branch per ticket, integrated onto one batch branch; one pull request for the batch, opening with `## Sequence`; after the merge, each ticket closed with evidence |
| `tracker-review` (skill, and a workflow for an epic or several repositories) | the pull request's diff, the ticket's done-when and tests | one review per pull request, an inline thread per finding labelled with a stable id; one `QA:` comment on the ticket |
| `tracker-fix` (workflow) | the unresolved threads and the `QA:` comments | one commit per finding, test first, naming its id, on the feature branch; stops before pushing, and a thread is resolved per pushed fix |
| `tracker-close` | the ticket's done-when lines, the tests, the commands' output | the proven lines ticked, a comment in fixed fields, the ticket closed only when every line holds; live checks handed to a person |
| `tracker-release` | the Conventional Commit types since the last tag | a CHANGELOG entry in the file's own shape, one release pull request or direct commit, an annotated tag whose message is the entry; no issue |
| `tracker-amend` | new requirements raised on near-ready work, the current ticket | the new scope written into the ticket or epic that owns it, for a clean session to build; the current pull request finishes only its own ticket |
| `tracker-pause` | the branch, the uncommitted files, any running workflows | a "Where I stopped" section of the in-progress ticket's description, replaced on every pause; each workflow's branches pushed and its relaunch recorded |
| `tracker-resume` | the pause note, the tracker, git | nothing: a brief, the mismatches between the note and the branch, and the one next action |
| `tracker-roadmap` | the roadmap issue, its epics and their tickets | the roadmap issue's phase order and each epic's `## Sequence`; shipped tickets labelled `live-check`; finished epics closed with evidence; audit findings as tickets under one Housekeeping epic |
| `tracker-audit` (workflow) | shipped code, subsystem by subsystem | nothing in the code: the confirmed findings in one file, which `tracker-roadmap` files as tickets |
| `workflow-orchestration` | the user-level workflow scripts, a run's journal | a run launched by script path; a correction as a `QA:` comment on the ticket, never a message to a running agent; merging and publishing kept with the orchestrator |

**Where each phase of the work lives:**

```
  Plan      research, then /tracker-plan            -> the epic's description
  Build     tracker-batch, one worktree per ticket   -> one pull request per batch
  Verify    the ticket's own procedure, lower levels first; a live check goes to a person
  Review    tracker-review                           -> PR threads + one QA: note
  Fix       tracker-fix, a commit per finding        -> a thread resolved per pushed fix
  Close     /tracker-close; amend the theme's record; brief-closer deletes a shipped brief
  Release   /tracker-release                         -> CHANGELOG entry + annotated tag
  Resume    /tracker-resume; /tracker-pause before stopping; /tracker-amend for new scope
```

Left open: the pipeline goes under `apm.yml`'s `dependencies.apm` once it is published as a public APM package; until then each person installs it at user level.

### 5. Claude Design — where the design comes from

**Claude Design is the first stage of the workflow, and `AGENTS.md` enforces it: you do not hand-build UI without a design.** The [`design-handoff`](.apm/skills/design-handoff/SKILL.md) skill is the procedure.

- **Design content lives in `<project>-ds`**, a sibling repository — briefs, the pages Claude Design returns, and a mirror of its export. It grows without bound, and an application repository carrying it stops being code.
- **A page draws the surface, never the application.** Every state of a screen on one page, reached through a state switcher and animated where it helps — but no validation, save rule or data model, because the application changes and the page does not. A sentence someone could find false in the running application comes out.
- **Every design repository has one layout** — `briefs/`, `pages/` or `system/` for the export, `references/`, `dist/`, `bin/sync` — whether it holds a product's design or a shared design system; [`layout.md`](.apm/skills/design-handoff/layout.md) states it folder by folder.
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

A template only gets better if the improvements people discover while *using* it flow back. `.apm/skills/template-feedback/SKILL.md` is that return path: when an agent (or you) finds a **reusable, project-agnostic** improvement to the workflow — a rule that should exist in `AGENTS.md`, a skill step that misfires, a docs-taxonomy gap — the skill surfaces a concrete proposal and, on your OK, opens a GitHub **issue on this template repo** so every adopter inherits the fix. It never edits the template silently, and it's scoped to *generalizable* improvements (project-specific rules stay in that project's `AGENTS.md`). `AGENTS.md` primes agents to reach for it — the "raise the hand" rule under **Improving this workflow**.

### 10. Skills and agents — what ships, and what to create

A procedure an agent follows is a skill: its body loads only when invoked, so it costs nothing on the tasks that do not need it. The workflow uses three kinds: the package shipped here, the delivery pipeline required at user level (§4), and optional user-level skills.

**Shipped here** — generic, as an [APM](https://github.com/microsoft/apm) package in `.apm/`. A project depends on it in its own `apm.yml`, and `apm install` deploys the skills to `.claude/skills/` and the agents to `.claude/agents/`; `apm.lock.yaml` pins the commit, and `apm update` takes a newer one. Nothing in the package names the project: what it needs to know about one, it reads from that project's `AGENTS.md`.

| | Does |
|---|---|
| `design-repo` | creates a design repository from one skeleton, in the layout every design repository keeps, and adopts the layout check in an existing one |
| `design-handoff` | the Claude Design procedure: which repository is which, how a design repository is laid out, the three routes into the project, writing a brief, reading an export back |
| `adopt-designs` | reads what the design project published — vendors the one generated bundle, reports what moved by selector, triages it — and hands the adoption to `design-curator` and any satisfied brief to `brief-closer` |
| `adopt-shared-release` | lands a shared design system's release in a product: moves the pin, fixes what the release removed, and deletes a stand-in only once the product's design-system copy is current |
| `template-feedback` | proposes a reusable workflow improvement as an issue on this template |
| `design-curator` (agent) | adopts a design that has shipped: deletes the application's copies of what the bundle now provides, and writes the components it ships but the application never uses |
| `brief-closer` (agent) | closes a brief once its surface ships, verifying each ask before deleting anything |

**The delivery pipeline, at user level** — the commands §4 lists, installed once per person and shared by every project (for instance a personal APM package installed with `apm install -g`), never copied into each one.

**Optional, at user level** — useful beside the pipeline, and nothing in it depends on them:

| | Does |
|---|---|
| `deps-upgrade` | lands a backlog of dependency pull requests: audits the lock, sorts by risk, batches the safe ones through the real gate |
| a knowledge-capture skill | files a reusable, project-agnostic lesson into a notes repository, so it outlives the project that taught it |

## Applying the template to a new project

### 1. Create the repository

```bash
# from this template, private unless it is meant to be public
gh repo create <owner>/<project> --template dsaenztagarro/agent-sdlc --private --clone
cd <project>
```

### 2. Fill in `AGENTS.md`

Replace every `<!-- FILL: … -->` marker — the project overview, the gate commands, the architecture map, the project's own rules — and delete the sections that do not apply, such as the design workflow for a headless service.

```bash
# list the placeholders still to fill
grep -n 'FILL' AGENTS.md
```

### 3. Keep `CLAUDE.md` as `@AGENTS.md`

### 4. Install the package

`apm.yml` records `claude` as the target, so every developer's `apm install` deploys to `.claude/`. Commit what it deploys, so a clone has the skills without APM.

```bash
# drop the template's own package
rm -rf .apm apm.yml
# declare the project's package, deploying to Claude Code
apm init --yes --target claude
# depend on a pinned release of the shared skills and agents
apm install dsaenztagarro/agent-sdlc#v<version>
# commit the manifest, the lock and what it deployed
git add apm.yml apm.lock.yaml .gitignore .claude/
git commit -m "chore: install agent-sdlc"
```

### 5. Open a decision log per theme

Name the first themes in `docs/adr/README.md` as the first decision in each area is made; each gets one `decision-log` issue, so `gh issue list --label decision-log` finds every theme's history.

```bash
# once per repository
gh label create decision-log
# once per theme
gh issue create --label decision-log --title "decision-log: <theme>" --body "History of docs/adr/<theme>.md"
```

### 6. Create the design repository, for a UI

Run the `design-repo` skill, and fill in the names in `AGENTS.md`'s design section, which `design-handoff` reads. Without a UI, delete that section.

### 7. Copy the local settings

```bash
# the real file is git-ignored; adjust it after copying
cp .claude/settings.local.json.example .claude/settings.local.json
```

### 8. Install the delivery pipeline at user level

Install the commands §4 lists if you do not have them yet; without them, follow §4's contract by hand.

## Layout

```
.
+-- AGENTS.md                          the rules every agent reads (fill in the placeholders)
+-- CLAUDE.md                          -> @AGENTS.md
+-- apm.yml                            the APM package an adopter depends on (an adopter replaces it with its own)
+-- .apm/                              the package's contents; an adopter deletes it and installs the package
|   +-- agents/
|   |   +-- brief-closer.agent.md      closes a brief once its surface ships
|   |   +-- design-curator.agent.md    adopts a shipped design: the app's copy goes, the design's class gets written
|   +-- skills/
|       +-- adopt-designs/SKILL.md     vendors the design's one bundle, triages it, hands adoption to design-curator
|       +-- adopt-shared-release/SKILL.md lands a shared design system's release, stand-ins last
|       +-- design-handoff/SKILL.md    the Claude Design procedure
|       +-- design-handoff/layout.md   how a design repository is organised, folder by folder
|       +-- design-repo/SKILL.md       creates a design repository from skeleton/, held to the layout by its layout_test.rb
|       +-- template-feedback/SKILL.md raise reusable workflow improvements upstream
+-- .claude/
|   +-- settings.local.json.example    committed template; the real file is git-ignored
+-- docs/
    +-- SECURITY.md                    secret and key handling
    +-- adr/                           one record per theme, named for it
```

## License

[MIT](LICENSE) © David Saenz
