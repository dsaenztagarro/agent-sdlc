---
name: adopt-shared-release
description: Land a shared design system's release in a product — move the pin, fix what the release removed, then retire the stand-ins the release lands, only once the product's design-system copy is current. Runs the landing order of design-handoff §5. Use when a shared design system ships a release, when bumping the package that carries it, or when asked to delete a stand-in for a component the shared system now ships.
---

# Adopting a shared design system's release

The landing order of `design-handoff` §5, run end to end.
A release reaches the product in two places: the application, through its pin on the shared system's package, and the product's design project, through its `_ds/` copy, which only a person refreshes.
A stand-in is deleted only after both carry the component; deleted against a stale copy, the surface loses its styling and nothing fails.

If the project vendors no shared design system, this skill does not apply.

## Names

Every name comes from `AGENTS.md`: its design section, and the gate from its CI / gate section. None is guessed:

- the shared design system, its package, its repository's checkout path, the ref of that repository a released version corresponds to, and where it publishes release notes;
- the command that moves its pin, and the one that syncs its tokens, if the project syncs them;
- the gate;
- the design repository, its checkout path, the command that regenerates its artefact, and its suite;
- where the application's own component styles live.

A name the section does not give: stop and ask the person for it, then offer to add it to the section.

## Steps

1. **Move the pin, conservatively.** Update only the shared system's package, with the project's own update command and its flag for leaving every other dependency where it is. If the release moved tokens, sync them the project's way.
2. **Read the release's notes for consumers.** Each selector, class or token the release removed or renamed is fixed in the application's markup against the new pin. A removal with no replacement the product needs is a brief to the shared system's repository, never a local rule.
3. **Run the gate, then drive one surface** that renders the shared system's components, and look at it. A green gate does not show a lost style.
4. **Check the design copy.** Add a temporary worktree of the shared system's repository at the ref the design section maps the pinned version to, never moving the person's own checkout. Run the design repository's `bin/ds-status` with that worktree's path, and read the shared manifest from the same worktree below; remove it once this step is done.
   - **Stale:** stop the landing. Delete nothing. Hand the person, in order: refresh the copy in the product's Claude Design project, download the export, run `bin/sync` in the design repository. Every stand-in stays.
   - **Current:** a component has landed only when both the shared system's manifest and the copy's list it. `current` alone proves nothing for a component the shared repository never synced: then neither manifest lists it, its stand-in stays, and the person is told the shared repository's export is behind. Each landed component's block marked `STAND-IN — delete when the design system lands <Component>`, where the design repository authors it, is to be deleted, but only once the pin check in the next bullet finds no overlap. A stand-in that exists only in the export mirror is never hand-edited (`design-handoff` §3): it stays, and its deletion is a brief to the product's design project.
   - **The pin holds for every local rule the landing keeps** for a component the release ships, marked or not, whichever branch kept it, and it is checked before anything is deleted: each stand-in that stays, and each unmarked rule in the design repository's authored sources or the application's own component styles that step 5 does not delete — on a stale copy step 5 never runs, so every such rule is kept and checked, landed component or not — and each unmarked rule in the export mirror outside its `_ds/` snapshot, which is never hand-edited and so always kept; the snapshot is the shared system's own copy, not a local rule, and carries the landed component by design. Compare each one's selectors with the stylesheet the new pin ships. If any redeclares one, undo steps 1-3, delete nothing, and run this skill again once what kept it is resolved, because a local rule wins only for the properties it sets and the pinned stylesheet's other properties stack on it. Only when none does may the landing go on: on a current copy, delete the landed stand-ins; on a stale one, steps 1-3 ship alone as the application's pull request.
5. **Delete the unmarked copies, then regenerate once.** A local rule for a landed component, marked or not, goes — in the design repository's authored sources and in the application's own component styles. A variant the shared system does not ship stays local, and is named in the pull request as the subject of a brief to the shared system. Only then regenerate the artefact and run the design repository's suite. The application re-vendors it through `adopt-designs` once the design repository's pull request has merged (step 6), so it vendors a published revision.
6. **Pull requests, each opening with `## Sequence`:** its ticket, and its neighbours across both repositories as the previous and next ones.
   - The design repository gets one, and it merges before the application's re-vendor, since the application vendors what it generates.
   - The application gets one holding the pin, the re-vendor and the deletions from its own component styles whenever a local rule deleted in step 4 or 5 redeclared a selector in the new pin's stylesheet. Only when none did may the pin go first as its own pull request, with the re-vendor and those deletions in a second one after the design repository's.

## Must not

- Delete a stand-in on a stale or unchecked copy, or before the pin hold is checked, or because the release notes say the component landed while the manifests do not list it.
- Ship the pin while a local rule the landing keeps, a stand-in or an unmarked rule, redeclares a selector in the new pin's stylesheet.
- Re-send a request to the shared system because the copy is stale. The copy is refreshed first.
- Move any other dependency in the same pull request.
- Edit the export mirror or the vendored artefact.
