---
name: design-repo
description: Create a design repository — a product's design or a shared design system — from one skeleton, so it starts in the layout every design repository keeps and states its Claude Design kind; or adopt the layout check and `bin/sync` in an existing one. Use when a project first needs a design repository, when a shared design system gets its own, or when an existing design repository should be held to the layout.
---

# Creating a design repository

Every design repository keeps one layout, stated folder by folder in the `design-handoff` skill's `layout.md`. Read it first.
This skill starts a repository in that layout from `skeleton/`, and `skeleton/common/test/layout_test.rb` keeps it there: copied into the repository, it fails `rake` when the repository drifts.

The skeleton states each kind by its files: `common/` holds what every design repository carries, and one overlay per kind adds the rest, its README included.

```
skeleton/
+-- common/          AGENTS.md, CLAUDE.md, Rakefile, Gemfile, .gitignore, CI, briefs/README.md,
|                    bin/sync, bin/serve, the layout check and their tests
+-- project/         README.md, bin/shots, lib/shots.js, bin/ds-status, bin/stand-ins, their tests
+-- design-system/   README.md, .design-sync/config.json and NOTES.md
```

## 1. Decide, before anything is created

**A product's design is a Claude Design Project, linked to the shared Design System; anything several applications share is a Design System, in a repository of its own.**
One repository mirrors one Claude Design project, so it is one kind: an application's pages never go into a Design System, and a Design System's `templates/` — starter layouts for the Projects linked to it — is never where an application's pages go.

| decision | the rule | who decides |
|---|---|---|
| **kind** | `project` — one application's surfaces, a Project whose export lands in `pages/` — or `system` — what a family of applications shares, a Design System whose export lands in `system/` | the person, if not already clear, by the rule above |
| **name** | `<project>-ds` beside the application `<project>`; a shared system `<brand>-ds`, for its brand or package, never its platform | derived; confirm |
| **linked Design System** | for a Project, the shared system it renders against, or none | the person |
| **the artefact that crosses** | a stylesheet bundle, a token file — what the application vendors from `dist/` | the person, if not already clear |
| **upstream paths** | files authored here and pushed with `/design-sync` (a palette, a component tier) | none by default |

## 2. Create the repository

Creating a repository is outward-facing: confirm the name first.

```bash
gh repo create <owner>/<name> --private --clone
```

Always `--private` unless the person asked for a public one in this conversation.

## 3. Copy the skeleton and fill in the names

`common/` first, then the overlay for the kind, and `KIND` in `bin/sync` set to match it:

```bash
overlay=project      # or design-system
kind=project         # or system, for the design-system overlay
cp -R <this skill>/skeleton/common/. <name>/
cp -R <this skill>/skeleton/$overlay/. <name>/
cd <name>
mv _bin bin
grep -rl '__NAME__' . | xargs sed -i '' 's/__NAME__/<name>/g'     # GNU sed: -i without ''
sed -i '' "s/^KIND=\"__KIND__\"$/KIND=\"$kind\"/" bin/sync
chmod +x bin/*
bundle install     # writes Gemfile.lock, which is committed
```

The skeleton keeps its scripts in `_bin/` because APM does not deploy a folder named `bin` inside a skill; the copy renames it.

A Project linked to a shared system replaces `__SHARED__` in `bin/ds-status` with that system's repository name, and in `bin/stand-ins` replaces `__SHARED_VAR__` with the name of the environment variable that the application's `AGENTS.md` design section declares for the shared system's checkout, without its leading `$`, and `__SHARED_CHECKOUT__` with its default. A Project linked to none deletes `bin/ds-status`, `bin/stand-ins` and their tests.

Then resolve every `FILL` marker (`grep -rn FILL .`):

- **`README.md`** — its first line states the kind, and for a Project the Design System it is linked to; then the opening paragraph, which paths flow which way, and the wrapper's tree: keep the lines that apply, delete the rest.
- **`.design-sync/`**, a Design System's — the system's id in `config.json`, and in `NOTES.md` the paths that flow each way.
- **`AGENTS.md`** — the consuming application, and which paths flow which way.
- **`briefs/README.md`** — what belongs here, for this kind.
- **`bin/sync`** — `REQUIRED_ROOT_FILES` lists what a complete export carries at its root: a web export's root stylesheet, nothing for a terminal client's. `UPSTREAM` lists each authored file as `<path in this repository>:<path in the export>`, so a product's palette authored under `system/` is compared with the copy its export carries. `PROJECT_FILES` lists the Markdown files the project keeps as its own — by default `readme.md`, `AGENTS.md` and `CLAUDE.md` — each a path in the export or a pattern; a shared system adds the patterns its export uses for its component and skill documents. Any other Markdown outside `_ds/` is a note, and the export is refused. `EXCLUDES` keeps its default unless the project carries other authoring noise.
- **`Rakefile`** — the generator's task and its `:check`, ahead of `:test`.

## 4. Add the generator

`lib/` holds it, `dist/` its committed output, and `rake` fails when the two disagree — that check is what makes *generated, not copied* true.
It is plain Ruby, adding no gem to the `Gemfile`, so `bundle install` once is all a clone needs before `rake`. `lib/shots.js` beside it is not a generator: it writes only `tmp/shots/`, needs node and a browser, and its test skips without them.
A product's stylesheet bundle is wrapped in its own cascade layer, declared after the shared system's.
Each refusal or guarantee it adds gets a test named for the rule, and earns its place by the realistic mistake that fails it, named beside it, as the testing seed's rule in `.claude/rules/testing.md` states.

## 5. Create the Claude Design project

Same name as the repository, and of the kind `bin/sync` names: a Project, linked to the Design System chosen in §1, or a Design System.
The README states the kind and the link, never the clicks that make them: the standalone Claude Design site closes on December 14, 2026, and steps written against it go stale.

Seed its own `readme.md` through `/design-sync` with the rules that must hold in every export, so that no brief has to restate them:

- for a product's project, the surface-only rule and its markup contract (`design-handoff` §4), so that `bin/shots` can shoot every page;
- for every project, that it never writes a request, a note or a plan into its files: a component it thinks every application should share is raised in the design chat, and `bin/sync` refuses an export carrying such a file;
- for a product's project bound to a shared system, that a stand-in's marker reads `STAND-IN — delete when the design system lands <Component>`, where `<Component>` is the one PascalCase name the shared system will list it under, so that `bin/stand-ins` looks it up by that name.
A Design System records its id in `.design-sync/config.json`, and what a future `/design-sync` must know in `.design-sync/NOTES.md`; a Project whose palette flows upstream adds both too.

## 6. First export, then the gate

```bash
bin/sync       # mirror the first export; a product's also shoots every page into tmp/shots/
rake           # the generator's check, then every test — layout_test.rb included
```

Commit the mirror as produced, as the repository's `AGENTS.md` states the publish procedure and its commit conventions. The repository is done when `rake` passes and `grep -rn FILL .` finds nothing.

## Adopting the layout check in an existing design repository

1. Copy `skeleton/common/test/layout_test.rb` into its `test/`.
2. Replace its `bin/sync` with `skeleton/common/_bin/sync`, filled in as §3 says — `NAME`, `KIND` from the export folder it mirrors, and the arrays carried over from the old script — and copy `skeleton/common/test/sync_test.rb` beside it, with `test_helper.rb` if the repository has none.
3. Run `rake`. Each failure is drift: fix it in the same change when it is small, or open an issue per failure on that repository.
4. A folder the layout does not name is either moved, or argued into `layout.md` first — never allowed by editing the copy. A refusal the old `bin/sync` had and the skeleton's lacks is raised on this template, never kept in a local copy.
5. State the kind as the README's first line, as the overlay's README does.

## Refreshing the check

`layout_test.rb` and `bin/sync` are copied, not shared: when a rule changes here, copy them again into each design repository, and fix what the new rule finds there. A local edit forks the rule from every other repository. `layout_check_test.rb`, which runs the check against throwaway checkouts, is copied with it wherever the repository carries `test_helper.rb`.
