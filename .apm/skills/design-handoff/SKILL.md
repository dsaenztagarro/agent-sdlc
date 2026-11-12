---
name: design-handoff
description: The Claude Design handoff loop — which repository is which, how a design repository is laid out, the three routes into the design project, writing a brief, reading an export back, and closing a brief out. Use when creating or reviewing a design repository, writing a design brief, handing work to Claude Design, reading an export back into the design repository, or building a surface from a design page.
---

# Working with Claude Design: the handoff loop

How a design change gets from an idea to something this application renders, and what an agent may and may not touch on the way.
This is an operating procedure — the order matters, and two of its steps exist to stop a class of silent loss.

If this project has no user interface, or its interface takes all its colours from its host — a multiplexer plugin drawing in the host theme's levels, a command line on the terminal's ANSI slots — this skill does not apply, and the theme's decision record says why, with the condition that reopens it.

## 1. Three names, and which one you are in

| | what it is | you may edit it |
|---|---|---|
| **`<project>`** (this repository) | the application — code, tests and decision records | yes |
| **`<project>-ds`** (the design repository) | the briefs, the pages Claude Design returns, a mirror of the design project's export, and the generator for the one artefact that crosses | the briefs and what the repository authors — yes; the export mirror, never (§3) |
| **`<project>-ds`**, the Claude Design project | where pages, components and specimens are drawn | through the three routes in §2, never directly |

`AGENTS.md`'s design section names the real repositories, and the shared design system vendored into the design repository when there is one — a fourth name, edited only in its own repository, where a request for a shared widget is a brief.

**Every name this skill and its neighbours read comes from the block of names in `AGENTS.md`'s design section, and from nowhere else.** A name the block does not give is asked for, never guessed; one that does not apply is written `none`. Who reads which:

- design repository, design checkout, regenerate command, design suite — this skill, `adopt-designs`, `adopt-shared-release`, and the checkout for `design-curator` too;
- artefact form — this skill (§2, §5), `adopt-designs`, `design-curator`;
- artefact source, vendor command — `adopt-designs`;
- artefact vendored at — `adopt-designs`, `design-curator`;
- cascade layer — `design-curator`;
- triage command — `adopt-designs`, `design-curator`;
- own component styles — `adopt-designs`, `design-curator`, `adopt-shared-release`;
- shared design system, its channel, its checkout, its release ref and release notes, the pin command and the token sync command — `adopt-shared-release`, and the shared system's checkout for `adopt-designs` too;
- decision records — this skill (§7), `brief-closer`.

**A design project is named for the codebase it draws for** — `<project>-ds` beside `<project>` — so the name says which checkout its export syncs into.
A design system shared by several projects is named for its brand or the package that ships it, never for its platform: a `web-ds` points at no repository, and stops being true the day a second web system exists.

**Every design repository has one layout**, whether it holds a product's design or a shared design system: [`layout.md`](layout.md) states it folder by folder. Read it before adding a folder to one; create one with the `design-repo` skill.

The design repository and the design project share a name. Say *repository* or *project*: the difference decides whether an edit survives.

Design content lives outside this repository because it grows without bound, and an application repository carrying it stops being code.

## 2. What crosses, and by which route

**Exactly one generated artefact reaches this application**, and it is data — a token set, or a stylesheet bundle.
`AGENTS.md`'s design section names it, its form, its path here, and the command that vendors it.
**"Nothing is vendored yet, and why" is a valid state of that line** — a design still being drawn, a surface that renders the shared system's components alone — and `adopt-designs` treats it as it treats `none`: it skips what needs the artefact, and says so. A blank line is not that state: it is a missing name.
A page is read by a person designing or building a surface; it is never a build input, and code never cites one.

The design project holds its own files and nothing else — it cannot open either repository. Everything it knows arrives by one of three routes, each started by a person:

| route | carries | lifetime |
|---|---|---|
| **a brief**, pasted into the project | its theme's pending asks | spent on arrival; each ask leaves it when its surface ships, and the brief is deleted when none remains (§8) |
| **`/design-sync`**, from Claude Code | a repository's React design system, converted and uploaded to a **Design System** project once the person confirms what it will upload or delete; it reaches no other kind of project | until overwritten |
| **a file added by hand**, in the project | a file a Project draws against but the design repository authors — its palette, its own `readme.md` | until replaced |
| **the export**, the project's Export menu, *Download as .zip* | the whole project, back to the design repository | a commit of the mirror |

`/design-sync` needs a claude.ai login in Claude Code (`/design-login`), and is unavailable where Claude Code does not contact claude.ai — Amazon Bedrock, Google Cloud, Microsoft Foundry.
It uploads to the standalone claude.ai/design site, which closes on December 14, 2026; design systems move into Claude, and where `/design-sync` uploads after that date is not documented yet.
Observed, not documented: it writes one change at a time, never as a wholesale replace, and it never writes `CLAUDE.md` or `.claude/`, which instruct the design agent: a repository that authors its system pushes `AGENTS.md` alone and commits no `CLAUDE.md` beside it, and only a project that authors its own files can create the import.

- **A rule that must hold for every future export goes into the project's own `readme.md`**, which the project reads before it draws: through `/design-sync` for a Design System, added by a person for a Project. Pasted into a brief, the same rule dies with the brief. Not documented: that `/design-sync` writes the project's `readme.md` is stated by no documentation, so check the project shows the rule after the sync.
- **The project's agent context holds principles, never decisions about particular elements.** A principle — shape names the field, colour flags attention, absence is calm — holds for elements not drawn yet. A decision about one chip or one column is drawn in its page, and changes without the agent context changing; written into it, the decision becomes a second copy of the page that drifts, and the file grows with the elements instead of with the product's ideas. A ruling that is a principle amends the agent context; a ruling about one element is drawn in that element's page. An index that only names what exists — components, pages, tokens — is not a decision, and stays: it carries no rule to drift.
- **The mirror is refreshed only through the export** and the design repository's sync script, whose refusals — an export of the other kind, a file the repository owns that the project edited, a note beside the pages — are the review gate.
- **The export carries no request.** A request or a plan the project writes into its files reaches no brief, and the next export can delete it unseen: the project raises it in the design chat, the sync script refuses an export carrying one, and its content goes to the open brief of the repository whose project will draw it.
- **A brief never restates a rule that holds for every export.** Each copy dies with its brief, and the copies drift as the rule moves. A shared system's standing rules reach each linked Project through the readme in its `_ds/` copy, so the Project's own readme points at them rather than restating them; and what a token is for is written beside its definition, in the token file the project already holds.

## 3. The export mirror is generated — never hand-edit it

The sync script mirrors the export with `rsync -a --delete`. A hand-edit there is destroyed by the next sync, silently, and it makes the record lie: the mirror is committed so its diff shows what Design produced.
Commit the mirror as produced, defects included, with what you found named in the commit message — and fix it through a brief.

If the design repository authors a file the project draws against — a checked palette — that file flows **up** — through `/design-sync` into a Design System, added by a person to a Project — and the sync script refuses an export whose copy of it differs or is missing. It compares the file where the repository authors it, which in a product's repository is outside the export folder, with the copy at the path the export carries it.

## 4. A page draws the surface, never the application

The application keeps changing; a drawn page changes only when someone redraws it.
A sentence on a page about how the application behaves is true the day it is drawn and drifts after, nothing checks it, and the next reader building from the page takes it as current.

- **A page shows a surface in every state it can be in** — empty, loading, error, long data; read, edit and create where they apply. The states share one page, one panel each, and a state switcher on the page reaches every one of them; nothing shows two states at once. Each state is named in two or three words, and that name is the switcher's label — the page carries no other caption.
- **The page says so in its markup, so a generator can read it.** One `[data-surface]` element is the application as it renders, chrome included; each state is a `[data-state="<Family> · <state>"]` element inside it, one shown at a time; each state is shown at the address `#state=<family>/<state>`, each part lowercased, every run of other characters a hyphen, and none at either end; the switcher sits in `[data-design-chrome]`, and its State row, `[role="tablist"][aria-label="State"]`, is required once a page has two states, its selected tab labelled with the shown state's full name. The design repository's `bin/shots` reaches every state at its address after each sync, checks that the State row names it, hides the design chrome, and captures the surface alone — whole, when it scrolls inside the viewport — so what a reader looks at is the application, never what was drawn around it; it names every page that breaks the contract, for a brief to fix.
- **A page with many states groups them into families.** A family is one situation of the surface — the list, a record, a form in one of its cases — and its states are that situation's variants. The bar gets a Family row above the State row: the Family row picks a family, and the State row shows that family's states alone. A family's states sit together, in the order a reader meets them, so stepping through the bar finishes one family before the next. Each state is named `<Family> · <state>`, or the bare family for its first; the family is the name before the separator, and the markup carries no other grouping. Each tab reads the state part, `Default` for the bare one.
- **A layout is a frame, never a state.** A layout, such as narrow or full, applies to every situation, so a state named for one multiplies the page without showing a new situation. A layout is named for what it shows, never for a width. Every page draws at the default width, and one Layout page per project draws each surface in each of its layouts, at the narrowest width the layout takes, one family per layout; the width goes in the frame's label only. A frame a single state needs, such as a drawer open, belongs to that state's markup, never to its name.
- **No page is drawn again without colour.** That colour never carries meaning alone is held where the meaning is defined — the token set, checked so that no two states share a glyph — and a copy with the colour removed shows nothing the coloured drawing does not.
- **Interaction belongs on a web page; the business does not.** A prototype may animate a drawer opening, a row expanding, a toast arriving — that is the surface. Validations, save rules, time windows, who may write what and the data model belong to the application, stated by its tests and decision records.
- **A terminal client's page is snapshots only.** A terminal redraws a whole grid of cells on each key press, with no hover, transition or reflow between, so one frame per state is everything the user sees. Interaction there is the key map, which is the application's behaviour: a page that answers keys writes it a second time, unchecked. A step through the surface is a run of named states instead, one frame each, named for what the user sees at that point.
- **The test for a sentence on a page: could someone open the running application and find it false?** Then it comes out.
- **The design project keeps no decision log, rulings page or behaviour hand-off.** Each is a second copy of an application record, and drifts from it.
- **A behaviour question raised by drawing goes back as a question.** Each candidate is drawn as its own state, named for what it shows; the question is raised in the design chat, never written on the page, and answered here (§7).
- **A state that needs a paragraph to be understood is a missing state.** Draw it.
- **Sweeping claims out of a page removes sentences, never drawings.** An artboard asserts nothing about the application; one that goes out with the prose around it is a defect, sent back through a brief.
- **A component's example page is a page too.** It shows the component in each case it has, as states, and nothing else. Each of its rules has one home: the shared system's component file once it has landed there, which is where most of them already are; the comment beside the class for a difference only this product has; a request to the shared system when every product should follow it. Options weighed, research and rollout sweeps belong in the design chat and the tracker. Keeping a page does not exempt it from this rule.

**This rule, its markup contract included, goes into the design project's own `readme.md`** when the project is created — added by a person, since a product's design is a Project, which `/design-sync` does not reach: it must hold in every export, and a rule pasted into a brief dies with the brief (§2). A project created before the contract gets it once, as a brief that redraws every page to it; after that no brief restates it.

## 5. A component the product needs: owned by the product, promoted only when generic

Only where a shared design system is vendored (§1).

- **A shared component that serves the job as well as anything could is used as it is.**
- **Otherwise the product owns one.** A component that makes this product's experience better — a widget only its domain needs, or a shape the shared one cannot take without bending — is drawn in the product's project, in its own leaf, and is the product's for good. That the shared system lacks it is no reason to move it there; best-in-class surfaces need components fitted to each product.
- **A component is promoted only once it is generic enough to serve other applications** — its rules hold with this product's domain taken out, and a second application would use it unchanged. Then, and only then, it takes the route below.
- **A promotion Design proposes is an input to that test, never a decision** — whether it comes in the design chat, as a stand-in marker, or as a note in the export, which `bin/sync` refuses. The agent who publishes the export judges each new stand-in marker:
  - **it passes** — the agent amends the shared system's open brief for the component's theme, or opens one for a theme none covers, carrying the stand-in's rules and names byte for byte and none of the steps Design proposed: a brief states the problem and the rules, and the drawing is the shared system's project's to invent;
  - **it fails** — the block loses its marker, through a brief to the product's own project, and stays the product's for good.

  Either way, nothing is written into either repository's export folder.

### Promoting a component: one stand-in, landed by deletion

The product's leaf becomes a stand-in, under a `STAND-IN — delete when the design system lands <Component>` marker, where `<Component>` is the one PascalCase name the shared system will list it under, so a search for that name finds it. The marker form reaches the design project in its own `readme.md`, seeded by the `design-repo` skill, since the project never sees this skill. The request goes in the **shared system's repository**: it amends that repository's open brief for the component's theme in `briefs/proposed/`, or opens `<theme>.brief.md` when none covers it, carrying the same rules and names, byte for byte. The application keeps writing the same names: on the web, the stand-in is a set of classes the markup writes; for a terminal client, it is a token or glyph name the renderer reads, defined in the product's design token set until the shared token set carries it.

- **Byte-identical is the point.** When the component lands, the stand-in is deleted — the classes, or the local definition of the token or glyph — and no markup or renderer call changes; a stand-in that drifted from its brief turns landing into a migration.
- **The request lives with the system that will draw it.** It joins the shared system's open brief for its theme, one theme attached to that project at a time, and leaves the brief once it lands.
- **Delete the stand-in only against a snapshot that carries the component.** Removed against a stale copy of the shared system, the surface loses its styling and nothing fails.

### The project's copy of the shared system, and how it stays current

A product's design project draws every page against `_ds/<id>/`, **its own copy** of the shared system, frozen at the moment it was copied.
The copy does not follow the shared system: a request that lands there reaches this project only when **the project refreshes its copy**, and nothing does that for it. The export carries whatever copy the project holds, so a sync cannot fix a stale one.

**Whether the copy is current is read from the manifests Claude Design writes**, never from a file someone keeps by hand. The shared system's `_ds_manifest.json` and the copy's each list the tokens and components they carry, and Claude Design rewrites both on every export, so neither can fall behind what it describes.

- **`bin/ds-status`** in the product's design repository compares `pages/_ds/<id>/_ds_manifest.json` with the shared system's `system/_ds_manifest.json`, and names every token and component the copy lacks, and every token whose value moved. It sees names and values, not a component whose files changed under the same name.
- **A stand-in has landed** once both manifests list its component and every class its rules name is defined in the copy.
- **The landing, in order** — skipping the second step is how a landed component goes on reading as missing. The `adopt-shared-release` skill runs it, from the release's pin bump in the application to the stand-in's deletion:
  1. the request lands in the shared system's project, and its repository syncs the export;
  2. the product's project refreshes its copy, and its repository syncs that export;
  3. `bin/ds-status` reports the copy current, and both manifests list the component;
  4. the stand-in the landing retires is deleted.
- **A stale copy is refreshed first** — never a reason to re-send a request, never a copy to compare a page against.
- **What landed when is history**, on the tracker; the manifests hold only what each side carries now.

**Rejected: a receipt kept by hand** — landed requests and a date stamp. It is correct only while every export remembers to update it; the manifests are rewritten by Claude Design every time.

## 6. The loop

```
  a brief in <project>-ds/briefs/proposed/
        |
        v
  pasted into the design project                  <- a person
        |
        v
  the project draws it; export downloaded         <- a person
        |
        v
  in <project>-ds: sync (which shoots every page), settle stand-ins,
  regenerate, run the suite
        |
        v
  review the sync diff: a rule changed or only a comment?
  every changed page well-formed? a removal that orphaned a heading?
  a drawing gone with the prose around it? a page bin/shots named?
        |
        v
  commit the mirror, as produced; a defect joins its theme's brief
        |
        v
  in this repository: vendor the artefact         adopt-designs
        |
        v
  build the surface against the page; tests hold the behaviour
        |
        v
  close out the brief it satisfied                brief-closer
```

**The last step is the one that gets skipped**, because nothing fails when it is.

## 7. Writing a brief

**One open brief per theme, named for the theme and amended in place.** A new ask joins the open brief for its theme; a brief opens only for a theme none covers. Briefs opened request by request grow with the work and stop being read. The design repository's `briefs/README.md` carries the house format and the reader rule.

1. **State the constraint; do not cite the artefact.** A decision's ruling is written out as a sentence, with its theme named beside it; the record itself lives where `AGENTS.md`'s design section says decision records do. A link out of the design repository resolves to nothing at the far end.
2. **Every proper noun must resolve inside the design project.** Pages, components, tokens — yes. File paths, commands, frameworks, issue numbers — no, except on the brief's Do-not-edit line, where application paths, issue numbers, checkouts and framework names constrain the deliverable rather than explain it.
3. **A brief never cites another brief.** Each is deleted on its own schedule.
4. **A technical decision belongs in a decision record here, not in the design.** The brief asks Design to *depict* a ruling, never to make it. A behaviour the page must show that nothing has settled is drawn and labelled as an **open question**, never as a rule.

## 8. Closing a brief out

An ask ends when its surface ships here, so the ticket that ships a surface carries a checkbox for its own ask leaving the theme's brief: ticked when the brief is deleted, or amended to drop that ask while the theme's other asks stay pending. Before either: verify each ask in the design project's export, re-point everything that cited it, and rewrite future-tense prose about it.

A brief whose asks all landed closes. One where some did not stays, listing only the remainder. One that got what it asked for while the doing broke something else stays too, listing only what broke: what remains for a theme never opens a brief of its own. The **`brief-closer`** agent does this, in a fixed order that deletes last, when an export lands that may satisfy an open brief as well as at a ticket's checkbox for its ask leaving the brief.

### Before a reshape, triage the queue

A reshape — a sweep or redraw across many pages of the design project — starts only once every open ask has been checked against the current export. An ask is written against the pages as they stood; a reshape that moves them leaves it describing a page that no longer exists, and nobody notices until someone pastes it. So, ask by ask, for every theme's brief in `briefs/proposed/`, before the reshape is asked for:

- **landed** — it leaves its brief through `brief-closer`'s close-out, never a direct delete;
- **outdated** — its premise is gone: drop it from its brief, or rewrite it against the current pages;
- **in the wrong repository** — it changes a shared component: it joins the shared system's open brief for its theme, rewritten for that project, or opens one there only when none covers the theme;
- **still open** — carry it into the brief of the reshape's theme, never a brief spanning themes, or keep it in its own brief and check it again once the reshape's export lands.

A theme's brief left with no ask is deleted by the same close-out. A long queue is the signal to triage, not to reshape: the reshape waits until the queue holds only asks that will survive it.

## 9. What an agent must not do

- **Edit the export mirror**, or the vendored artefact here.
- **Style anything outside what `AGENTS.md`'s build rule allows.** On the web: a colour, a spacing or a component that neither the vendored artefact nor the shared system's package ships. In a terminal: a colour or a glyph outside the vendored token set, the shared system's tokens, the user's overrides and the renderer's defaults. The fix is a brief, not a local rule.
- **Cite a brief or a design page from code.** Cite the decision record for *why* and the test for *what*.
- **Answer a behaviour question on a page.** Behaviour is decided here, in a test.
- **Start a route that §2 says a person starts.**
