# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.3] - 2026-11-12

A width is a frame, drawn once per project, never a state on every page, and no page is drawn again without colour.

### Changed

- **`design-handoff` §4 states that a width is a frame, never a state.** Every page draws at the default width. One Layout page per project shows how each surface recomposes at the others, one family per width, so a page's state bar lists only its situations.
- **`design-handoff` §4 states that no page is drawn again without colour.** The token set's check that no two states share a glyph holds what a monochrome copy was meant to show.

## [1.0.2] - 2026-11-12

A shared system's standing rules, and what each token is for, each have one home outside the briefs.

### Changed

- **`design-handoff` §2 says where a standing rule and a token's purpose live.** A shared system's rules reach each linked Project through the readme in its `_ds/` copy, and the Project's own readme points at them. What a token is for is written beside its definition in the token file the project holds. A brief restates neither.

## [1.0.1] - 2026-11-12

A comment fix in the skeleton.

### Fixed

- **The skeleton's `shots_test.rb` header no longer describes the family-ordering refusals** that v1.0.0 removed.

## [1.0.0] - 2026-11-12

The template keeps only the rules and checks that pay for themselves. One coherent change is one pull request, with no issue required for work done now and no issue per idea upstream. Decision records keep their history in git rather than in a tracker issue per theme. The design-repository skeleton drops the checks that tested repository housekeeping or listed forbidden spellings, serves pages with the standard library, and runs its gate on every pull request. Each design repository adopts this skeleton in one pull request.

### Changed

- **One pull request per coherent change.** `AGENTS.md`'s development workflow opens an issue only for work someone will build later, and drops the branch-renaming and remote-check steps. `## Sequence` stays.
- **A decision record's history is its git log.** `docs/adr/` drops the `decision-log` issue per theme, its label and its procedure; the amendment's commit message says what changed and why.
- **`template-feedback` appends one checklist item to the template's open feedback issue**, never an issue per idea.
- **The pull request title check is `amannn/action-semantic-pull-request`**, in place of a hand-written script and its tests.
- **The skeleton's `bin/serve` is `python3 -m http.server`**, and its `Gemfile` holds only `minitest` and `rake`.
- **The skeleton's CI runs `rake` on every pull request and push**, not weekly.
- **A brief's commit is `docs(briefs): …`**, a Conventional Commit type.
- **The README states the template once**, leaving procedures to the skills and rules to `AGENTS.md`.

### Removed

- **The `complexity · model · why` tag on every task.**
- **`layout_test.rb` and `layout_check_test.rb`.** They tested where folders sit in a design repository, which review holds; `bin/sync` already refuses an export of the other kind.
- **`bin/stand-ins`.** A stand-in is found by its marker and has landed once both manifests list its component.
- **`bin/sync`'s refusal of a page whose file name looks versioned**, a list of forbidden spellings that the next variant walks past.
- **`bin/shots`' family-ordering refusals** — a split family, a bare family not first, a state repeating its family.
- **`brief-closer`'s tracker steps:** a tracking issue per ask, ticking the epic, and retiring guard exemptions.
- **The vendor contract's five mandated test names**, replaced by what the tests must cover.

## [0.7.0] - 2026-11-12

A check now has to earn its place. The testing seed states the rule, that a check earns its place by the realistic mistake that fails it, named beside it, and the design skills and agents that write checks point at it. The design-repository skeleton's layout check keeps only the checks a real mistake fails.

### Added

- **The testing seed states when a check earns its place.** `.claude/rules/testing.md` opens with `## Whether a check earns its place`: a check is written only for a realistic mistake that fails it, and names that mistake beside it. A check on what the project only copies from another project its maintainers can commit to lives in that project. What arrives from a source no one here can check, such as a generator's export, is checked at the first boundary the project owns. A check that restates a runtime guard is not written, while a test that proves the guard fires is. A check red on a goal state of the lifecycle is a defect, and one that scans the prose of documents is not written. The `design-repo` skill's tests for a generator's refusals and guarantees, `design-handoff`'s layout check, and the guards `design-curator` writes all point at the rule. (#66)

### Removed

- **Three layout checks that no realistic mistake in a design repository fails.** `layout_test.rb` drops the check that no 80-character line repeats across two open briefs, which failed a repository whose own procedure requires every brief to open with the same preamble. It also drops the check on the `vendor/` folder's name, which only a vendoring script writes, and the check that `bin/sync` names its kind, which `bin/sync` already refuses on its first run. `layout_check_test.rb` loses their cases, and `layout.md` lists only the closed rules the check still holds. The rule that a standing rule never goes in a brief stays as guidance. (#65)

## [0.6.0] - 2026-11-11

The delivery pipeline becomes a contract rather than a shipped copy, and `AGENTS.md` states the delivery rules every task needs, with a CI check that holds pull request titles to Conventional Commits so a release can be versioned from what was reviewed. Its design section becomes the one block of names the design skills read, and states each design rule with a web and a terminal form where they differ. `adopt-designs` reads a token set as well as a stylesheet bundle, under a vendor contract that ships with it, and a design repository keeps one open brief per theme, which `brief-closer` verifies and deletes in a fixed order. The design-repository skeleton catches up with the reference design repository: `bin/sync` refuses an incomplete export and compares an authored palette wherever it lives, the page contract reaches each state at its address, and `bin/serve` and `bin/stand-ins` join it. A request and a standing rule each keep their one home: an export carrying a note is refused, a promotion Design proposes is judged before the mirror is committed, and a rule repeated across briefs fails the layout check. A design repository states its Claude Design kind, in a skeleton split into a common part and one overlay per kind. The testing rules leave `AGENTS.md` for a path-scoped seed the adopter keeps, and gain the rules that decide whether a suite sees the defects that matter: locating by role, state as accessible state, invariants after every command, and stateful components built complete.

### Added

- **`adopt-designs` reads a token set by name as well as a bundle by selector, under a shipped vendor contract.** Steps 1-3 follow the artefact form `AGENTS.md` declares: what appeared, changed and disappeared is reported by selector or by token name, every disappearance flagged, and each triage finding marked guarded or `NO GUARD`; step 1 quotes the previous and new revision the vendor command prints and regenerates code generated from the artefact. `vendor-contract.md` beside the skill states, language-neutral, one writer and a stamp on every vendored file naming the design repository, the full revision and the SHA-256 of the bytes; three refusals, each message naming only what it checked; the adopter tests by name; and the four guard kinds in their web and terminal forms. `design-curator` gains a terminal section: a literal the token set names is replaced by the token, a missing token is a brief, and one golden frame per state holds composition only. (#39)
- **A CI check holds every pull request title to a Conventional Commit.** `.github/workflows/pr-title.yml` runs `.github/scripts/pr-title` on `<type>(<scope>)!: <subject>` whenever a pull request is opened, edited, pushed to or reopened, and names the expected form when it refuses one; `test/pr_title_test.rb` holds its rules. README's Applying steps gain the one command that squashes with the pull request title, so `/tracker-release` versions from what was reviewed. (#37)
- **The design-repository skeleton serves every page, and tracks each stand-in.** `bin/serve` serves the checkout from a real origin with an index walked on every request; it is a small Sinatra application, so the skeleton gains a `Gemfile`, and its index is an ERB template. `bin/stand-ins`, for a product bound to a shared system, reads each stand-in's stage — unrequested, requested, upstream, landed — from the shared system's open briefs and the two manifests, its shared checkout from the environment variable and default the application's `AGENTS.md` declares; `design-handoff` §5's landing steps name it. Each has its tests, and `layout.md`, the skeleton README and `design-repo` §3 know both. (#41)
- **A standing rule lives in the design project's `readme.md`, never in a brief, and the layout check holds it.** `layout_test.rb` fails when a line of 80 characters or more, outside the brief's header, appears verbatim in two open briefs, naming the line and the briefs; `test/layout_check_test.rb` runs it against throwaway briefs. The skeleton's `briefs/README.md`, `layout.md` and `design-handoff` §2 state the rule. (#57)
- **A promotion Design proposes is an input, and the publish step acts on it.** `design-handoff` §5 states that a proposed promotion is an input to the genericity test: one that passes amends the shared system's open brief for its theme with the stand-in's rules and names byte for byte and none of Design's steps, one that fails loses its marker and stays the product's. `adopt-designs` step 0 and the skeleton `AGENTS.md`'s publish procedure run `bin/stand-ins` after `bin/sync` and settle each `unrequested` stand-in before the mirror is committed. `design-repo` §5 seeds two more rules into the design project's `readme.md`: the project writes no request, note or plan into its files, and a stand-in's marker names the one PascalCase component the shared system will list it under. (#57)
- **The skeleton's `AGENTS.md` states the publish procedure** — sync, review the diff by rule and section, regenerate, `rake`, commit and push the mirror as produced with its defects named — **and three commit conventions:** `chore(designs): sync the export that …`, `brief(<theme>): …`, and `brief(<theme>): delete, drawn in the <sha> export`. (#41)

### Changed

- **A design repository keeps one open brief per theme, named for the theme and amended in place.** `layout.md`, the skeleton's `briefs/README.md`, `design-handoff` §5-§8 and `adopt-designs` add a request or a defect to its theme's brief, and a theme that landed partly or with a defect keeps its brief, listing only what remains, instead of a brief per request and a follow-up brief per defect. The skeleton's `briefs/README.md` gains a house format — a For, Produces, Do-not-edit and Status header, the problem first, jobs as outcomes, out of scope — and the reader rule. `brief-closer` triggers when an export lands, reads every path from `AGENTS.md`'s design section, and works in a fixed order: the vendored stamp at or past the satisfying export, citations re-pointed, guard exemptions retired, the tracking issue closed, the epic ticked, and the brief deleted last, in its own commit on a branch of the design repository. (#40)
- **The testing rules are a path-scoped seed, `.claude/rules/testing.md`, that the template ships and the adopter keeps.** Its `paths:` is a `FILL` for the globs of the tests and of the interactive components' source, and README §7 and Applying step 2 say so. Each rule is one sentence, with a web and a terminal form where they differ: real collaborators and a smoke test per interactive surface, as before; markup located by role and accessible name, then label, then visible text, with a class only inside a named test helper; a component's state read as the accessible state its role defines, or the rendered frame's text in a terminal; invariants checked after every command, in a few named journeys and one fixed-seed walk; a mutation check proving detection, not correctness; a source-invariant guard for a closed property; every reachable state of a stateful component legal, escapable and visible; no control hidden in reaction to a user action; and one implementation for a question two surfaces ask. It is not in the APM package because every `apm install` rewrites a deployed rule's `paths:` from the package. `AGENTS.md` loses its inline Testing Guidelines, so they no longer load in every session, its routing table names the seed, and driving a change's runtime surface stays in its development workflow. `template-feedback` routes a testing proposal to the seed rather than to `AGENTS.md`. (#42, #4, #5, #25)
- **A design repository states its Claude Design kind.** The skeleton is `common/` plus one overlay per kind, `project/` and `design-system/`, each with its own README, so the kind is visible in the files rather than in what `design-repo` §3 deletes. Every README opens with its kind — a Project and the Design System it is linked to, or a Design System — then the Claude Design content and the git wrapper around it, with no click-by-click Claude Design steps, since the standalone site closes on December 14, 2026. `design-repo` §1 decides the kind by one rule: a product's design is a Project linked to the shared Design System, and anything several applications share is a Design System in its own repository. `layout.md` lists what a Design System export holds, says `templates/` is starter layouts for linked Projects and never an application's pages, and drops the case of one repository holding both kinds. The layout check fails when `bin/sync` names no kind, or when the repository holds the other kind's export folder, letting a Project keep under `system/` only what `UPSTREAM` pushes up; `bin/sync`'s tests cover a Design System export carrying `templates/` and one refused by a Project's repository. Before, the kind lived only in one `sed` on `bin/sync`, and an application's design was uploaded as a Design System without anything noticing. (#32)
- **Adopting the layout in an existing design repository installs the skeleton's `bin/sync` and `sync_test.rb`**, not only `layout_test.rb`, and a refusal the old script had and the skeleton's lacks is raised on the template rather than kept in a local copy. (#32, #24)
- **`bin/sync` refuses an export carrying a note beside its pages.** Any Markdown file outside `_ds/` other than the project's own files in `PROJECT_FILES` — by default `readme.md`, `AGENTS.md` and `CLAUDE.md`, each a path or a pattern — is refused with nothing mirrored, and the message says where a request goes: the open brief of the repository whose project will draw it. Before, a request written into the export was mirrored, reached no brief, and could be deleted by the next export. (#57)
- **`bin/sync` refuses an incomplete export, and compares an authored file wherever it lives.** An export with no `_ds_manifest.json`, or missing a root file the repository lists in `REQUIRED_ROOT_FILES` — a web export's root stylesheet, nothing for a terminal client's — is refused with nothing mirrored. Authoring screenshots never cross, and a symlinked snapshot is replaced by the export's own. Each `UPSTREAM` entry is `<path in the repository>:<path in the export>`, so a product repository's palette authored under `system/` is compared with its export's copy, where the guard used to look only inside the export folder; `design-handoff` §3 and `layout.md` promise only what its test holds. (#41)
- **A page's states are reached at their addresses, and the family is read from the name.** A state is named `<Family> · <state>` and shown at `#state=<family>/<state>`; the State row's selected tab is labelled with the state's name; `[data-design-chrome]` is hidden in every shot, and a surface that scrolls inside the viewport is shot whole. No grouping attribute remains: `lib/shots.js`, its test, `design-handoff` §4 and `layout.md` state this contract, and `bin/shots` names a bare family that is not its family's first state. (#41)
- **The skeleton's new tests are named for their rules** with `test "…"`, defined in `test/test_helper.rb` — the sync, serve, shots and stand-ins tests — and the layout check names the `design-repo` skill as the one owner of the layout. (#41)
- **`AGENTS.md`'s Development Workflow states the delivery rules every task needs.** One coherent change is one issue, branch and pull request, with its triage and review rows inside it; the branch starts at a freshly fetched default branch and its name is checked on the remote before the first push; a worktree gets its untracked files through `.worktreeinclude`; every ticket and pull request opens with `## Sequence`; a pull request has a Conventional Commit title, compares with the base branch and carries the evidence in its body; the CHANGELOG follows Keep a Changelog with a lead paragraph per release. CI / gate states that the local gate is the gate — checked before building, never skipped, reported only by quoting its output — with `FILL` lines for the formatter and the commit and push hooks, which verify and never rewrite. "No fallbacks to legacy values" stays an every-task rule, with why. (#37)
- **`AGENTS.md`'s design section opens with a block of names, one per line, that the design skills and agents read and no others** — the design repository and its checkout, the artefact's form, source and vendored path (or nothing vendored yet, and why), the vendor and triage commands, the shared system with its package channel and its checkout as an environment variable, and where decision records live; `brief-closer` reads the last instead of assuming `docs/adr/`. An ASCII diagram draws who owns what: the design repository owns look and composition, the application behaviour, tests and records, and briefs flow back. The rules gain never working around a design defect, markup over prose, the canonical shared system over a local restatement, the full canonical noun, searching both design projects by shape before writing a style, never hand-editing the mirror or the vendored artefact, and reading a design in its own checkout; two rules gain a web form and a terminal form — a page draws interaction on the web and is snapshots only in a terminal, with the key map kept out, and building to the vendored artefact allows the artefact and the shared system's package on the web, and the token sets, the user's overrides and the renderer's defaults in a terminal. (#38)
- **A design repository is for a UI whose colours the product owns.** A surface that takes all its colours from its host needs none, and records why in its theme's decision record, in `AGENTS.md`, README's Applying steps and `design-handoff`. (#38, #9)
- **`design-handoff` reads every name from that block**, accepts "nothing is vendored yet, and why" as a state of the artefact line, which `adopt-designs` skips as it skips `none`, gives §5's stand-in and §9's styling rule a terminal form — the stand-in a token or glyph name, landed by deleting its definition in the product's design token set — and checks §2's routes table and its `/design-sync` note against the Claude Design documentation, marking what the documentation does not state as observed. (#38)
- **The local settings example carries a format-on-write hook slot**, a `FILL` for the project's formatter. (#37)
- **README states the delivery pipeline as required at user level, with its contract.** Plan, build, review, fix, close and release run on the user-level tracker pipeline, never shipped in this package, since a copy per project drifts. README §4 lists each command and workflow it uses — `tracker-plan`, `tracker-batch`, `tracker-review`, `tracker-fix`, `tracker-close`, `tracker-release`, `tracker-amend`, `tracker-pause`, `tracker-resume`, `tracker-roadmap`, `tracker-audit`, `workflow-orchestration` — with what it reads and what it leaves where, so an adopter without the pipeline follows the contract by hand; `AGENTS.md`'s routing rows point at it. The at-a-glance diagram and the phase map describe the one pipeline. Left open: the pipeline goes under `apm.yml`'s `dependencies.apm` once it is published as a public APM package. (#36)
- **README's "Applying the template" is one step per heading, with the commands to copy.** The package installs with `apm init --yes --target claude` and a pinned `apm install dsaenztagarro/agent-sdlc#v<version>`, so `apm.yml` records `claude` as the target and every developer's install deploys to `.claude/`. (#36)
- **`template-feedback` asks for one coherent improvement per issue, with related changes from one review as one issue,** instead of splitting one review's findings across many, and its file map names the package's `.apm/` paths. (#36)

### Removed

- **The `/epic` skill.** The user-level tracker pipeline plans, builds, reviews, fixes, closes and releases an epic's tickets; a second orchestrator writing to the same epic kept its own decisions log, checklist and close-out, and collided with it. (#36)

## [0.5.0] - 2026-11-11

### Added

- **A product reads and adopts its design through a shipped skill and agent.** `adopt-designs` publishes in the design checkout and reviews the sync diff by selector and section, vendors the one generated bundle with the project's vendor command, reports the selectors that appeared, changed and disappeared, triages, hands the adoption to the `design-curator` agent and each satisfied brief to `brief-closer`, and leaves the tree uncommitted. `design-curator` deletes the application's copies of what the bundle ships and writes the design's classes, restores dropped ancestors, and never translates a design rule into utilities or edits a generated file. Both read their names from `AGENTS.md`'s design section and stop to ask for one it does not give; the section's `FILL` block gains the cascade layer and the triage command, and `design-handoff` lists every name a project fills in and who reads it. A project no longer writes its own copy of either. (#47)
- **A shared design system's release lands in a product through one skill.** `adopt-shared-release` runs `design-handoff` §5's landing order: it moves the pin conservatively, fixes in the application what the release removed, runs the gate and drives a surface, then reads `bin/ds-status` — a stale copy stops it with the refresh handed to the person and every stand-in kept; a current one retires each stand-in and unmarked copy of a landed component, and re-vendors through `adopt-designs` once the design repository's pull request has merged. Before deleting anything, it holds the pin back while any local rule the landing keeps, a stand-in or an unmarked rule in the design repository's authored sources, its export mirror outside the `_ds/` snapshot, or the application's component styles, redeclares a selector in the new pin's stylesheet, since that stylesheet's other properties stack on it; a held landing deletes nothing. Its names come from `AGENTS.md`'s design section, whose `FILL` block gains the ones it reads. (#46)
- **A product's design repository shoots every page in every state, the surface alone.** `design-repo`'s skeleton gains `bin/shots` and its generator `lib/shots.js`, which walk each page's state bar in the installed Chrome and screenshot the `[data-surface]` element in each state into `tmp/shots/`, with a contact sheet; a caption or paragraph drawn beside the surface never reaches a shot. A page that breaks the contract — not exactly one surface, no state, several states and no state bar, a bar whose tabs disagree with the states — is named, for a brief to fix. `bin/sync` runs it after mirroring a project export, and `test/shots_test.rb` holds each rule, skipping where node or a browser is missing. (#30)
- **A page with many states groups them into families.** `design-handoff` §4: a Family row above the State row, a family's states contiguous and named `<Family> · <state>` without repeating the family, every state carrying `[data-family]` or none. `lib/shots.js` reads a grouped bar — each tab labelled with the state part, `Default` for the bare family — reaches the tabs it hides, and names a split family, a state outside its family's name and one repeating it. (#30)
- **A page states its surface and states in its markup.** `design-handoff` §4: `[data-surface]`, `[data-state="<Name>"]` and a `[role="tablist"][aria-label="State"]` bar; the rule goes into the project's `readme.md` with the rest of §4, so no brief restates it. (#30)
- **A review is published where a fresh session finds it.** README §10 lists the user-level `tracker-review` and `tracker-fix` workflows: findings go on the pull request as threads, each labelled with a stable id, and what no line of the diff shows goes in one `QA:` comment on the ticket; the fix commit names the id, and resolving a thread records the fix. The phase map gains a Review line. (#28)

### Changed

- **`AGENTS.md` holds only what every task needs, and routes to the rest.** Instead of a single source of truth read before anything, it keeps the rules an agent can break before it knows they exist, and a routing table points at the skills and path-scoped rules that hold procedures, loaded only when their task runs. README §1 says the same. (#28)
- **Renamed to `agent-sdlc`.** The template covers the whole lifecycle of building software with agents — plan, design, build, verify, release, decide — and the shorter name says so; GitHub's template flag already marks it as a template. The `agent-` prefix is shared with the other repositories that tell a coding agent how to work. (#29, #34)
- **The skills and the `brief-closer` agent ship as an APM package, installed rather than copied.** They live in `.apm/` under an `apm.yml`; an adopter depends on `dsaenztagarro/agent-sdlc`, and `apm install` deploys them into `.claude/`, pinned by `apm.lock.yaml`, so `apm update` takes every later fix instead of each copy drifting on its own. `design-handoff` carries no project fills: it reads the design repository, any shared system it extends and the artefact that crosses from `AGENTS.md`'s design section. (#34)
- **A product owns the components its experience needs, and promotes one only when it is generic.** `design-handoff` §5: a shared component is used as it is where it serves the job as well as anything could; otherwise the product draws its own and keeps it. That the shared system lacks a component is no reason to move it there: it is promoted — through the stand-in route — only once it is generic enough to serve other applications unchanged. (#30)
- **A terminal client's page is snapshots only.** `design-handoff` §4: a terminal redraws a whole grid per key press, so one frame per state is everything the user sees, and a page answering keys would write the application's key map a second time. A step through the surface is a run of named states. A behaviour question is drawn as candidate states and raised in the design chat, never labelled on the page. (#30)

## [0.4.2] - 2026-10-08

### Added

- **Every decision-log issue carries the `decision-log` label.** `docs/adr/README.md` states the issue's shape — titled `decision-log: <theme>`, one comment per amendment, open for as long as its record exists — and the filter that lists every theme's history, `gh issue list --label decision-log --state all`. `AGENTS.md` points an agent at it, and the themes table gains a Decision log column.

## [0.4.1] - 2026-10-08

### Fixed

- **`design-handoff` §5 states its rejected alternative in one line.** The hand-kept receipt is given with the technical reason it loses, without an account of how it failed.

## [0.4.0] - 2026-10-08

### Added

- **A page reaches its states through a switcher.** `design-handoff` §4: a surface's states share one page, one panel each, reached through a state switcher on the page, and no view shows two at once; each state's name is the switcher's label, and the page carries no other caption.
- **A component's example page is held to the page format.** `design-handoff` §4: it shows the component's cases as states and nothing else; each rule it carried goes to the shared system's component file, the comment beside the class, or a request upstream, and options weighed, research and rollout sweeps go to the design chat and the tracker.
- **A design project's agent context holds principles only.** `design-handoff` §2: the file the project reads before it draws states principles that hold for elements not drawn yet; a decision about one element is drawn in that element's page, so the file grows with the product's ideas, not its elements.
- **Triage the brief queue before a reshape.** `design-handoff` §8: a sweep or redraw across many pages starts only once every open brief has been checked against the current export — deleted when landed or outdated, moved when it belongs to the shared system, carried into the reshape or rechecked after it when still open.
- **How a product's design project knows its copy of the shared system is current.** `design-handoff` §5: the project draws against its own frozen `_ds/` copy, which only the project refreshes; the landing steps in order; and `bin/ds-status`, in the `design-repo` skeleton with its test, which compares the copy's `_ds_manifest.json` with the shared system's and names every token and component the copy lacks. The manifests are written by Claude Design on every export, so the check needs no hand-kept receipt.

### Removed

- **The request-queue check.** `layout_test.rb` no longer guards against `ds-graduation/` or `handoffs/` inside an export, and `layout.md` no longer lists them: both were folder names this template's adopters invented, not Claude Design conventions, and with the folders gone the check guarded a name nobody creates. A request is still a brief in the repository that will draw it.

## [0.3.0] - 2026-10-05

### Added

- **A `design-repo` skill** that creates a design repository — a product's design or a shared design system — from one skeleton: the root files, `briefs/README.md`, the weekly CI, a `Rakefile` whose `rake` is the gate, and a `bin/sync` for either export kind that refuses an export of the wrong kind, a page that is not one canonical prototype per surface, and an edit to a file the repository authors upstream, with a test for each. It also adopts the layout check in an existing repository.
- **A layout check for design repositories**, `test/layout_test.rb` in the `design-repo` skill's skeleton: each design repository copies it into its own `test/`, so `rake` fails when the repository leaves the layout — an unnamed root entry, a symlink, an ignored part of an export, a request queue inside an export, a misnamed brief or vendored system, a `CLAUDE.md` that is not an import, scratch left trackable.

## [0.2.0] - 2026-10-05

### Changed

- **Renamed to `agentic-engineering-template`.** "AI engineering" names building applications on language models; this template is about engineering *with* agents.
- **Every corpus an agent reads is bounded.** Decision records move to `docs/adr/`: a few broad themes, one record each, named for the theme and amended in place, with superseded reasoning on a per-theme decision-log issue. `/epic` amends themes once, at close-out, instead of writing a record per ticket. `docs/adr/decision-records.md` records why.
- **Design content moves to a sibling `<project>-ds` repository**, with one generated artefact crossing. The `design-handoff` skill is the procedure, including the three routes into a Claude Design project.

- **Each ticket gets its own worktree**, `claude --worktree issue-<N>` under a git-ignored `.claude/worktrees/`, so two agents never share a checkout and the same name re-enters it.

### Added

- **A `brief-closer` agent**, which closes a brief once its surface ships and verifies each ask before deleting anything.
- **A `design-handoff` skill**, the Claude Design procedure an agent follows when it writes a brief or reads an export back. It rules that a page draws the surface — every state, interaction included — and never the application's behaviour, a rule seeded into the design project's own `readme.md`; names a design project for its codebase and a shared design system for its brand, never its platform; lands a component the shared system lacks through one byte-identical stand-in and a brief in the shared system's own repository, deleted when the component ships; and states in `layout.md` the one layout every design repository keeps, folder by folder — a product's design and a shared design system alike.
- **README §10 lists the skills the workflow uses**: the ones shipped here, the ones each project creates (`read-designs`, `design-curator`), and the user-level ones created once for every project (`tracker-plan`, `tracker-resume`, `tracker-pause`, `tracker-close`, `deps-upgrade`, knowledge capture), with the phase of the work each carries.

### Removed

- **`docs/features/`, `docs/specs/`, `docs/guides/`, `docs/architecture/` and `docs/designs/`.** Each grew one file per feature, decision or brief. Behaviour is stated by tests, the reasoning by themed records, commands by the README and procedures by skills; nothing describes how the code works, because the code and its tests already do.

## [0.1.0] - 2026-08-13

First tagged release of the AI-engineering template — the agent-driven workflow scaffold that a project copies to give its coding agents a single, current source of truth.

### Added

- **Agent instruction source of truth** — `AGENTS.md` (surfaced to Claude via `CLAUDE.md`) carrying the portable principles: deliberate model selection and task-complexity tagging, the documentation taxonomy, testing guidelines (test the real thing; verify the runtime surface), the Claude Design workflow, and the standard development workflow.
- **Documentation taxonomy under `docs/`** — Architecture Decision Records (`docs/architecture/decisions/`) with a README, numbered template, and the seed ADR-0001; how-it-works explainers (`docs/architecture/`) with an explainer template; how-to guides (`docs/guides/`); feature docs (`docs/features/`); and a security note (`docs/SECURITY.md`).
- **Feature-specification layer (`docs/specs/`)** — the design=surface / spec=behaviour boundary, with code citing the spec (never a design file) via a relative markdown anchor link, cross-cutting behaviour consolidated into one shared spec every instance cites, and no design section-anchor in user-facing copy. (Closes #1.)
- **Claude Design workflow** — brief → canvas → build-to-it → verify-and-promote, bound to a repo design system recorded in `docs/designs/DESIGN-SYSTEM.md`, with brief scaffolding under `docs/designs/briefs/`, plus the rule to validate a design against the codebase and raise the hand — by comment or brief, sized to the discrepancy — rather than silently implementing a wrong design or diverging from it in code.
- **Skills** — `epic` (turn a design doc into a phased GitHub epic, shipped one ticket at a time) and `template-feedback` (raise a reusable, project-agnostic improvement back to this upstream template).
- **MIT license** and project README.

[Unreleased]: https://github.com/dsaenztagarro/agent-sdlc/compare/v1.0.3...HEAD
[1.0.3]: https://github.com/dsaenztagarro/agent-sdlc/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/dsaenztagarro/agent-sdlc/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/dsaenztagarro/agent-sdlc/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/dsaenztagarro/agent-sdlc/compare/v0.7.0...v1.0.0
[0.7.0]: https://github.com/dsaenztagarro/agent-sdlc/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/dsaenztagarro/agent-sdlc/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/dsaenztagarro/agent-sdlc/compare/v0.4.2...v0.5.0
[0.4.2]: https://github.com/dsaenztagarro/agent-sdlc/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/dsaenztagarro/agent-sdlc/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/dsaenztagarro/agent-sdlc/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/dsaenztagarro/agent-sdlc/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/dsaenztagarro/agent-sdlc/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/dsaenztagarro/agent-sdlc/releases/tag/v0.1.0
