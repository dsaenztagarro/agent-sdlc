# Design briefs

The requests made to the **__NAME__** Claude Design project, and nothing else.
A brief is an **input**: the problem, who it is for and what it must do — then out of the way, so the project can invent the answer.
It is handed over by copy-paste, so it travels as text, and nothing it links to travels with it.

## Lifecycle — a brief ends when what it asked for lands

```
briefs/proposed/  ->  the project draws it  ->  bin/sync mirrors the export  ->  deleted
```

Everything in a brief is in the future tense, so once its surface ships, every sentence tells its reader to do work already done.
Before deleting one, verify each ask in the mirrored export, not in anyone's word that it landed, and check its durable half has a home: a ruling in the consuming application's decision record, the drawing in the export, the behaviour in the application's tests.
What is left — the drawing instructions, the jobs, the out of scope — is spent, and git history keeps it.

| what you find | the brief |
|---|---|
| every ask landed, cleanly | deleted |
| some landed, others did not | stays, listing only what remains |
| every ask landed, but the doing broke something | stays, listing only what broke |

`git log --diff-filter=D -- briefs/` finds a deleted brief again.

## One open brief per theme

**A new ask amends the open brief for its theme; a brief opens only for a theme no open brief covers.**
A brief per request grows with the work and stops being read; a brief per theme stays the one place that says what is still pending for that area, the way a decision amends its theme's record.

- A brief is named for its theme, `<theme>.brief.md`, never for the change it asks.
- An ask a delivery left undone stays in its brief, which then lists only what remains.
- A defect found while reviewing an export joins the open brief for its theme.

## What belongs here

<!-- FILL: for a product's design — its own surfaces; a shared component it needs is a brief in the shared system's repository. For a shared design system — what every consuming application shares; one application's screens belong in that application's design repository. -->

## Writing one

A brief opens with a header of four lines:

- **For:** the Claude Design project that draws it;
- **Produces:** the pages or components it asks for;
- **Do-not-edit:** what the deliverable must leave alone, and why;
- **Status:** what is still open in it.

Then:

- **The problem first,** and who meets it, in the first person where a workflow is described.
- **Jobs as outcomes,** never mechanisms. Name existing pages and components as context to extend, never as the prescribed answer, and invite a better shape.
- **The principles that genuinely bind,** and nothing that merely describes.
- **Out of scope,** stated, so the project does not draw past the ask.
- **The durable half lands first.** A ruling the surface depends on is recorded in the consuming application's decision record before the brief is written, so deleting the brief later loses nothing.
- **Design depicts, never decides.** The brief states the ruling in a sentence and asks the project to draw it; a ruling nobody has recorded is written down first, and a behaviour nothing has settled is drawn as an open question.
- **Never cite another brief.** Each is deleted on its own schedule.
- **Ask for the surface, never the application's behaviour.**
- **A rule that must hold for every export is never written into a brief.** It goes into the design project's own `readme.md` through `/design-sync`, which the project reads before it draws; pasted into briefs, each copy dies with its brief and the copies drift. `rake` fails when two open briefs share a line of 80 characters or more outside their headers.

## Write for the reader, who sees only the design project

A brief is read inside the Claude Design project, which holds its own pages, components and tokens and nothing else.
An unresolvable reference is worse than none: the reader cannot check it, so it reconstructs a rationale, and a wrong one produces a confidently wrong design.

- **State the ruling; don't cite where it was decided.** A link resolves to nothing inside the project; name the record's theme beside the sentence if it helps the application's side.
- **Every proper noun must resolve inside the design project.** Name its pages, components and tokens freely.
- **Application paths, issue numbers, repository checkouts and framework names appear only on the Do-not-edit line,** where they constrain the deliverable rather than explain it.

Before handing a brief over, read it as someone holding only the design project: every sentence is either checkable by opening a file they have, or a constraint plain enough to act on.
