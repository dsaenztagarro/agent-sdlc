# The vendor contract

What a project's vendor command does, whatever its language, and the tests and guards that hold it.
`adopt-designs` runs the vendor command and trusts what this contract makes it guarantee: the vendored file says which revision of the design repository it is, and any edit after vendoring fails the gate.
Each adopter implements it once, in its own stack, and names the command in `AGENTS.md`'s design section.

## One writer, one stamp per file

**The vendor command is the only path that writes a vendored file, and every file it writes carries a stamp.**
A second script that copies from the design repository writes a file nothing can trace; fold it into the vendor command or delete it.
A file generated here from the vendored artefact — code compiled from a token set — is not vendored: it carries no stamp, and is held by its own regenerate-and-compare test instead.

The stamp is the file's first line, in the artefact's own comment syntax:

```
stylesheet bundle:
/* vendored from <design repository>@<revision> sha256:<digest> — re-vendor with <vendor command>, never edit by hand */

token set:
# vendored from <design repository>@<revision> sha256:<digest> — re-vendor with <vendor command>, never edit by hand
```

- `<design repository>` is the name `AGENTS.md`'s design section gives.
- `<revision>` is the full object name of the design checkout's `HEAD`, never abbreviated.
- `<digest>` is the lowercase hex SHA-256 of every byte that follows the stamp line, exactly as published.

The stamp and the digest are what let this repository, which holds none of the artefact's sources, tell a faithful copy from an edited one.

## Refusals

The vendor command refuses, writes nothing, and exits non-zero when:

1. **The checkout is not the design repository:** the artefact's source path does not exist in it, or its `origin` remote does not name the design repository.
2. **The published artefact is dirty:** `git status --porcelain -- <artefact source>` prints anything. A revision is a pin only if it contains the bytes copied.
3. **`HEAD` is not on the remote yet:** `git merge-base --is-ancestor HEAD origin/<default branch>` exits non-zero. A revision no one else can fetch pins nothing for the reviewer.

A refusal message names exactly what was checked and the fix for that check, never a broader fix: a message saying "push it" for a check that only saw an uncommitted change sends the reader after the wrong thing.

## How it runs git

- **Every environment variable whose name begins `GIT_` is removed** from git's environment. Under a git hook, `GIT_DIR` and `GIT_INDEX_FILE` name the calling repository and win over `-C`, so a vendor run from a hook would otherwise read the application's own repository.
- **Only stdout is the answer.** A git whose file-system monitor does not respond still answers, with a warning on stderr; read as output, that warning is an uncommitted change that is not there. Stderr goes only into the message of a failed command, and a failed command is a refusal.

## What it prints

The previous revision, read from the stamp it replaces (`none` on a first vendor), and the new one:

```
<artefact vendored at>: <previous revision> -> <new revision>
```

Whether the new revision is the current one is not the vendor command's to say: comparing it with the design repository's default branch stays a human step.

## The five tests

Each adopter writes these, in its own stack, under these names, against a real temporary git repository with a bare remote standing in for the design repository — never a stubbed git:

- `the vendored bytes match the digest` — every vendored file in the application starts with a stamp whose digest matches the bytes after it. It runs in the gate, so an unstamped file from a second path fails it too.
- `an edit breaks the digest` — one byte changed after the stamp, and the digest check fails.
- `vendoring pins HEAD` — vendoring from the fixture stamps its `HEAD`'s full revision and the design repository's name.
- `a dirty artefact is refused` — an uncommitted change to the published artefact is refused, and the vendored file is left as it was.
- `a stderr warning is not read as dirty` — a git that writes a warning to stderr and a clean status to stdout vendors normally. A wrapper on `PATH` that writes the warning and then runs the real git is the one double this needs: the warning cannot be produced otherwise.

## The guards an adopter writes

The triage in `adopt-designs` marks each finding with the guard that catches it, or `NO GUARD`. These are the kinds of guard, each in its form for a stylesheet bundle (web) and for a token set (terminal). A kind the project has not written yet is one more `NO GUARD` in every triage.

| guard | web, stylesheet bundle | terminal, token set |
|---|---|---|
| **triage** | a class the markup writes that no shipped stylesheet declares fails the build; a class the bundle ships that no markup writes is reported as coverage, not failed | a token name the code reads that the vendored set does not define fails the build; a name the set ships that no code reads is reported as coverage, not failed |
| **ownership** | no application selector that the design declares: one selector, one home | no colour or glyph literal outside the token loader |
| **precedence** | the cascade layer order, documented once and tested once | the order among the vendored set, the shared system's tokens, the user's overrides and the renderer's defaults, documented once and tested once |
| **parity** | a node's computed style against the same node on the design page, in the same state | one golden frame per page state, ANSI-stripped so it holds composition only, compared against that state, or recorded as deferred in the theme's decision record |
