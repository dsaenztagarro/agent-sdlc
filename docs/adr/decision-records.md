# Decision records

**Status:** Live · **Decision log:** <!-- FILL: this theme's decision-log issue -->

How this project writes things down: which artefact owns which fact, and why every corpus an agent reads has a bound.

## Context

An agent reads the repository at the start of every task, and its context is finite. Every durable document competes for it.

The corpora that fail are the ones whose file count grows with the work: a decision record per decision, a spec per feature, a feature page per capability, an archive of shipped briefs. Each file is fine; the corpus stops being readable, and then stops being read. One project using this workflow reached 64 decision records in three months — one every 33 hours — before consolidating them into thirteen themes.

## Decisions

### Every corpus an agent reads is bounded by design, not by discipline

A kind of document may grow with the product's *areas* — themes, topics — but never with its *work items* — decisions, features, tickets, briefs. A generator that writes one file per work item is a defect in the generator.

### One owner per fact

| fact | owner |
|---|---|
| what the code does | a test, named for the rule it states |
| why it is built this way | the decision record for its theme |
| how a mechanism works | the topic guide, `docs/guide-<topic>.md`, with its slides |
| work still open | an issue |
| what a surface looks like | the design repository's page |

Prose never records what the code currently does. A claim about code state in a durable document is born rotting; "not yet built" is work status and belongs on an issue.

### Records are a few broad themes, named for the theme, and amended in place

A decision amends its theme's record and never opens a sibling. The superseded reasoning moves to the theme's decision-log issue; git holds the text. [The README](README.md) carries the bar and the procedure.

What keeps the set small is the breadth of each theme, not a number: a theme is drawn wide enough that the next decision in its area lands in it, and a new record has to argue why no existing theme fits.

A record is named for its theme — `storage.md`, not `0004-storage.md`. A record amended in place is always current, so an order of creation says nothing about it, and a citation that reads "the storage record" needs no lookup where "0004" does.

### An input is deleted when what it produced ships

A brief, a backend design, a review — each is written in the future tense, so once its output exists it instructs the reader to do work already done. Its durable half moves to a record, a test or an issue, and the input is deleted.

### An instruction is placed by when it is needed

`AGENTS.md` holds only what applies to every task. What applies to one area is a path-scoped rule in `.claude/rules/`, which loads when a matching file is read; a procedure is a skill, whose body loads only when invoked. Before writing a rule down, name the test that would fail if it were broken, and write that instead.

## Rejected

- **Immutable records superseded by new files.** Optimises for an audit trail git already keeps, and shelves a wrong decision beside the right one.
- **A feature page per capability.** Its whole content is a narrative of current behaviour, so the folder is born rotting.
- **A behaviour spec per feature, cited from code.** Duplicates the tests in prose that cannot fail, and grows with every feature.
- **A fixed cap on the number of records, or a line ceiling per record, enforced by a check.** A count says nothing about whether the themes are broad, and a ceiling pushes a growing theme to split into narrow ones — the per-decision ledger again, one step removed.
- **Numbering records.** Numbers order immutable per-decision records; a theme record is amended in place, so the number carries nothing and a merged theme leaves a gap to explain.

## Left open

- **A spec for a contract no test can hold** — a rule binding surfaces that do not exist yet. Reopens when one appears; it goes in the owning theme's record first.

## References

[`README.md`](README.md) · [`template.md`](template.md)
