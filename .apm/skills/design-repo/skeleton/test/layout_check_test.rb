# frozen_string_literal: true

require_relative "test_helper"
require "fileutils"
require "open3"
require "rbconfig"
require "tmpdir"

# What the layout check refuses in a repository's briefs.
#
# A rule that must hold for every export lives in the design project's own readme.md; pasted into
# each open brief, every copy dies with its brief and the copies drift apart meanwhile. The check
# finds a long line repeated verbatim across two briefs, and leaves alone the header lines every
# brief carries. Each test runs a copy of test/layout_test.rb in a throwaway checkout, since the
# check reads the briefs git tracks beside it.
class LayoutCheckTest < Minitest::Test
  CHECK = File.expand_path("layout_test.rb", __dir__)
  RULE = "Every colour a surface uses exists in the token set as a decision token, and a surface names it."

  def teardown
    FileUtils.rm_rf(@root) if @root
  end

  test "a rule repeated in two open briefs belongs in the project's readme" do
    checkout(
      "board.brief.md" => brief("Board", RULE, "Draw the board's columns."),
      "composer.brief.md" => brief("Composer", RULE, "Draw the composer."),
      "progress.brief.md" => brief("Progress", "Draw every workflow in flight.")
    )

    status, out = check

    refute status.success?, out
    assert_includes out, RULE
    assert_includes out, "briefs/proposed/board.brief.md and briefs/proposed/composer.brief.md"
    refute_includes out, "progress.brief.md"
    assert_includes out, "readme.md"
  end

  test "the header lines every brief carries are not a repeated rule" do
    header = "this is an input to the design project, and it is deleted once the surface it asks for ships here"
    checkout(
      "board.brief.md" => brief("Board", "Draw the board's columns.", do_not_edit: header),
      "composer.brief.md" => brief("Composer", "Draw the composer.", do_not_edit: header)
    )

    status, out = check

    assert status.success?, out
    assert_includes out, "1 runs, ", "the check ran"
  end

  # A request may carry a component's complete files, and two such files can share a long line.
  test "code quoted in two briefs is not a repeated rule" do
    code = "```css\n/* #{'-' * 80} */\n@layer product { .callout { padding: var(--space-2); border-color: var(--border-subtle); } }\n```"
    checkout(
      "board.brief.md" => brief("Board", "Draw the board's columns.", code),
      "composer.brief.md" => brief("Composer", "Draw the composer.", code)
    )

    status, out = check

    assert status.success?, out
    assert_includes out, "1 runs, ", "the check ran"
  end

  private

  def brief(theme, *body, do_not_edit: "this is an input")
    <<~MD
      # Brief — #{theme}

      **For:** Claude Design
      **Produces:** the #{theme} page
      **Do not edit:** #{do_not_edit}
      **Status:** proposed

      #{body.join("\n\n")}
    MD
  end

  def checkout(briefs)
    @root = Dir.mktmpdir("design-repo-layout")
    FileUtils.mkdir_p(File.join(@root, "test"))
    FileUtils.cp(CHECK, File.join(@root, "test/layout_test.rb"))
    FileUtils.mkdir_p(File.join(@root, "briefs/proposed"))
    briefs.each { |name, body| File.write(File.join(@root, "briefs/proposed", name), body) }
    git("init", "-q")
    git("add", "-A")
  end

  def git(*args)
    _out, err, status = Open3.capture3("git", "-C", @root, *args)
    raise "git #{args.join(' ')} failed: #{err}" unless status.success?
  end

  def check
    out, err, status = Open3.capture3(RbConfig.ruby, File.join(@root, "test/layout_test.rb"),
                                      "-n", "test_no_rule_is_repeated_in_two_open_briefs")
    [status, out + err]
  end
end
