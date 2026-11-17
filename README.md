# agent-sdlc

A project-agnostic scaffold for building software with coding agents, on any codebase.

It gives an agent one set of rules to read (`AGENTS.md`), a bounded place for decisions (`docs/adr/`), a delivery loop that runs on the issue tracker, and the **Claude Design** step that produces a UI's design before anyone builds it.
Use it as a GitHub template, fill the `<!-- FILL: … -->` placeholders in `AGENTS.md`, and install its two Claude Code plugins, `sdlc` and `design`, once per machine.

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
| `.claude/rules/testing.md` | The testing rules, as a path-scoped rule that loads when a test or a stateful component is opened. It comes with the template, not a plugin, so a plugin update never overwrites the `paths:` you fill. |
| `docs/adr/` | One decision record per theme, amended in place; its history is `git log -p`. [`decision-records.md`](docs/adr/decision-records.md) says why every corpus an agent reads is bounded. |
| `docs/SECURITY.md` | Where secrets live and what is never committed. |
| `.github/workflows/pr-title.yml` | Holds every pull request title to a Conventional Commit, so the squash subject versions the release. |
| `.claude/settings.local.json.example` | Local permissions, attribution and a format-on-write hook slot; the real file is git-ignored. |
| `.claude-plugin/marketplace.json`, `plugins/` | The `agent-sdlc` marketplace and its two plugins, below. |

### The plugins

Installed once per machine from this repository's marketplace, never copied into a project: every project on the machine reads the same copy, and `claude plugin update` moves them all. Nothing in them names a project: what they need to know, they read from the adopter's `AGENTS.md`.

```bash
claude plugin marketplace add dsaenztagarro/agent-sdlc
claude plugin install sdlc@agent-sdlc
claude plugin install design@agent-sdlc
```

**`sdlc`**, the delivery pipeline on the issue tracker (GitHub Issues or Jira):

| | Does |
|---|---|
| `/sdlc:plan` | publishes a confirmed plan as a marked section of the epic, with the tickets it calls for |
| `/sdlc:build` | builds a ticket, or an epic's next batch one ticket at a time, to a reviewed and walked pull request, then closes it once merged |
| `/sdlc:review` | reviews a pull request, proves each finding by walking the product, fixes what pays for itself, and posts the rest on the pull request |
| `/sdlc:amend` | moves new scope on near-ready work into the ticket or epic that owns it |
| `/sdlc:close` | closes a ticket with evidence for each done-when line |
| `/sdlc:pause`, `/sdlc:resume` | leave and pick up a "Where I stopped" note on the ticket, including runs in flight |
| `/sdlc:release` | versions merged work from its Conventional Commit types, with a CHANGELOG entry and a tag |
| `/sdlc:roadmap` | says where the project stands across its epics, and housekeeps and audits on request |
| `/sdlc:git-push` | pushes with a rebase first, never forcing past a refusal |
| `/sdlc:template-feedback` | sends a reusable workflow improvement upstream, as one item on the template's open feedback issue |

**`design`**, the Claude Design handoff:

| | Does |
|---|---|
| `design-repo` | creates a design repository from one skeleton, or brings an existing one to the current skeleton |
| `design-handoff` | the Claude Design procedure: which repository is which, the routes into the design project, briefs, reading an export back; [`layout.md`](plugins/design/skills/design-handoff/layout.md) is a design repository's layout |
| `adopt-designs` | vendors the design's one artefact under a revision stamp and digest ([`vendor-contract.md`](plugins/design/skills/adopt-designs/vendor-contract.md)), reports what moved, and hands adoption to `design-curator` |
| `adopt-shared-release` | lands a shared design system's release in a product, deleting a stand-in only once the product's copy is current |
| `figma` | reads a Figma frame through the REST API when the Figma MCP refuses a call |
| `design-curator` (agent) | deletes the application's copies of what the design ships, and uses what it ships instead |
| `brief-closer` (agent) | verifies a brief's asks landed, then deletes or amends it |

### The delivery pipeline

Without the `sdlc` plugin, follow its contract by hand:

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

# 3. drop the template's own marketplace and its distribution record (and that record's row in docs/adr/README.md):
#    the plugins install per machine, above
rm -rf .claude-plugin plugins docs/adr/distribution.md
git commit -am "chore: start from agent-sdlc"

# 4. squash with the pull request title, so the reviewed title versions the release
gh api -X PATCH repos/<owner>/<project> -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY

# 5. local settings; the real file is git-ignored
cp .claude/settings.local.json.example .claude/settings.local.json
```

**A UI whose colours the product owns** gets a design repository: run the `design-repo` skill, and fill the block of names in `AGENTS.md`'s design section. A surface that takes all its colours from its host, or no UI at all, deletes the design section and records why in the theme's decision record.

## License

[MIT](LICENSE) © David Saenz
