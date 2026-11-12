# frozen_string_literal: true

require_relative "test_helper"
require "fileutils"
require "open3"
require "rbconfig"
require "tmpdir"

# What the layout check refuses in a repository's export folders.
#
# A repository is one Claude Design kind, the one bin/sync's KIND names: a Project mirrored into
# pages/, or a Design System mirrored into system/. Without a check tying the folders to the kind,
# an application's design uploaded as a Design System goes unnoticed. A Project's repository may
# keep under system/ only what bin/sync pushes upstream.
#
# Each test runs a copy of test/layout_test.rb and of bin/sync in a throwaway checkout, since the
# check reads the files git tracks beside it.
class LayoutCheckTest < Minitest::Test
  CHECK = File.expand_path("layout_test.rb", __dir__)
  SYNC = File.expand_path("../bin/sync", __dir__)
  EXPORT_FOLDER = "test_the_only_export_folder_is_the_one_bin_sync_names"

  def teardown
    FileUtils.rm_rf(@root) if @root
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

  private

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

  def check(rule)
    out, err, status = Open3.capture3(RbConfig.ruby, File.join(@root, "test/layout_test.rb"), "-n", rule)
    [status, out + err]
  end
end
