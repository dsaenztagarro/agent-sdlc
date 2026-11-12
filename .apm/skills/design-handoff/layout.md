# How a design repository is organised

Every design repository has the same layout, whatever it designs and whichever Claude Design project type it mirrors.
A folder means the same thing in each one, so an agent that has worked in one can find its way around any other without reading the README first.
Read this file before creating a design repository, adding a folder to one, or reviewing one; the `design-repo` skill creates one in this layout from its skeleton.

## Two kinds, one layout

| kind | what it designs | its Claude Design project | who consumes what it generates |
|---|---|---|---|
| **a product's design** — `<project>-ds` | one application's own surfaces | a **Project**: pages, plus a `_ds/` snapshot of the design system it is bound to | that application |
| **a shared design system** — `<brand>-ds` | what every application in a family shares: components, tokens, patterns | a **Design System**, which each product's Project is linked to | each product design, and each application in the family |

**A product's design is a Project linked to the shared Design System; anything several applications share is a Design System, in a repository of its own.**
One `bin/sync` mirrors one Claude Design project, so a repository is one kind: a Project export lands in `pages/`, a Design System export in `system/`.
The kind is stated in `bin/sync`'s `KIND`, the README's first line, and the export folder; `bin/sync` refuses an export of the other kind.
A Project's repository may keep files under `system/` only when it authors them and `bin/sync` pushes them upstream, such as a checked palette.

**What a Design System export holds**, as observed in exports:

- `_ds_manifest.json`, the index of every token and component, which a Project's `_ds/` snapshot carries too;
- `components/`, `tokens/` and `guidelines/`, the system itself;
- `templates/`, starter layouts the system offers the Projects linked to it — never an application's pages, which are that application's Project, in its own repository;
- `_ds_bundle.js`, the compiled components the design agent renders;
- beside them, the project's own `readme.md`, and the stylesheets, previews and skill file it keeps at its root.

## Names

- **The repository, the Claude Design project, the generated bundle and its cascade layer all take one name.** A product's is `<project>-ds`, beside the application `<project>`; a shared system's is `<brand>-ds`, named for its brand or the package that ships it.
- **Never a platform name** (`web-ds`): it points at no repository, and stops being true the day a second system for the same platform exists.
- **Never a folder named after the repository** inside it (`<name>-ds/<name>-ds/`). The export folder is `pages/` or `system/`.
- **A Claude Design project that is renamed takes its old name with it.** Every document saying the old name means the new owner of that name from then on; date a reference before trusting it, and rewrite the ones you touch.

## The tree

```
<name>-ds/
+-- README.md               its kind, the Claude Design content, the git wrapper, the commands
+-- AGENTS.md               the rules an agent working here needs; CLAUDE.md is `@AGENTS.md`
+-- CLAUDE.md
+-- Rakefile                `rake` is the gate: every check, then the tests
+-- Gemfile                 the gems `rake` needs; Gemfile.lock beside it, committed
+-- Gemfile.lock
+-- .gitignore              tmp/ (the sync's staging and the shots), .DS_Store, .claude/worktrees/
+-- .github/workflows/      the gate, on every pull request and push
+-- briefs/
|   +-- README.md           what belongs here, the lifecycle, how to write one
|   +-- proposed/           <theme>.brief.md, one open brief per theme
+-- pages/                  a Project export, mirrored                     (product)
|   +-- _ds/<project-id>/   the design-system snapshot the pages render against, committed
+-- system/                 a Design System export, mirrored; authored and pushed up  (a Project's: upstream files only)
+-- references/             hand-authored material the projects draw on; never touched by bin/sync
+-- vendor/<shared>-ds/     the shared system's build inputs, copied whole  (when the generator needs them)
+-- docs/                   the contract the generated artefact keeps, one file per theme
+-- lib/                    the generators
+-- test/                   the generators' tests and bin/sync's
+-- dist/                   the generated artefacts that cross, committed
+-- bin/
|   +-- sync                mirror a fresh export
|   +-- ds-status           whether pages/_ds/ carries what the shared system does   (product)
|   +-- shots               every page in every state, the surface alone, into tmp/shots/   (product)
|   +-- serve               every page from a real origin, with a directory listing
|   +-- vendor-sync         refresh vendor/ from the shared system's checkout
+-- .design-sync/           config.json and NOTES.md, when files are pushed up with /design-sync
+-- .claude/skills/         skills that only make sense here, such as the contract's
```

A folder that does not apply is absent, never empty. A folder not in this tree is not added without amending this file first.

**Review holds a repository to this layout**; no test does, since a folder in the wrong place breaks nothing a check could see.

## Folder by folder

### `briefs/`

The requests made **to this repository's Claude Design project**, and nothing else.

- A product's `briefs/` asks its own project for surfaces; a shared system's asks for what every application shares.
- **A request belongs to the repository whose project will draw it.** A product that needs a shared component writes the brief in the shared system's `briefs/proposed/`, not its own, and not inside its project.
- **One open brief per theme**, a self-contained `<theme>.brief.md` named for the theme and amended in place: a new ask joins the open brief for its theme, and a brief opens only for a theme none covers. A request that carries code — a component's complete files — is still a brief.
- A theme that landed partly, or landed with a defect, keeps its brief, listing only what remains.
- **A rule that must hold for every export is never written into a brief**: it lives in the design project's own `readme.md`, pushed with `/design-sync`.
- Deleted once everything it asked for has landed and its durable half has a home elsewhere (the `brief-closer` agent and §8 of the skill). `git log --diff-filter=D -- briefs/` finds one again.
- `briefs/README.md` states what belongs here, the lifecycle, the house format and the reader rule, in the words of this repository.

### `pages/` — a Project export

- **A mirror.** `bin/sync` writes it with `rsync -a --delete`; nobody edits it by hand, and it is committed as produced, defects included.
- **`pages/_ds/<project-id>/` is committed.** It is the snapshot of the shared system the pages were drawn and render against, as the export carries it. A page must render the same on any clone, so it is never a symlink to a local checkout of the shared system, and never git-ignored.
- **`bin/ds-status` says whether that snapshot is current**, by comparing its `_ds_manifest.json` with the shared system's; `design-handoff` §5 has how the copy is refreshed.
- The snapshot is not a second source: the shared system's repository is. A diff between `pages/_ds/<project-id>/` and the shared system's `system/` shows how far behind it is.
- What a page may hold is ruled in §4 of the skill: the surface, never the application, marked up so `bin/shots` can find the surface and walk its states.

### `system/` — a Design System project

Two directions, and the README says which path goes which way. By default everything but `templates/` is authored here, and `templates/` is drawn in the Design System:

- **Downstream** — drawn in the project, exported, mirrored by `bin/sync`. A hand edit is reverted by the next sync.
- **Upstream** — authored here, checked by `rake`, pushed to the project with `/design-sync` (a palette, a component tier, the project's own `readme.md`). `bin/sync` **refuses an export whose copy of an upstream file differs or is missing**, because `--delete` would otherwise overwrite the only copy the checks ran against. Each upstream entry names the file's path in the repository and its path in the export, so a product repository's palette, authored under `system/` while its export lands in `pages/`, is compared with the copy its export carries.

### `references/`

Hand-authored material the projects draw on and the generators do not read: cross-application references, explorations kept on purpose, a component tier stated as data. Never touched by `bin/sync`.

### `vendor/<shared>-ds/`

What the **generator** needs from the shared system — its generator code, its base palette, its component tier — copied whole by `bin/vendor-sync` and committed, so `rake` runs on a clone with nothing else checked out.
It is not the rendering snapshot (that is `pages/_ds/`), and it is absent when the generator needs nothing from the shared system.

### `dist/`

The generated artefacts that cross into applications — a stylesheet bundle, a token file. **Committed**, and `rake` fails when they disagree with their sources, which is what makes *generated, not copied* true.
A product's bundle is wrapped in its own cascade layer, declared after the shared system's.

### `docs/`

The contract the generated artefact keeps — what each field carries and why it is computed here. One file per theme, never one per change, component or request.

### `lib/` and `test/`

The generators, and their tests. `test/` also holds `bin/sync`'s tests, each running a copy of the script in a throwaway checkout: what a clean export mirrors, and each export it refuses.

### `bin/`

- **`sync`** mirrors a fresh export. Its refusals are the review gate, each leaves the mirror untouched, and each has a test:
  - an incomplete export — no `_ds_manifest.json`, or a root file the repository lists as required missing: a web export's root stylesheet, while a terminal client's export lists none;
  - an export of the other kind — a Project's export into a Design System's repository, or a Design System's into a Project's;
  - an export whose copy of a file this repository authors upstream differs or is missing;
  - a note beside the pages — any Markdown file outside `_ds/` other than the project's own files the repository lists, by default `readme.md`, `AGENTS.md` and `CLAUDE.md`: a request it carries belongs in the open brief of the repository whose project will draw it.
- It never mirrors authoring screenshots, and replaces a symlinked snapshot with the export's own.
- It stages into a git-ignored `tmp/`, deletes only inside the checkout, mirrors, reports what changed, and leaves committing to a person.
- **`ds-status`**, in a product's repository, compares the `_ds/` snapshot's manifest with the shared system's, and exits 1 when the snapshot lacks a token or component the shared system carries.
- **`shots`**, in a product's repository, runs after every sync: it reaches each state of each page at its address, `#state=<family>/<state>`, checks that the State row names it, hides `[data-design-chrome]`, and screenshots the `[data-surface]` element whole into the git-ignored `tmp/shots/`, with an `index.html` contact sheet; it exits 1 naming each page that breaks the page contract (§4 of the skill). The generator is `lib/shots.js`; Playwright drives the installed Chrome from a cache outside the repository, and its test skips, saying so, where node or a browser is missing.
- **`serve`** serves the checkout on a real origin with `python3 -m http.server`, so a page that fetches anything works as it does in Claude Design.
- **`vendor-sync`** refreshes `vendor/` from a checkout of the shared system.

### `.design-sync/`

`config.json` pins the Claude Design project's id, the bundle's namespace and the repository's shape; `NOTES.md` records what a future `/design-sync` must know about this repository. Present only where files are pushed up.

### Root files

- **`README.md`** opens with its Claude Design kind — a Project and the Design System it is linked to, or a Design System — then what the repository is and who consumes it, then two parts: the Claude Design content, the export folder and which paths flow which way; and the git wrapper, each folder around the export and what it does. Then the commands. It states the kind and the link, never the clicks that create them in Claude Design.
- **`AGENTS.md`** holds the rules an agent needs here and nowhere else — which files flow which way, what the generator guarantees; `CLAUDE.md` is the one line `@AGENTS.md`. The application's own rules stay in the application's `AGENTS.md`, linked.
- **`Rakefile`**: `rake` runs every check, then the tests, and is the gate before every merge. CI runs the same `rake` on every pull request and push.

## What is never in a design repository

- **The application's behaviour** — validations, save rules, the data model. Tests in the application hold it.
- **The reasoning behind an application decision.** The application's decision records hold it; a brief states the ruling in a sentence.
- **A symlink into another checkout.** What a clone renders, builds or tests must come from that clone.
- **A copy of another design repository's pages** — a terminal client's mockups inside a web product's repository. Each design has one repository.
- **A file per work item** — a spec per feature, a log per sync, an archive of shipped briefs.
