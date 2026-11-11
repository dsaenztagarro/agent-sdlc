# AGENTS.md

Instructions for AI agents working on this codebase. This file holds only what applies to **every** task — the rules an agent can break before it knows they exist — and a routing table to the rest. A procedure is a skill in `.claude/skills/`, loaded when it is invoked; a rule for one kind of file is a path-scoped rule in `.claude/rules/`, loaded when a matching file is opened.

> This file is a **template**. Replace every `<!-- FILL: … -->` with your project's specifics and delete any section that doesn't apply. The principle sections (model selection, documentation, testing, design workflow, development workflow) are portable as-is.

## Where the rest of the instructions live

| when you are… | load | how it fires |
|---|---|---|
| <!-- FILL: writing or changing a test --> | <!-- FILL: `.claude/rules/testing.md` --> | <!-- FILL: opening `test/**` --> |
| planning multi-ticket work, or building, reviewing, fixing, closing or releasing its tickets | the user-level tracker pipeline: `/tracker-plan`, `tracker-batch`, `tracker-review`, `tracker-fix`, `/tracker-close`, `/tracker-release` | invoke it |
| stopping, resuming, or taking new scope on near-ready work | `/tracker-pause`, `/tracker-resume`, `/tracker-amend` | invoke it |
| handing a design to Claude Design, or reading one back | the `design-handoff` skill | invoke it |
| raising a workflow improvement upstream | the `template-feedback` skill | invoke it |

The tracker pipeline is required at user level, never shipped in the agent-sdlc package. Without it, follow [its contract](https://github.com/dsaenztagarro/agent-sdlc#4-the-delivery-pipeline--required-at-user-level) by hand: what each step reads, and what it leaves where.

A path-scoped rule fires only when a matching file is read, so a rule that must hold before any file is opened stays in this file.

## Model selection & task tracking

Every task you plan or pick up carries an explicit **complexity** rating and the **model** it runs on — state both (`complexity · model · why`) in the plan, the parent ticket, or the task list so the choice is deliberate and reviewable, not implicit. When you decompose work, tag each piece; don't leave the model a running default nobody chose.

- **Default to the most capable model.** Correctness-critical, interdependent, or context-heavy work — schema/data changes, multi-file refactors, anything where a subtle mistake compounds across the change — stays there even when it is large. Delegating hard work to a cheaper run because it's tedious is a false economy.
- **Escalate to a cheaper/faster model only when the complexity genuinely pays off there** and the task isn't the correctness-critical / interdependent / context-heavy kind above. When it's a close call, stay on the capable model.
- **Record the call, one clause of why.** e.g. `complexity: complex · model: <capable> · why: interdependent state machine`. The rating is about consequence and coupling, not line count.

## Improving this workflow (raise the hand)

This project runs on the [agent-sdlc](https://github.com/dsaenztagarro/agent-sdlc) template. When you discover a **reusable, project-agnostic** improvement to the workflow itself — a rule that should exist here, a skill step that misfires, a docs-taxonomy gap, a principle worth stating — don't silently apply it only to this repo. **Raise the hand:** run the **`template-feedback`** skill (`.claude/skills/template-feedback/`) to surface a concrete proposal and, on the maintainer's OK, open an issue on the upstream template so every adopter benefits. Keep project-specific rules in this repo; send generalizable ones upstream.

## Project Overview

<!-- FILL: 2-3 sentences — what this project is, who uses it, the core domain. Link the README. -->

## Tech Stack

<!-- FILL: language(s), framework(s), datastore, key libraries, deploy target. -->

## Common Commands

<!-- FILL: the real commands. These are what the test/lint gate and the tracker pipeline rely on. -->

```bash
# build:   <!-- FILL -->
# test:    <!-- FILL -->
# lint:    <!-- FILL -->
# run:     <!-- FILL -->
```

## Architecture

<!-- FILL: the mental model in a paragraph, then a "Key files" list mapping subsystems to paths. -->

## Documentation Conventions

- **Decision records** live in `docs/adr/` — **a few broad themes, one record each, amended in place.** A decision amends the record that owns its theme; it never opens a new file. A decision that fits no theme is the maintainer's call — stop and ask. The bar, the themes and the procedure are in [`docs/adr/README.md`](docs/adr/README.md); the reasoning is [`docs/adr/decision-records.md`](docs/adr/decision-records.md). **A decision's history** is on its theme's decision-log issue: `gh issue list --label decision-log --state all` lists every one.
- **Tests are the specification.** What the code does is stated by tests named for the rules they hold. Before writing a behaviour rule in prose, name the test that would fail if it were broken — then write that test and stop. A test states what the product does, never what the repository contains: that a file exists, a document has a section, or a folder holds fewer than some number of files specifies nothing, and review holds it.
- **How to run, set up or operate it** is a command in the README; a multi-step procedure an agent follows is a skill in `.claude/skills/`, loaded when it is invoked.
- **An input is deleted when what it produced ships** — a brief, a backend design, a review. Its durable half moves to a record, a test or an issue first.
- **Never a document per work item.** A generator that writes one file per decision, feature, ticket or brief is a defect.
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

**Do not hand-build UI without a design.** Design content — briefs, the pages Claude Design returns, the export mirror — lives in the **`<project>-ds`** design repository, and exactly one generated artefact crosses into this one. The procedure, and the three routes into the Claude Design project, are the [`design-handoff`](.claude/skills/design-handoff/SKILL.md) skill.

### The names the design skills read

The `design-handoff`, `adopt-designs` and `adopt-shared-release` skills and the `design-curator` and `brief-closer` agents read these names and no others. One name per line; write `none` for one that does not apply. A name missing here is asked for, never guessed.

- **Design repository:** <!-- FILL: its name, `<project>-ds` -->
- **Design checkout:** <!-- FILL: its path on disk -->
- **Regenerate command:** <!-- FILL: the command, run in the design checkout, that regenerates the artefact -->
- **Design suite:** <!-- FILL: the design repository's test command -->
- **Artefact form:** <!-- FILL: `stylesheet bundle` or `token set` -->
- **Artefact source:** <!-- FILL: its path in the design repository -->
- **Artefact vendored at:** <!-- FILL: its path here, or `nothing is vendored yet` and why -->
- **Cascade layer:** <!-- FILL: the layer the bundle is loaded in; `none` for a token set -->
- **Vendor command:** <!-- FILL: the command that vendors the artefact and pins the revision it read -->
- **Triage command:** <!-- FILL: the command that reads the vendored artefact against the markup and edits nothing -->
- **Own component styles:** <!-- FILL: where this application's own component styles live -->
- **Shared design system:** <!-- FILL: the system this design extends, or `none` -->
- **Shared system channel:** <!-- FILL: the package that brings it here; it never arrives through this application's design repository -->
- **Shared system checkout:** <!-- FILL: an environment variable and its default, `$<VAR>` (default `<path>`) -->
- **Shared release ref:** <!-- FILL: the ref of its repository that a released version corresponds to -->
- **Shared release notes:** <!-- FILL: where it publishes them -->
- **Pin command:** <!-- FILL: the command that moves the shared system's pin and nothing else -->
- **Token sync command:** <!-- FILL: the command that syncs its tokens, or `none` -->
- **Decision records:** <!-- FILL: where they live, `docs/adr/` -->

### Who owns what

```
  <project>-ds  (design repository)            <project>  (this repository)
  owns how a surface LOOKS and is COMPOSED     owns how it BEHAVES
  +----------------------------------+          +-------------------------------------+
  | briefs/proposed/                 |          | code                                |
  | pages, components, tokens        |   one    | tests               -> what         |
  | the export mirror   (generated)  | -------> | decision records    -> why          |
  | the artefact's generator         | artefact | the vendored artefact (generated)   |
  +----------------------------------+          +-------------------------------------+
                 ^                                                 |
                 |                                                 |
                 +-------------------- briefs ---------------------+
```

Claude Design ships surface only; the last rule below says where a behaviour it draws is decided.

### The rules

- **A design page shows the surface, never the application's rules.** Interaction is drawn; validations, save rules, time windows and the data model are not. The test for a sentence on a page: could someone open the running application and find it false? The design project's own `readme.md` carries the rule.
- **Build to the page, with the vendored artefact only.**
  - *Web:* no colour, spacing or component outside the artefact's cascade layer, the classes it owns and the classes the shared system's package ships.
  - *Terminal:* no colour or glyph outside the vendored token set, the shared system's tokens, the user's overrides and the renderer's defaults; a full-screen interface degrades to the line renderer.
- **Never work around a design defect in the application.** Write the design as it ships, and brief the defect in the same change. A state the design cannot show yet is said in content, never in style.
- **A page's markup and styles are what it specifies; its prose is intent.** Prose that contradicts its own markup is surfaced, never implemented.
- **When a local restatement and the canonical shared system disagree, the canonical one wins.**
- **Application labels use the full canonical noun** the design names a thing by.
- **Before writing a style, search both design projects by name, shape and value.** Search for what the thing is, not the name you were about to type. If neither draws it, brief it, with no local stand-in meanwhile.
- **Never hand-edit the design mirror or the vendored artefact.** Both are generated, and the next sync or vendor destroys the edit without an error. This rule lives here because the mirror is in another repository, where nothing in this one fires.
- **Read a design in its own checkout**, on its default branch, never from a copy.
- **Code never cites a design page or a brief**, in any form — a path, a section label, or the same thing in words. A page regenerates and a brief is deleted; cite the decision record for *why* and the test for *what*.
- **Validate the design against the codebase before building — raise the hand if it's wrong.** If it brings consistency, build it faithfully. If it does **not**, neither implement it silently nor diverge from it silently: a **comment** on the ticket for something localised, a **brief** in the design repository for something structural.
- **A behaviour a page draws that nothing here has settled is an open question**, answered by a test and, where it is a real fork, the theme's decision record — then sent back through a brief.

If this project has no UI, or its UI takes all its colours from its host — a multiplexer plugin drawing in the host theme's levels, a command line on the terminal's ANSI slots — delete this section, and record why in the theme's decision record, with the condition that reopens it.

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

This stays an every-task rule rather than a path-scoped one: a fact can be read from any file, so no path pattern would fire before the fallback is written.

## CI / gate

<!-- FILL: what must be green before a change ships (tests, lint, security scan) and where it runs.
     The tracker pipeline defers to this gate. -->

**The local gate is the gate.**

- **Check it is installed and runnable before building** — its hooks are in place and its command runs — and never pass `--no-verify`.
- **Report a gate's result only by quoting the output seen in that run.** A hook that is not installed did not pass.

Rules that depend on the project's tooling, each a `FILL` with its rule beside it:

- **Formatter on write:** <!-- FILL: the formatter command --> — runs on each file as it is written, through the format-on-write hook in `.claude/settings.local.json.example`.
- **Commit and push hooks:** <!-- FILL: what each hook runs, and how it is installed --> — a hook verifies and never rewrites: a hook that changes files commits what nobody reviewed.

## Development Workflow

**One coherent change is the unit of work:** one issue, one branch, one pull request, sized for one review.

1. **Open one issue for the change:** the problem, the done-when lines, the technical notes. Related tickets from one analysis are one issue, and the triage and review rows it produces stay inside it as checklist items, never a ticket each.
2. **Branch from a freshly fetched default branch**, in the issue's own worktree: `git fetch origin` first, then `claude --worktree issue-<issue>` checks out `.claude/worktrees/issue-<issue>`, and the same command re-enters it later. `git log origin/<default>..HEAD` prints nothing before the first commit, so no unpushed local commit rides into the squash. Two agents never share a checkout — they race on HEAD.
3. **A worktree gets the untracked files it needs** — local keys, a `.env` — through `.worktreeinclude`, never by copying them by hand.
4. **Check the branch name on the remote before the first push:** rename the branch to `<issue>-<slug>`, and `git ls-remote --heads origin <branch>` prints nothing, so the push cannot land on a branch an existing pull request uses.
5. **Implement & test** — write tests alongside the change; run the gate frequently; drive the runtime surface.
6. **Record decisions** — a decision that clears the bar amends its theme's record in `docs/adr/`.
7. **Open a PR** with `gh pr create`, body ending `Closes #<issue>`; merge with `gh pr merge --squash` once the gate is green.

Every ticket and every pull request **opens with `## Sequence`**, one reference per line: a ticket names the previous ticket, the next and its pull requests; a pull request names its ticket, the previous pull request and the next.

A pull request:

- **Has a Conventional Commit title:** `<type>(<scope>)!: <subject>`, with a sentence-style subject after the type. `.github/workflows/pr-title.yml` checks it, again whenever the title is edited, and the repository squashes with the PR title as the commit subject, so the release is versioned from what was reviewed.
- **Compares with the base branch:** what the code did before and why that was wrong, never an earlier revision of the branch, which its reader never saw.
- **Carries the evidence in its body:** the gate's output, the mutation checks, how to test it. The issue gets no copy of it: the closing reference closes the issue, and the close step ticks each done-when line against the evidence the pull request holds.

**The CHANGELOG follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),** each release opening with a lead paragraph on what it brings, before its lists.

Work planned across several tickets is the one exception to the unit above, and is planned and built with the tracker pipeline (see the routing table): the plan is a marked section of the parent issue's description, each ticket gets its own worktree, and a batch of tickets ships as one pull request.

### Incidental minor findings → the `chore` accumulator

While doing a task you'll notice **minor, unrelated** defects — a stale label, a typo, a dead file, a tiny inconsistency — out of scope for what you're shipping. Don't fix it inline (bloats an unrelated diff), don't drop it (it's lost), and don't open a dedicated issue for a one-line fix (pure ceremony). Instead capture it in one rolling paper-cuts list and keep working.

One open **`chore`**-labelled issue pools these. Find it, append the finding, move on:

```bash
gh issue list --label chore --state open        # find the open accumulator
# none yet? create the label once, then the issue.
```

Append **one self-contained `- [ ]` item per finding** — enough for a later run to fix it without rediscovery: `file:line` — the symptom — the fix — provenance (found while doing #NNN).

- **Belongs here:** minor, unrelated, low-urgency paper cuts.
- **Does not:** a real bug or security issue gets its **own** issue — don't bury it in the list.
- **Already in your blast radius:** a trivial fix in a file you're *already* editing just gets fixed and reported as a distinct change; the accumulator is only for what's **out of scope**.

When worth a pass, the list ships as **one** PR that closes many items at once.
