# design-sync notes for __NAME__

- **This repository mirrors its Design System; it is not a component library for the converter.** `"shape": "mirror"` records that: a `/design-sync` run pushes named paths and never imports components from here, and re-adopting the Design System to match this repository would delete what it draws.
- **What flows up:** everything under `system/` but `templates/`, as named paths with no deletes. <!-- FILL: the paths, if they differ. -->
- **What flows down:** `templates/`, the starter layouts the Design System draws for the Projects linked to it, mirrored by `bin/sync`.
- **A push that renames or removes a token travels with a brief.** The system's components paint by token name, and a renamed one leaves them unstyled until they are repainted.

<!-- FILL: anything else a future /design-sync must know about this repository. -->
