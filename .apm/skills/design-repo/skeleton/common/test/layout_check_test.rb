# frozen_string_literal: true

require_relative "test_helper"
require "fileutils"
require "open3"
require "rbconfig"
require "tmpdir"

# What the layout check refuses in a repository's briefs and in its export folders.
#
# A rule that must hold for every export lives in the design project's own readme.md; pasted into
# each open brief, every copy dies with its brief and the copies drift apart meanwhile. The check
# finds a long line repeated verbatim across two briefs, and leaves alone the header lines every
# brief carries.
#
# A repository is one Claude Design kind, the one bin/sync's KIND names: a Project mirrored into
# pages/, or a Design System mirrored into system/. Without a check tying the folders to the kind,
# an application's design uploaded as a Design System goes unnoticed. A Project's repository may
# keep under system/ only what bin/sync pushes upstream.
#
# Each test runs a copy of test/layout_test.rb, and of bin/sync where the kind matters, in a
# throwaway checkout, since the check reads the files git tracks beside it.
class LayoutCheckTest < Minitest::Test
  CHECK = File.expand_path("layout_test.rb", __dir__)
  SYNC = File.expand_path("../bin/sync", __dir__)
  RULE = "Every colour a surface uses exists in the token set as a decision token, and a surface names it."
  REPEATED_RULE = "test_no_rule_is_repeated_in_two_open_briefs"
  EXPORT_FOLDER = "test_the_only_export_folder_is_the_one_bin_sync_names"
  NAMED_KIND = "test_bin_sync_names_the_kind_of_project_it_mirrors"

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

    line = "**Do not edit** the exported copy of this project by hand — it is mirrored from the design project."
    checkout(
      "board.brief.md" => "# Board\n\n#{line}\n\nDraw the board's columns.\n",
      "composer.brief.md" => "# Composer\n\n#{line}\n\nDraw the composer.\n"
    )

    status, out = check

    assert status.success?, "a header field may be bold without a colon:\n#{out}"
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

  test "a repository holds the export folder its sync kind names, and not the other" do
    kind_checkout(kind: "project", files: ["pages/list.html"])

    status, out = check(EXPORT_FOLDER)

    assert status.success?, out
    assert_includes out, "0 skips", "the check ran"

    kind_checkout(kind: "project", files: ["pages/list.html", "system/components/button.css"])

    status, out = check(EXPORT_FOLDER)

    refute status.success?, out
    assert_includes out, "system/components/button.css"

    kind_checkout(kind: "system", files: ["system/components/button.css", "pages/list.html"])

    status, out = check(EXPORT_FOLDER)

    refute status.success?, out
    assert_includes out, "pages/list.html"
  end

  # A Project's palette is authored here and pushed up, and its export carries it under _ds/.
  test "a project repository may hold system/ only for the paths its sync pushes upstream" do
    palette = "system/tokens/colors.css"
    kind_checkout(kind: "project", upstream: ["#{palette}:_ds/shared/tokens/colors.css"],
                  files: ["pages/list.html", palette])

    status, out = check(EXPORT_FOLDER)

    assert status.success?, out
    assert_includes out, "0 skips", "the check ran"

    kind_checkout(kind: "project", upstream: ["#{palette}:_ds/shared/tokens/colors.css"],
                  files: ["pages/list.html", palette, "system/templates/app.html"])

    status, out = check(EXPORT_FOLDER)

    refute status.success?, out
    assert_includes out, "system/templates/app.html"
    refute_includes out, %("#{palette}")
  end

  test "bin/sync names the kind of project it mirrors" do
    kind_checkout(kind: "__KIND__")

    status, out = check(NAMED_KIND)

    refute status.success?, out
    assert_includes out, "KIND is project"
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
    repository do
      FileUtils.mkdir_p(File.join(@root, "briefs/proposed"))
      briefs.each { |name, body| File.write(File.join(@root, "briefs/proposed", name), body) }
    end
  end

  # bin/sync filled in as the design-repo skill fills it, and an empty file at each path.
  def kind_checkout(kind:, upstream: [], files: [])
    repository do
      FileUtils.mkdir_p(File.join(@root, "bin"))
      script = File.read(SYNC)
        .sub(/^KIND=".*"$/, %(KIND="#{kind}"))
        .sub(/^UPSTREAM=\(.*\)$/, "UPSTREAM=(#{upstream.map { |entry| %("#{entry}") }.join(' ')})")
      File.write(File.join(@root, "bin/sync"), script)
      files.each do |path|
        FileUtils.mkdir_p(File.dirname(File.join(@root, path)))
        File.write(File.join(@root, path), "")
      end
    end
  end

  def repository
    FileUtils.rm_rf(@root) if @root
    @root = Dir.mktmpdir("design-repo-layout")
    FileUtils.mkdir_p(File.join(@root, "test"))
    FileUtils.cp(CHECK, File.join(@root, "test/layout_test.rb"))
    yield
    git("init", "-q")
    git("add", "-A")
  end

  def git(*args)
    _out, err, status = Open3.capture3("git", "-C", @root, *args)
    raise "git #{args.join(' ')} failed: #{err}" unless status.success?
  end

  def check(rule = REPEATED_RULE)
    out, err, status = Open3.capture3(RbConfig.ruby, File.join(@root, "test/layout_test.rb"), "-n", rule)
    [status, out + err]
  end
end
