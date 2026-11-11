# __NAME__

**Claude Design kind: a Project**, linked to the <!-- FILL: the shared Design System's name, `<brand>-ds`; or "linked to no Design System" --> Design System.

<!-- FILL: one paragraph — the application whose surfaces this repository designs, and what that application vendors from `dist/`. -->

This repository is the source of truth for that design.
The application holds no copy of the export: it vendors the generated file in `dist/` and has no opinion about how it was made.

## The Claude Design content

The __NAME__ Project draws the application's surfaces, one canonical page per surface, against the Design System it is linked to.
Its export is mirrored into one folder, and nothing else here is Claude Design's:

```
pages/                 the Project's export, mirrored by bin/sync; never edited here
pages/_ds/<id>/        the snapshot of the linked Design System the pages render against, committed
```

<!-- FILL: keep this paragraph when the Project draws against a file authored here, else delete it. -->
A file the Project draws against but this repository authors — a checked palette — lives under `system/`, flows up with `/design-sync`, and `bin/sync` refuses an export whose copy of it differs.
`system/` holds only those files: `bin/sync`'s `UPSTREAM` lists them, and the layout check refuses anything else there.

A hand edit inside `pages/` is reverted by the next `bin/sync`: a change to what the Project draws starts as a brief in `briefs/proposed/`.

## The git wrapper

Everything else wraps the export in git: the requests that go in, the generator that reads it, and the checks that hold it.

```
<!-- FILL: keep the lines that apply, delete the rest; the layout check refuses a folder not listed in the layout. -->
briefs/proposed/       the requests to the __NAME__ Project, one open brief per theme, handed over by copy-paste
references/            hand-authored material the Project draws on; never touched by bin/sync
vendor/<shared>-ds/    the shared system's build inputs, copied whole by bin/vendor-sync
docs/                  the contract dist/ keeps
lib/                   the generators, shots.js among them
dist/                  what crosses into the application — generated, committed
test/                  the generators' tests, bin/sync's, and the layout check
bin/sync               mirror a fresh export into pages/
bin/ds-status          whether pages/_ds/ carries what the linked Design System does
bin/shots              every page in every state, the application surface alone, into tmp/shots/
bin/stand-ins          where each stand-in is on its way into the linked Design System
bin/serve              every page from a real origin, with an index walked on each request
```

## Working on it

```bash
bundle install  # once: the gems rake and bin/serve need
bin/sync        # mirror ~/Downloads/__NAME__.zip; refuses an incomplete export, a Design System's, an off-format page, a note, or an edited upstream file
rake            # every check, then the tests — the gate before each merge
bin/ds-status   # what pages/_ds/ lacks, from the two manifests
bin/stand-ins   # each stand-in's stage — unrequested, requested, upstream or landed
bin/shots       # screenshot every page in every state, and name each page that breaks the page contract
bin/serve       # browse every page on http://localhost:4000
```
