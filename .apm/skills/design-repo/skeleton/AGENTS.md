# __NAME__

The rules an agent working in this design repository needs. The consuming application's own rules are in its `AGENTS.md`.
<!-- FILL: link the consuming application's AGENTS.md, or for a shared design system, name the applications that consume it. -->

## Which files flow which way

<!-- FILL: name every path that is authored here and pushed up with /design-sync; everything else in the export folder is drawn in the project and mirrored down, and is never edited here. -->

## Generated, not copied

`dist/` is generated from the export by `rake`, and `rake` fails when the two disagree. Never edit `dist/` or the export folder by hand.

## The layout is fixed

`test/layout_test.rb` holds this repository to the layout every design repository keeps. It is a copy: change the rule where the copy comes from, never here.

## A request belongs to the project that will draw it

A brief for this project goes in `briefs/proposed/`. A request for something a shared design system should own goes in that system's repository, as a brief there.
