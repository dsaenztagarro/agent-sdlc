# frozen_string_literal: true

require "minitest/autorun"
require "open3"

# Every design repository keeps one layout — the `design-handoff` skill's layout.md — so that an
# agent who has worked in one finds its way around any other. Design repositories drift after they
# are created, not when: a snapshot symlinked from a local checkout, an export folder named after
# its repository. Each test below is one closed rule of that layout with a real failure behind it;
# whether a given file exists is left to the skill that creates a repository.
#
# Copied from the agentic-sdlc `design-repo` skill. Change it there and copy it
# again; a local edit here forks the rule from every other design repository.
class LayoutTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  ROOT_FOLDERS = %w[briefs pages system references vendor docs lib test dist bin .design-sync .claude .github].freeze
  ROOT_FILES = %w[README.md AGENTS.md CLAUDE.md Rakefile .gitignore LICENSE].freeze
  EXPORT_FOLDERS = %w[pages system].freeze

  def test_every_top_level_entry_is_one_the_layout_names
    entries = tracked.map { |path| path.split("/").first }.uniq
    folders, files = entries.partition { |entry| tracked.any? { |path| path.start_with?("#{entry}/") } }

    assert_empty folders - ROOT_FOLDERS, "a folder the layout does not name — amend layout.md first, or move it"
    assert_empty files - ROOT_FILES, "a root file the layout does not name"
  end

  def test_nothing_tracked_is_a_symlink
    symlinks = git("ls-files", "-s").lines.select { |line| line.start_with?("120000") }.map { |line| line.split("\t").last.strip }

    assert_empty symlinks, "what a clone renders, builds or tests must come from that clone, not another checkout"
  end

  def test_nothing_under_an_export_folder_is_ignored
    present = EXPORT_FOLDERS.select { |folder| File.directory?(File.join(ROOT, folder)) }
    skip "no export folder yet" if present.empty?

    ignored = git("ls-files", "--others", "--ignored", "--exclude-standard", "--directory", "--", *present).lines.map(&:strip)

    assert_empty ignored, "an export is committed as produced; an ignored part of it renders differently on every clone"
  end

  def test_an_open_brief_is_one_topic_brief_md_in_briefs_proposed
    briefs = tracked.select { |path| path.start_with?("briefs/") } - ["briefs/README.md"]
    misplaced = briefs.reject { |path| path.match?(%r{\Abriefs/proposed/[^/]+\.brief\.md\z}) }

    assert_empty misplaced
  end

  def test_a_vendored_shared_system_is_a_name_ds_folder
    vendored = tracked.select { |path| path.start_with?("vendor/") }
    misplaced = vendored.reject { |path| path.match?(%r{\Avendor/[a-z0-9-]+-ds/}) }

    assert_empty misplaced
  end

  def test_claude_md_only_imports_agents_md
    path = File.join(ROOT, "CLAUDE.md")
    skip "no CLAUDE.md" unless File.file?(path)

    assert_equal "@AGENTS.md", File.read(path).strip, "the rules live once, in AGENTS.md"
  end

  def test_scratch_staging_and_editor_state_stay_untracked
    probes = ["tmp/probe", ".DS_Store", ".claude/worktrees/probe"]
    tracked_anyway = probes.reject { |probe| ignored?(probe) }

    assert_empty tracked_anyway, "bin/sync stages into tmp/; Finder state and worktrees never belong in git"
  end

  private

  def tracked
    @tracked ||= git("ls-files").lines.map(&:strip)
  end

  def ignored?(path)
    _out, _err, status = Open3.capture3("git", "-C", ROOT, "check-ignore", "-q", "--no-index", path)
    status.success?
  end

  # stdout only: a git that cannot reach its file-system monitor still answers, with a warning on stderr.
  def git(*args)
    out, err, status = Open3.capture3("git", "-C", ROOT, *args)
    raise "git #{args.join(' ')} failed: #{err}" unless status.success?

    out
  end
end
