# __NAME__

**Claude Design kind: a Design System**, which every consuming application's Project is linked to.

<!-- FILL: one paragraph — what every application in the family shares through it, which applications consume what it generates, and what each vendors from `dist/`. -->

This repository is the source of truth for that system.
No application holds a copy of the export: each vendors the generated file in `dist/`, and each application's own design repository is a Project that renders against a snapshot of this system.

## The Claude Design content

The __NAME__ Design System is mirrored into one folder, and nothing else here is Claude Design's.
Its files flow two ways:

```
  this repository                                 the __NAME__ Design System
  +-----------------------------+   /design-sync   +-----------------------------+
  | system/  authored and       | ---------------> | components, tokens,         |
  |          checked by rake    |                  | guidelines, readme.md       |
  |                             |   bin/sync       |                             |
  | system/templates/           | <--------------- | templates/  drawn there     |
  +-----------------------------+                  +-----------------------------+
```

<!-- FILL: name the paths that go each way, if they differ from the default below. -->
- **Up:** everything under `system/` but `templates/` is authored here, checked by `rake`, and pushed with `/design-sync`. `bin/sync`'s `UPSTREAM` lists each file whose exported copy must match, and refuses an export that differs.
- **Down:** `templates/` holds the starter layouts the system offers the Projects linked to it. The Design System draws them, and `bin/sync` mirrors them back. An application's own pages never live here: they are that application's Project, in its own design repository.

`.design-sync/config.json` pins the Design System's id; `.design-sync/NOTES.md` holds what the next `/design-sync` run must know.

## The git wrapper

Everything else wraps the system in git: the requests that go in, the generator that reads it, and the checks that hold it.

```
<!-- FILL: keep the lines that apply, delete the rest. -->
briefs/proposed/       the requests to the __NAME__ Design System, one open brief per theme, handed over by copy-paste
references/            hand-authored material the system draws on; never touched by bin/sync
docs/                  the contract dist/ keeps
lib/                   the generators
dist/                  what crosses into applications — generated, committed
test/                  the generators' tests, and bin/sync's
bin/sync               mirror a fresh export into system/
bin/serve              every page from a real origin, with a directory listing at /
.design-sync/          the Design System's id, and the notes /design-sync reads
```

## Working on it

```bash
bundle install  # once: the gems rake needs
bin/sync        # mirror ~/Downloads/__NAME__.zip; refuses an incomplete export, a Project's, a note, or an edited upstream file
rake            # every check, then the tests — the gate before each merge
bin/serve       # browse every page on http://localhost:8000
```
