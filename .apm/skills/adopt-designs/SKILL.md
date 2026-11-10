---
name: adopt-designs
description: Read what the product's design project published and adopt it — publish in the design checkout, vendor the one generated bundle, report what moved by selector, triage it against the markup, hand the reconciliation to the design-curator agent, and close the briefs it satisfied with brief-closer. Use when the design project has published a new export, when asked to read in, vendor, refresh or adopt a design, or when adopt-shared-release re-vendors.
argument-hint: "[optional path to the design checkout]"
---

# Adopting a design

Two steps, kept apart on purpose.
**Read** takes what the design project published. **Adopt** makes this application use it.

Exactly one generated artefact crosses the boundary, and adoption is a named step with a performer.
The application holds no mirror of the export: a mirror invites reading behaviour out of a mockup, an export's own agent instructions would outrank this repository's, any edit to it is destroyed by the next refresh, and a refreshed mirror changes nothing about whether the application writes the classes the design ships.

If `AGENTS.md` has no design section, this skill does not apply. A section that exists but names nothing is not that case: it is the missing names below.

## Names

Every name comes from `AGENTS.md`'s design section, the way `design-handoff` reads it. None is guessed:

- the design repository, its checkout path, the command that regenerates its bundle, and its suite;
- the bundle, its path in the design repository, and its vendored path here;
- the cascade layer the vendored bundle is loaded in;
- the command that vendors the bundle, and the command that triages it against the markup;
- where the application's own component styles live.

A name the section does not give: stop, ask the person for it, and offer to add it to the section. Do not read on with a guessed one.
A name the section gives as `none` — no cascade layer for a token set, no triage command — skips what needs it, and the report says so.
If `$ARGUMENTS` names a checkout, it replaces the section's checkout path for this run.

## Steps

0. **Publish in the design checkout**, only when the person has downloaded a new export. A re-vendor of a design revision that has already merged, as `adopt-shared-release` sends, starts at step 1: `bin/sync` would mirror whatever export is lying in the download folder. In the design repository, mirror the export with its `bin/sync`, regenerate the bundle, and run its suite. The export mirror is generated: never hand-edit it (`design-handoff` §3). Review the sync diff by selector and by section, never by file, since it is the one moment a defect in an export is cheap to catch:
   - a rule changed, or only a comment? A comment moves no pixel; a rule wants a look at what consumes it;
   - is every changed page still well-formed, and did a removal orphan a heading or take a drawing with the prose around it?
   - did the manifest gain or lose a component? A component lost is a class the application may still write;
   - did `bin/shots` name a page that breaks the markup contract?

   What you find becomes a brief in the design repository's `briefs/proposed/`, never a fix. On a branch of the design repository, commit the mirror as produced, defects named in the message, push, and open its pull request; vendor once it has merged.
1. **Read — vendor the bundle.** Switch the design checkout to its default branch and pull it, so you read what was published and not a stale clone or a feature branch; if it has uncommitted work, or sits on a branch whose work has not merged into the default branch, stop and ask rather than move the person's work. Run the design repository's suite on what you pulled, and stop on red. Then run the vendor command. Never copy the bundle by hand: the vendor command pins the revision it read, and a copy pins nothing. To see whether the design has moved since the last read, compare that pinned revision with the design repository's default branch for the bundle's path; nothing else checks it.
2. **Report — what changed, by selector.** A file-level diff says the bundle changed, which decides nothing. Diff the selectors of the vendored bundle and name the ones that **appeared**, **changed** and **disappeared**. The third is the dangerous one: a selector the application still writes and the design no longer ships is an unstyled element that raises nothing, and a name built in code rather than written in markup is seen by nothing but this diff.
3. **Triage.** Run the triage command. Every decision a new design creates is selector-level: triage reads the vendored bundle against the markup, reports coverage and each outstanding finding, and edits nothing. A finding no guard sees surfaces only in this report.
4. **Adopt, through `design-curator`.** Spawn the `design-curator` agent with step 2's selector report as its task, and the triage output beside it where there is a triage command: a disappeared selector built in code is in the report alone. It reads the bundle, the application's component styles and the markup, and rewrites files the calling session does not need in its context; its constraints are in the agent, so do not restate them. Its direction is one way: the application's copy goes, the design's class gets written. Two things stay with you:
   - **A fix that belongs in the design project** — a wrong rule, a selector to rename, a component that cannot express what a surface needs — is a brief to the design repository, or to the shared design system's when the component is generic (`design-handoff` §5). Write that brief in the design repository's `briefs/proposed/` (`design-handoff` §7), including each one `design-curator` reports, and name it in your report; never patch it locally.
   - **The inline fallback.** If the agent cannot be spawned, read `design-curator` in full and work its procedure in order yourself.
5. **Close out, through `brief-closer`.** An export usually lands because a brief asked for it, and a brief ends when its surface ships. Check the design repository's `briefs/proposed/` against what just arrived and what this application now writes; for each brief whose ask looks landed, spawn the `brief-closer` agent with the brief's name and the export's diff. A brief left after its surface is live goes on telling its reader to build what exists, and nothing fails. If the agent stops with asks outstanding, the brief stays.
6. **Leave the application's tree uncommitted** for the person to review. Its two halves review separately: the vendored bundle is what arrived, everything else is what this application changed to use it. A brief written in step 4 or written or deleted in step 5 goes on a branch of the design repository, created before the first such change and never its default branch, and is left uncommitted there for the same review.

## Must not

- Edit the export mirror or the vendored bundle.
- Translate a design rule into the application's own styles. That is what `design-curator` exists to undo.
- Vendor from a design checkout whose suite is red or whose bundle has uncommitted changes.
- Skip step 5 because nothing fails without it.
- Commit in the application.
