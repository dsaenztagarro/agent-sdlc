# Design briefs

The requests made to the **__NAME__** Claude Design project, and nothing else.
A brief is an **input**: the problem, who it is for and what it must do — then out of the way, so the project can invent the answer.

## Lifecycle — a brief ends when what it asked for lands

```
briefs/proposed/  ->  the project draws it  ->  bin/sync mirrors the export  ->  deleted
```

Before deleting one, verify each ask in the mirrored export, not in anyone's word that it landed, and check its durable half has a home: a ruling in the consuming application's decision record, the drawing in the export, open work in an issue.
`git log --diff-filter=D -- briefs/` finds a deleted brief again.

## What belongs here

<!-- FILL: for a product's design — its own surfaces; a shared component it needs is a brief in the shared system's repository. For a shared design system — what every consuming application shares; one application's screens belong in that application's design repository. -->

## Writing one

- **One self-contained `<topic>.brief.md` per request.**
- **Every proper noun must resolve inside the design project.** The project sees its own files and nothing else: name pages, components and tokens; never a path, a command, an issue number or a framework.
- **State the ruling; don't cite where it was decided.** A link resolves to nothing inside the project.
- **Never cite another brief.** Each is deleted on its own schedule.
- **Ask for the surface, never the application's behaviour.** A behaviour the drawing raises comes back as an open question.
