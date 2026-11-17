# agent-sdlc

My Claude Code plugins, and the project template they run on.

The template gives an agent one set of rules to read (`AGENTS.md`), a bounded place for decisions (`docs/adr/`), a delivery loop that runs on the issue tracker, and the **Claude Design** step that produces a UI's design before anyone builds it.
Use it as a GitHub template, fill the `<!-- FILL: … -->` placeholders in `AGENTS.md`, and install the plugins once per machine.

> Everything here is language- and framework-agnostic: no application code, no build tool, no reference to a specific project.

## The plugins

Installed once per machine from this repository's marketplace, never copied into a project: every project on the machine reads the same copy, and `claude plugin update` moves them all.

```bash
claude plugin marketplace add dsaenztagarro/agent-sdlc
```

| Plugin | Does | Install |
|---|---|---|
| [`sdlc`](plugins/sdlc/README.md) | the delivery pipeline on the issue tracker: plan, build, amend, review, close, pause, resume, release and roadmap | `claude plugin install sdlc@agent-sdlc` |
| [`ds`](plugins/ds/README.md) | the Claude Design handoff: design repositories, briefs, reading an export back and adopting it | `claude plugin install ds@agent-sdlc` |

Each plugin's README lists its skills and agents.

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

## What's in the template

| | |
|---|---|
| `AGENTS.md`, `CLAUDE.md` | The rules every task needs, and a routing table to the rest. `CLAUDE.md` is `@AGENTS.md`. |
| `.claude/rules/testing.md` | The testing rules, as a path-scoped rule that loads when a test or a stateful component is opened. It comes with the template, not a plugin, so a plugin update never overwrites the `paths:` you fill. |
| `docs/adr/` | One decision record per theme, amended in place; its history is `git log -p`. [`decision-records.md`](docs/adr/decision-records.md) says why every corpus an agent reads is bounded. |
| `docs/SECURITY.md` | Where secrets live and what is never committed. |
| `.github/workflows/pr-title.yml` | Holds every pull request title to a Conventional Commit, so the squash subject versions the release. |
| `.claude/settings.local.json.example` | Local permissions, attribution and a format-on-write hook slot; the real file is git-ignored. |
| `.claude-plugin/marketplace.json`, `plugins/` | The `agent-sdlc` marketplace and its plugins, above. |

## Applying the template to a new project

```bash
# 1. create the repository, private unless it is meant to be public
gh repo create <owner>/<project> --template dsaenztagarro/agent-sdlc --private --clone
cd <project>

# 2. fill the placeholders, and the testing rule's paths:
grep -n 'FILL' AGENTS.md .claude/rules/testing.md docs/SECURITY.md

# 3. drop the template's own marketplace and its distribution record (and that record's row in docs/adr/README.md):
#    the plugins install per machine, above
rm -rf .claude-plugin plugins docs/adr/distribution.md
git commit -am "chore: start from agent-sdlc"

# 4. squash with the pull request title, so the reviewed title versions the release
gh api -X PATCH repos/<owner>/<project> -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY

# 5. local settings; the real file is git-ignored
cp .claude/settings.local.json.example .claude/settings.local.json
```

**A UI whose colours the product owns** gets a design repository: run `/ds:repo`, and fill the block of names in `AGENTS.md`'s design section. A surface that takes all its colours from its host, or no UI at all, deletes the design section and records why in the theme's decision record.

## License

[MIT](LICENSE) © David Saenz
