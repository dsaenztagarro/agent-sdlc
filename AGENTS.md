# AGENTS.md

Instructions for AI agents working on this codebase. This file holds only what applies to **every** task — the rules an agent can break before it knows they exist — and a routing table to the rest. A procedure is a skill in `.claude/skills/`, loaded when it is invoked; a rule for one kind of file is a path-scoped rule in `.claude/rules/`, loaded when a matching file is opened.

> This file is a **template**. Replace every `<!-- FILL: … -->` with your project's specifics and delete any section that doesn't apply. The principle sections (documentation, design workflow, development workflow) are portable as-is, and so is the testing rule in `.claude/rules/testing.md` once its `paths:` is filled.

## Where the rest of the instructions live

| when you are… | load | how it fires |
|---|---|---|
| writing or changing a test, or building a component that holds state | `.claude/rules/testing.md` | opening a file its `paths:` names, which you fill |
| planning multi-ticket work, or building, reviewing, fixing, closing or releasing its tickets | the user-level tracker pipeline: `/tracker-plan`, `tracker-batch`, `tracker-review`, `tracker-fix`, `/tracker-close`, `/tracker-release` | invoke it |
| stopping, resuming, or taking new scope on near-ready work | `/tracker-pause`, `/tracker-resume`, `/tracker-amend` | invoke it |
| handing a design to Claude Design, or reading one back | the `design-handoff` skill | invoke it |
| raising a workflow improvement upstream | the `template-feedback` skill | invoke it |

The tracker pipeline is required at user level, never shipped in the agent-sdlc package. Without it, follow [its contract](https://github.com/dsaenztagarro/agent-sdlc#the-delivery-pipeline-at-user-level) by hand: what each step reads, and what it leaves where.

A path-scoped rule fires only when a matching file is read, so a rule that must hold before any file is opened stays in this file.

## Improving this workflow

This project runs on the [agent-sdlc](https://github.com/dsaenztagarro/agent-sdlc) template. A reusable, project-agnostic improvement to the workflow itself goes upstream through the `template-feedback` skill, as one checklist item on the template's open feedback issue; a project-specific rule stays here.

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

- **Decision records** live in `docs/adr/` — **a few broad themes, one record each, amended in place.** A decision amends the record that owns its theme; it never opens a new file. A decision that fits no theme is the maintainer's call — stop and ask. The bar, the themes and the procedure are in [`docs/adr/README.md`](docs/adr/README.md); the reasoning is [`docs/adr/decision-records.md`](docs/adr/decision-records.md). **A decision's history** is the record's git log: `git log -p docs/adr/<theme>.md`.
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
- **Vendor command:** <!-- FILL: the command that vendors the artefact under the stamp `adopt-designs`' vendor contract states -->
- **Triage command:** <!-- FILL: the command that reads the vendored artefact against the application (a bundle against the markup and the styles that read its custom properties, a token set against the code that reads its names) and edits nothing -->
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
  <project>-ds  (design repository)             <project>  (this repository)
  owns how a surface LOOKS and is COMPOSED      owns how it BEHAVES
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

- **A design page shows the surface, never the application's rules.** Validations, save rules, time windows and the data model are not drawn. The test for a sentence on a page: could someone open the running application and find it false? The design project's own `readme.md` carries the rule.
  - *Web:* interaction is drawn — a drawer opening, a row expanding.
  - *Terminal:* snapshots only, one named frame per state; the key map is the application's behaviour, and stays out of the page.
- **Build to the page, with the vendored artefact only.**
  - *Web:* no colour, spacing or component outside the artefact's cascade layer, the classes it owns and the classes the shared system's package ships.
  - *Terminal:* no colour or glyph outside the vendored token set, the shared system's tokens, the user's overrides and the renderer's defaults; a full-screen interface degrades to the line renderer.
- **Never work around a design defect in the application.** Write the design as it ships, and raise the defect in the same change, as the validation rule below routes it. A state the design cannot show yet is said in content, never in style.
- **A page's markup and styles are what it specifies; its prose is intent.** Prose that contradicts its own markup is surfaced, never implemented.
- **When a local restatement and the canonical shared system disagree, the canonical one wins.**
- **Application labels use the full canonical noun** the design names a thing by.
- **Before writing a style, search both design projects by name, shape and value.** Search for what the thing is, not the name you were about to type. If neither draws it, brief it, with no local stand-in meanwhile.
- **Never hand-edit the design mirror or the vendored artefact.** Both are generated, and the next sync or vendor destroys the edit without an error. This rule lives here because the mirror is in another repository, where nothing in this one fires.
- **Read a design in its own checkout**, at the revision being built against, never from a copy.
- **Code never cites a design page or a brief**, in any form — a path, a section label, or the same thing in words. A page regenerates and a brief is deleted; cite the decision record for *why* and the test for *what*.
- **Validate the design against the codebase before building — raise the hand if it's wrong.** If it brings consistency, build it faithfully. If it does **not**, neither implement it silently nor diverge from it silently: a **comment** on the ticket for something localised, a **brief** in the design repository for something structural.
- **A behaviour a page draws that nothing here has settled is an open question**, answered by a test and, where it is a real fork, the theme's decision record — then sent back through a brief.

If this project has no UI, or its UI takes all its colours from its host — a multiplexer plugin drawing in the host theme's levels, a command line on the terminal's ANSI slots — delete this section, and record why in the theme's decision record, with the condition that reopens it.

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

**One coherent change is the unit of work:** one branch, one pull request, sized for one review. Related findings from one analysis ship together, never as a ticket each.

1. **Open an issue only for work someone will build later.** Work done now needs none: the pull request states the problem.
2. **Branch from a freshly fetched default branch, in a worktree of its own:** `git fetch origin`, then `claude --worktree <slug>`. Two agents never share a checkout — they race on HEAD. A worktree gets the untracked files it needs — local keys, a `.env` — through `.worktreeinclude`.
3. **Implement and test:** tests alongside the change, the gate run often, and a change with a runtime surface driven and observed before it is called done, since passing tests are necessary, not sufficient.
4. **Record decisions:** a decision that clears the bar amends its theme's record in `docs/adr/`.
5. **Open the pull request** with `gh pr create`, closing any issue it finishes; merge with `gh pr merge --squash` once the gate is green.

Every ticket and every pull request **opens with `## Sequence`**, one reference per line: a ticket names the previous ticket, the next and its pull requests; a pull request names its ticket, if any, the previous pull request and the next.

A pull request:

- **Has a Conventional Commit title:** `<type>(<scope>)!: <subject>`, with a sentence-style subject after the type. `.github/workflows/pr-title.yml` checks it, and the repository squashes with the PR title as the commit subject, so the release is versioned from what was reviewed.
- **Compares with the base branch:** what the code did before and why that was wrong, never an earlier revision of the branch, which its reader never saw.
- **Carries the evidence in its body:** the gate's output, the mutation checks, how to test it. Nothing is mirrored back to an issue.

**The CHANGELOG follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),** each release opening with a lead paragraph on what it brings, before its lists.

Work too large for one review is planned with the tracker pipeline (see the routing table): the plan is a marked section of one parent issue, and a batch of its tickets ships as one pull request.

### Incidental minor findings → the `chore` accumulator

A **minor, unrelated** defect noticed while doing a task — a stale label, a typo, a dead file — is neither fixed inline nor given an issue of its own: it joins one rolling list.

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
