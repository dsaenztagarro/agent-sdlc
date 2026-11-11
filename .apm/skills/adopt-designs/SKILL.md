---
name: adopt-designs
description: Read what the product's design project published and adopt it — publish in the design checkout, vendor the one generated artefact (a stylesheet bundle or a token set) under its revision stamp, report what moved by selector or by token name, triage it with each finding marked guarded or NO GUARD, hand the reconciliation to the design-curator agent, and close the briefs it satisfied with brief-closer. Use when the design project has published a new export, when asked to read in, vendor, refresh or adopt a design, or when adopt-shared-release re-vendors. Not for a release of the shared design system: that is adopt-shared-release, which moves the pin and checks the stand-ins before it re-vendors through this skill.
argument-hint: "[optional path to the design checkout]"
---

# Adopting a design

Two steps, kept apart on purpose.
**Read** takes what the design project published. **Adopt** makes this application use it.

Exactly one generated artefact crosses the boundary, and adoption is a named step with a performer.
The application holds no mirror of the export: a mirror invites reading behaviour out of a mockup, an export's own agent instructions would outrank this repository's, any edit to it is destroyed by the next refresh, and a refreshed mirror changes nothing about whether the application uses what the design ships.

If `AGENTS.md` has no design section, this skill does not apply. A section that exists but names nothing is not that case: it is the missing names below.

## Names

Every name comes from `AGENTS.md`'s design section, the way `design-handoff` reads it. None is guessed:

- the design repository, its checkout path, the command that regenerates its artefact, and its suite;
- the artefact's form — a stylesheet bundle or a token set — its path in the design repository, and its vendored path here;
- the command that vendors the artefact, and the command that triages it against the application;
- where the application's own component styles live;
- the shared design system's repository checkout path, if the project extends one, for a brief step 4 sends there.

A name the section does not give: stop, ask the person for it, and offer to add it to the section. Do not read on with a guessed one.
A name the section gives as `none` — no triage command, no shared design system — skips what needs it, and the report says so. An artefact given as nothing vendored yet is read the same way: the steps that need it are skipped, and the report gives the reason the section states.
If `$ARGUMENTS` names a checkout, it replaces the section's checkout path for this run.

**The form decides the unit every step reads by.** A stylesheet bundle is read by selector, against the markup that writes its classes. A token set is read by token name, against the code that reads its names. Steps 1-3 give both; follow the one the section declares, and never mention the other's unit in the report: a token set has no selectors, and a bundle's colours are not tokens.

## Steps

0. **Publish in the design checkout**, only when the person has downloaded a new export. A re-vendor of a design revision that has already merged, as `adopt-shared-release` sends, starts at step 1: `bin/sync` would mirror whatever export is lying in the download folder. If the design checkout has uncommitted work, or sits on a branch whose work has not merged, stop and ask rather than move it; otherwise branch from its default branch. Then mirror the export with its `bin/sync`, regenerate the artefact, and run its suite. The export mirror is generated: never hand-edit it (`design-handoff` §3). Review the sync diff by rule and by section, never by file, since it is the one moment a defect in an export is cheap to catch:
   - a rule changed, or only a comment? A comment moves no pixel; a rule wants a look at what consumes it;
   - is every changed page still well-formed, and did a removal orphan a heading or take a drawing with the prose around it?
   - did the manifest gain or lose a component? A component lost is a class or a token the application may still read;
   - did `bin/shots` name a page that breaks the markup contract?

   What you find becomes a brief in the design repository's `briefs/proposed/`, never a fix, committed with the mirror on the branch below. On a branch of the design repository, commit the mirror as produced, defects named in the message, push, and open its pull request; vendor once it has merged.
1. **Read — vendor the artefact.** Switch the design checkout to its default branch and pull it, so you read what was published and not a stale clone or a feature branch; if it has uncommitted work, or sits on a branch whose work has not merged into the default branch, stop and ask rather than move the person's work. Run the design repository's suite on what you pulled, and stop on red. Then run the vendor command, and quote the previous and the new revision it prints. Never copy the artefact by hand: the vendor command stamps the revision it read and the digest of what it wrote, and a copy pins nothing. What the vendor command must do — the stamp, its refusals, the git environment — is [`vendor-contract.md`](vendor-contract.md); a vendor command that does not do it is a defect to raise, not a reason to copy by hand. A refusal is the answer: fix what it names, never work around it. Whether the design has moved since the last read is a human check: compare the stamped revision with the design repository's default branch for the artefact's path; nothing else checks it.
2. **Report — what changed, by the form's unit.** A file-level diff says the artefact changed, which decides nothing. Name what **appeared**, what **changed** and what **disappeared**, and flag every disappearance:
   - *A stylesheet bundle:* diff its selectors. A selector the application still writes and the design no longer ships is an unstyled element that raises nothing, and a class name built in code rather than written in markup is seen by nothing but this diff.
   - *A token set:* diff its token names, and for each changed one say what moved — a value, a fallback, what it references. A name the code still reads and the set no longer defines is a build failure at best, and at worst a surface quietly repainted by whatever the name now resolves to. A token whose value alone changed needs nothing in the application: the code reads the name, and the new value arrives with it.
3. **Triage.** Run the triage command. It reads the vendored artefact against the application — a bundle's selectors against the markup, a token set's names against the code that reads them — reports coverage and each outstanding finding, and edits nothing. **Mark every finding as guarded or `NO GUARD`.** Guarded names the guard in the gate that fails while the finding stands; `NO GUARD` means this report is the only place the finding is visible, so it is never dropped, and the report says which guard kind would have caught it (the kinds are in [`vendor-contract.md`](vendor-contract.md)).
4. **Adopt, through `design-curator`.** Spawn the `design-curator` agent with step 2's report as its task, the artefact's form named, and the marked triage output beside it where there is a triage command: a disappeared name built in code is in the report alone. It reads the artefact, the application's own styles or token reads, and the page that governs each surface, and rewrites files the calling session does not need in its context; its constraints are in the agent, so do not restate them. Its direction is one way: the application's copy goes, and what the design ships is used in its place. Two things stay with you:
   - **A fix that belongs in the design project** — a wrong rule, a selector or token to rename, a component or token that cannot express what a surface needs — is a brief to the design repository, or to the shared design system's when the component is generic (`design-handoff` §5). Write that brief in that repository's `briefs/proposed/` (`design-handoff` §7), including each one `design-curator` reports, and name it in your report; never patch it locally. A brief for the shared system goes in a new worktree of the repository whose checkout the design section gives for it, on a branch cut from its default branch, never moving the person's own checkout; it is left uncommitted like the rest, and your report names the worktree's path.
   - **A note for the ticket** that `design-curator` returns — a small, local defect — is named in your report for the person to raise; it is never dropped, and never posted by the agent.
   - **The inline fallback.** If the agent cannot be spawned, read `design-curator` in full and work its procedure in order yourself.
5. **Close out, through `brief-closer`.** An export usually lands because a brief asked for it, and a brief ends when its surface ships. Check the design repository's `briefs/proposed/` against what just arrived and what this application now uses; for each brief whose ask looks landed, spawn the `brief-closer` agent with the brief's name and the export's diff. A brief left after its surface is live goes on telling its reader to build what exists, and nothing fails. If the agent stops with asks outstanding, the brief stays.
6. **Leave the application's tree uncommitted** for the person to review. Its two halves review separately: the vendored artefact, and any file generated here from it, is what arrived; everything else is what this application changed to use it. The pull request that carries it states the previous and the new stamped revision, and what appeared, changed and disappeared. A brief written in step 4 or written or deleted in step 5 goes on a branch of the design repository, created before the first such change and never its default branch, and is left uncommitted there for the same review.

## Must not

- Edit the export mirror or the vendored artefact.
- Translate a design rule into the application's own styles or literals. That is what `design-curator` exists to undo.
- Vendor from a design checkout whose suite is red, or past a refusal of the vendor command.
- Drop a `NO GUARD` finding: nothing else will show it.
- Skip step 5 because nothing fails without it.
- Commit in the application.
