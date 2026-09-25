# Decision records

One record per **theme**, capped at ten.
Each answers the question a future maintainer actually asks — *"why is it built this way?"* — which is the one thing a closed pull request throws away.

A reader asking what has been decided about anything opens **one** file and reads the current position.
That only stays true while the set is small enough to read, which is why it is capped rather than merely organised.

## The bar

A decision record holds reasoning that is not recoverable from the code. Before writing anything down, check it clears all three:

- **A real fork.** There were at least two defensible options and one was chosen. If there was only ever one way to do it, the code says so better than prose can.
- **Consequence beyond the change.** A data-model contract, a cross-cutting convention, a security boundary, a wire promise, a thing deliberately *not* built. Not a local code choice, however careful.
- **Nothing else can hold it.** Behaviour belongs in tests, the mechanism in a topic guide (`docs/guide-<topic>.md`). A decision record is for the part none of those record: the reasoning.

**A record is not** a schema, a census of the current code, a rollout plan or a ticket list. Prose records *why*, never *what the code currently does*.

## One record per theme, from a closed list

A decision **amends the record that owns its theme**. It never opens a second file — not for a reversal, not for an extension, not for a decision that builds on an earlier one.

| # | Theme | Owns |
|---|---|---|
| [0001](0001-decision-records.md) | Decision records | how this project records decisions, what goes where, and why it is bounded |

<!-- FILL: one row per theme, added when the project's first decision in that area is made. Name a theme for an area of the product — storage, the wire contract, the terminal surface — never for a single decision. -->

A decision that fits no theme is the maintainer's call, not an agent's: **stop and ask.**
An eleventh record must argue, in its own context section, which themes were considered and why the decision fits none of them.

## Amending a record

1. Open the theme's record and change the rule. An amendment usually **replaces** a rule; it rarely appends one.
2. Record the change as one line on the theme's `decision-log` issue — the date, what changed, why — linking the commit rather than pasting the displaced passage. Git holds the prose; the issue is the findable index.
3. Stay under **sixty lines**. If the record will not fit, something in it has stopped being a decision — find it and move it out.

The log lives on the tracker rather than at the foot of the record because a log inside the record grows for as long as the theme is alive, and every line of it is loaded by every reader who opens the record for its current position.

## What earns a line

- **A rejected option earns one line only if someone would reach for it tomorrow**: the option, and why it lost. Its job is stopping the rebuild. An option that lost to a condition no longer true goes to the decision-log issue.
- **A fork deliberately left open always stays**, with the condition that would reopen it. It is current state, not history, and the cheapest line in the record.

## Conventions

- **Sections:** Context · Decisions · Rejected · Left open · References. Copy [`template.md`](template.md).
- **Diagrams are ASCII** (`+ - | v ^ >`).
- **Prose is one line per paragraph, or semantic line breaks**, never hard-wrapped at a column.
- **Code cites a record by theme, in words** — "the storage record" — never by quoting a passage that an amendment will change.
- **The cap and the ceiling are checked** by `.github/workflows/docs.yml`, so an eleventh record or a seventy-line one fails the build rather than a review.
