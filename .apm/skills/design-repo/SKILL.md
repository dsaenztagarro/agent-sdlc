---
name: design-repo
description: Create a design repository — a product's design or a shared design system — from one skeleton, so it starts in the layout every design repository keeps; or adopt the layout check in an existing one. Use when a project first needs a design repository, when a shared design system gets its own, or when an existing design repository should be held to the layout.
---

# Creating a design repository

Every design repository keeps one layout, stated folder by folder in the `design-handoff` skill's `layout.md`. Read it first.
This skill starts a repository in that layout from `skeleton/`, and `skeleton/test/layout_test.rb` keeps it there: copied into the repository, it fails `rake` when the repository drifts.

## 1. Decide, before anything is created

| decision | the rule | who decides |
|---|---|---|
| **kind** | a product's design (one application's surfaces) or a shared design system (what a family of applications shares) | the person, if not already clear |
| **name** | `<project>-ds` beside the application `<project>`; a shared system `<brand>-ds`, for its brand or package, never its platform | derived; confirm |
| **export kind** | `project` (a Claude Design Project → `pages/`) or `system` (a Design System → `system/`) | from the Claude Design project type |
| **the artefact that crosses** | a stylesheet bundle, a token file — what the application vendors from `dist/` | the person, if not already clear |
| **upstream paths** | files authored here and pushed with `/design-sync` (a palette, a component tier) | none by default |

## 2. Create the repository

Creating a repository is outward-facing: confirm the name first.

```bash
gh repo create <owner>/<name> --private --clone
```

Always `--private` unless the person asked for a public one in this conversation.

## 3. Copy the skeleton and fill in the names

```bash
cp -R <this skill>/skeleton/. <name>/
cd <name>
mv _bin bin
grep -rl '__NAME__' . | xargs sed -i '' 's/__NAME__/<name>/g'     # GNU sed: -i without ''
sed -i '' 's/^KIND="__KIND__"$/KIND="<project|system>"/' bin/sync
chmod +x bin/sync bin/ds-status bin/shots bin/stand-ins bin/serve
bundle install     # writes Gemfile.lock, which is committed
```

The skeleton keeps its scripts in `_bin/` because APM does not deploy a folder named `bin` inside a skill; the copy renames it.

A product bound to a shared system replaces `__SHARED__` in `bin/ds-status` with that system's repository name, and in `bin/stand-ins` replaces `__SHARED_VAR__` with the name of the environment variable that the application's `AGENTS.md` design section declares for the shared system's checkout, without its leading `$`, and `__SHARED_CHECKOUT__` with its default. A shared system, or a product bound to none, deletes `bin/ds-status`, `bin/stand-ins` and their tests.
A shared system deletes `bin/shots`, `lib/shots.js` and `test/shots_test.rb` too: it has no pages to shoot.

Then resolve every `FILL` marker (`grep -rn FILL .`):

- **`README.md`** — the opening paragraph, and the tree: keep the lines that apply, delete the rest.
- **`AGENTS.md`** — the consuming application, and which paths flow which way.
- **`briefs/README.md`** — what belongs here, for this kind.
- **`bin/sync`** — `REQUIRED_ROOT_FILES` lists what a complete export carries at its root: a web export's root stylesheet, nothing for a terminal client's. `UPSTREAM` lists each authored file as `<path in this repository>:<path in the export>`, so a product's palette authored under `system/` is compared with the copy its export carries. `PROJECT_FILES` lists the Markdown files the project keeps as its own — by default `readme.md`, `AGENTS.md` and `CLAUDE.md` — each a path in the export or a pattern; a shared system adds the patterns its export uses for its component and skill documents. Any other Markdown outside `_ds/` is a note, and the export is refused. `EXCLUDES` keeps its default unless the project carries other authoring noise.
- **`Rakefile`** — the generator's task and its `:check`, ahead of `:test`.

## 4. Add the generator

`lib/` holds it, `dist/` its committed output, and `rake` fails when the two disagree — that check is what makes *generated, not copied* true.
It is plain Ruby, adding no gem to the `Gemfile`, so `bundle install` once is all a clone needs before `rake`. `lib/shots.js` beside it is not a generator: it writes only `tmp/shots/`, needs node and a browser, and its test skips without them.
A product's stylesheet bundle is wrapped in its own cascade layer, declared after the shared system's.
Each refusal or guarantee it adds gets a test named for the rule.

## 5. Create the Claude Design project

Same name as the repository. Seed its own `readme.md` through `/design-sync` with the rules that must hold in every export, so that no brief has to restate them:

- for a product's project, the surface-only rule and its markup contract (`design-handoff` §4), so that `bin/shots` can shoot every page;
- for every project, that it never writes a request, a note or a plan into its files: a component it thinks every application should share is raised in the design chat, and `bin/sync` refuses an export carrying such a file;
- for a product's project bound to a shared system, that a stand-in's marker reads `STAND-IN — delete when the design system lands <Component>`, where `<Component>` is the one PascalCase name the shared system will list it under, so that `bin/stand-ins` looks it up by that name.
When paths flow upstream, record the project's id and namespace in `.design-sync/config.json`, and what a future `/design-sync` must know in `.design-sync/NOTES.md`.

## 6. First export, then the gate

```bash
bin/sync       # mirror the first export; a product's also shoots every page into tmp/shots/
rake           # the generator's check, then every test — layout_test.rb included
```

Commit the mirror as produced, as the repository's `AGENTS.md` states the publish procedure and its commit conventions. The repository is done when `rake` passes and `grep -rn FILL .` finds nothing.

## Adopting the layout check in an existing design repository

1. Copy `skeleton/test/layout_test.rb` into its `test/`, and run `rake`.
2. Each failure is drift: fix it in the same change when it is small, or open an issue per failure on that repository.
3. A folder the layout does not name is either moved, or argued into `layout.md` first — never allowed by editing the copy.

## Refreshing the check

`layout_test.rb` is copied, not shared: when a rule changes here, copy it again into each design repository, and fix what the new rule finds there. A local edit forks the rule from every other repository. `layout_check_test.rb`, which runs the check against throwaway checkouts, is copied with it wherever the repository carries `test_helper.rb`.
