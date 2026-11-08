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
4. **Check the design copy.** Add a temporary worktree of the shared system's repository at the ref the design section maps the pinned version to, never moving the person's own checkout. Run the design repository's `bin/ds-status` with that worktree's path, then remove the worktree.
   - **Stale:** stop the landing. Delete nothing. Hand the person, in order: refresh the copy in the product's Claude Design project, download the export, run `bin/sync` in the design repository. Then compare each stand-in's selectors with the stylesheet the new pin ships. If any stand-in redeclares one, the pin stays too: undo steps 1-3, because a stand-in wins only for the properties it sets and the bundle's other properties stack on it. Only when none does may steps 1-3 ship alone as the application's pull request. Run this skill again once the copy is current.
   - **Current:** a component has landed only when both the shared system's manifest and the copy's list it. `current` alone proves nothing for a component the shared repository never synced: then neither manifest lists it, its stand-in stays, and the person is told the shared repository's export is behind. For each landed component, delete the block marked `STAND-IN — delete when the design system lands <Component>` where the design repository authors it. A stand-in that exists only in the export mirror is never hand-edited (`design-handoff` §3): its deletion is a brief to the product's design project. If such a stand-in redeclares a selector the new bundle ships, the pin waits for that brief to land: undo steps 1-3, and run this skill again once the export without the stand-in is synced. Then regenerate the artefact, run the design repository's suite, and re-vendor it into the application through `adopt-designs`.
5. **Delete the unmarked copies.** A local rule for a landed component, marked or not, goes — in the design repository's authored sources and in the application's own component styles. A variant the shared system does not ship stays local, and is named in the pull request as the subject of a brief to the shared system.
6. **One pull request per repository** — the application, the design repository — each opening with `## Sequence`: its ticket, and the other repository's pull request as the previous or next one. The design repository's merges first, since the application vendors what it generates. In the application, the pin and the re-vendor without the stand-ins are one pull request whenever a stand-in redeclares a selector the new bundle ships; the pin goes alone only when none does.

## Must not

- Delete a stand-in on a stale or unchecked copy, or because the release notes say the component landed while the manifests do not list it.
- Ship the pin while a stand-in that redeclares a selector the new bundle ships is still vendored.
- Re-send a request to the shared system because the copy is stale. The copy is refreshed first.
- Move any other dependency in the same pull request.
- Edit the export mirror or the vendored artefact.
