# agent-sdlc

A project-agnostic scaffold for building software with coding agents, on any codebase.

It gives an agent one set of rules to read (`AGENTS.md`), a bounded place for decisions (`docs/adr/`), a delivery loop that runs on the issue tracker, and the **Claude Design** step that produces a UI's design before anyone builds it.
Use it as a GitHub template, fill the `<!-- FILL: … -->` placeholders in `AGENTS.md`, and install the shared skills as an APM package.

> Everything here is language- and framework-agnostic: no application code, no build tool, no reference to a specific project.

## The workflow at a glance

```
  a design brief       Claude Design        AGENTS.md          one pull request
  (<project>-ds)  -->  draws the page  -->  the rules     -->  per coherent change,
                       (<project>-ds)       every agent        evidence in its body,
                                            obeys              squashed with its title
                                                                        |
                                                                        v
                              docs/adr/  one record per theme  <--  tests state the rules
```

1. **Design.** For a UI, a **brief** goes to a Claude Design project, which draws the page. Briefs, pages and the export live in a sibling `<project>-ds` repository; one generated artefact crosses into the application.
2. **Deliver.** One coherent change is one branch and one pull request, sized for one review, built in its own worktree. Work too large for one review is planned on one parent issue and shipped in batches.
3. **Remember, within a bound.** Behaviour is stated by tests, the *why* amends one of a few themed decision records, commands live in the README and procedures in skills. Nothing grows one file per ticket, decision or feature.

A person approves the plan and merges; the finished work is reviewed at the end.

## What's in the box

| | |
|---|---|
| `AGENTS.md`, `CLAUDE.md` | The rules every task needs, and a routing table to the rest. `CLAUDE.md` is `@AGENTS.md`. |
| `.claude/rules/testing.md` | The testing rules, as a path-scoped rule that loads when a test or a stateful component is opened. It comes with the template, not the package, so an `apm install` never overwrites the `paths:` you fill. |
| `docs/adr/` | One decision record per theme, amended in place; its history is `git log -p`. [`decision-records.md`](docs/adr/decision-records.md) says why every corpus an agent reads is bounded. |
| `docs/SECURITY.md` | Where secrets live and what is never committed. |
| `.github/workflows/pr-title.yml` | Holds every pull request title to a Conventional Commit, so the squash subject versions the release. |
| `.claude/settings.local.json.example` | Local permissions, attribution and a format-on-write hook slot; the real file is git-ignored. |
| `.apm/` | The package an adopter installs: the design skills and agents below. |

### The package

Installed with [APM](https://github.com/microsoft/apm) into `.claude/skills/` and `.claude/agents/`. Nothing in it names a project: what it needs to know, it reads from the adopter's `AGENTS.md` design section.

| | Does |
|---|---|
| `design-repo` | creates a design repository from one skeleton, or brings an existing one to the current skeleton |
| `design-handoff` | the Claude Design procedure: which repository is which, the routes into the design project, briefs, reading an export back; [`layout.md`](.apm/skills/design-handoff/layout.md) is a design repository's layout |
| `adopt-designs` | vendors the design's one artefact under a revision stamp and digest ([`vendor-contract.md`](.apm/skills/adopt-designs/vendor-contract.md)), reports what moved, and hands adoption to `design-curator` |
| `adopt-shared-release` | lands a shared design system's release in a product, deleting a stand-in only once the product's copy is current |
| `template-feedback` | sends a reusable workflow improvement upstream, as one item on the template's open feedback issue |
| `design-curator` (agent) | deletes the application's copies of what the design ships, and uses what it ships instead |
| `brief-closer` (agent) | verifies a brief's asks landed, then deletes or amends it |

### The delivery pipeline, at user level

Planning, batch building, review, fix, close and release run through user-level tracker skills (`/tracker-plan`, `tracker-batch`, `tracker-review`, `tracker-fix`, `/tracker-close`, `/tracker-release`), installed once per person and never copied into a project. Without them, follow the contract by hand:

- **A plan is a marked section of the parent issue's description**, replaced in place when it changes.
- **Every ticket and every pull request opens with `## Sequence`:** the previous and the next.
- **One worktree per writer, one pull request per batch;** a person merges.
- **Review findings are threads on the pull request**, fixed one commit each.
- **A ticket closes only with evidence:** each done-when line against a named test or a command's real output; a live check an agent cannot run goes to a person as exact commands.
- **A release versions from the Conventional Commit types** since the last tag, into a CHANGELOG entry and an annotated tag.

## Applying the template to a new project

```bash
# 1. create the repository, private unless it is meant to be public
gh repo create <owner>/<project> --template dsaenztagarro/agent-sdlc --private --clone
cd <project>

# 2. fill the placeholders, and the testing rule's paths:
grep -n 'FILL' AGENTS.md .claude/rules/testing.md docs/SECURITY.md

# 3. replace the template's own package with a dependency on it
rm -rf .apm apm.yml
apm init --yes --target claude
apm install dsaenztagarro/agent-sdlc#v<version>
git add apm.yml apm.lock.yaml .gitignore .claude/
git commit -m "chore: install agent-sdlc"

# 4. squash with the pull request title, so the reviewed title versions the release
gh api -X PATCH repos/<owner>/<project> -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY

# 5. local settings; the real file is git-ignored
cp .claude/settings.local.json.example .claude/settings.local.json
```

**A UI whose colours the product owns** gets a design repository: run the `design-repo` skill, and fill the block of names in `AGENTS.md`'s design section. A surface that takes all its colours from its host, or no UI at all, deletes the design section and records why in the theme's decision record.

Commit what `apm install` deploys, so a clone has the skills without APM; `apm update` takes a newer release.

## License

[MIT](LICENSE) © David Saenz
