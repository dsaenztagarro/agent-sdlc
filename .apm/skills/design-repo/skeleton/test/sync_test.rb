# frozen_string_literal: true

require_relative "test_helper"
require "fileutils"
require "open3"
require "tmpdir"

# What bin/sync lets into this repository.
#
# The mirror is `rsync --delete`, so whatever an export carries becomes this repository's truth,
# and every refusal has to happen before anything is copied: an incomplete export, the other kind,
# a page that is not one canonical prototype, an edit to a file this repository authors. Authoring
# screenshots never cross; behaviour artefacts cross and are reported, so their arrival is news.
# Each test runs a copy of bin/sync in a throwaway checkout, set to the export kind under test,
# because the script resolves its target from its own location and a real run would mirror over
# this repository.
class SyncTest < Minitest::Test
  SCRIPT = File.expand_path("../bin/sync", __dir__)

  def teardown
    FileUtils.rm_rf(@root) if @root
  end

  test "a project export is mirrored into pages with its design-system snapshot" do
    checkout(kind: "project")
    project_export

    status, out = sync

    assert status.success?, out
    assert_path_exists File.join(@root, "pages/surface.html")
    assert_path_exists File.join(@root, "pages/_ds/shared/_ds_manifest.json")
  end

  test "a project mirror is followed by shots, and a breach does not undo it" do
    checkout(kind: "project")
    project_export
    File.write(File.join(@root, "bin/shots"), "#!/bin/sh\ntouch \"$(dirname \"$0\")/../shot\"\nexit 1\n")
    File.chmod(0o755, File.join(@root, "bin/shots"))

    status, out = sync

    assert status.success?, out
    assert_path_exists File.join(@root, "shot")
    assert_path_exists File.join(@root, "pages/surface.html")
  end

  test "a design-system export is mirrored into system" do
    checkout(kind: "system")
    system_export

    status, out = sync

    assert status.success?, out
    assert_path_exists File.join(@root, "system/components/button.css")
  end

  test "an export of the other kind is refused" do
    checkout(kind: "system")
    project_export

    status, out = sync

    refute status.success?
    assert_includes out, "project export"
    refute_path_exists File.join(@root, "system")
  end

  test "an export with no design-system manifest is refused and nothing is mirrored" do
    checkout(kind: "project")
    project_export
    FileUtils.rm(File.join(@export, "_ds/shared/_ds_manifest.json"))

    status, out = sync

    refute status.success?
    assert_includes out, "_ds_manifest.json"
    refute_path_exists File.join(@root, "pages")
  end

  # A web export carries its root stylesheet; a terminal export carries none, so the list is the
  # repository's, and an empty one refuses nothing.
  test "an export missing a root file the repository requires is refused" do
    checkout(kind: "project", required: ["styles.css"])
    project_export

    status, out = sync

    refute status.success?
    assert_includes out, "styles.css"
    refute_path_exists File.join(@root, "pages")
  end

  test "a page that is not one canonical prototype per surface is refused" do
    checkout(kind: "project")
    project_export
    pages = ["surface-v2.html", "timer v1.html", "parity-audit.html", "tab-rationale.html", "back-link-options.html"]
    pages.each { |page| File.write(File.join(@export, page), "") }

    status, out = sync

    refute status.success?
    pages.each { |page| assert_includes out, page }
    refute_path_exists File.join(@root, "pages")
  end

  test "an export carrying behaviour artefacts is mirrored and reported as a contract regression" do
    checkout(kind: "project")
    project_export
    FileUtils.mkdir_p(File.join(@export, "spec-notes"))
    File.write(File.join(@export, "spec-notes/save-rules.md"), "")
    File.write(File.join(@export, "list-rulings.html"), "")

    status, out = sync

    assert status.success?, out
    assert_includes out, "surface-only contract"
    assert_includes out, "pages/spec-notes"
    assert_includes out, "pages/list-rulings.html"
    assert_path_exists File.join(@root, "pages/spec-notes/save-rules.md")
  end

  test "authoring screenshots in an export are never mirrored" do
    checkout(kind: "project")
    project_export
    FileUtils.mkdir_p(File.join(@export, "screenshots"))
    File.write(File.join(@export, "screenshots/list.txt"), "")
    File.write(File.join(@export, "draft.png"), "")
    File.write(File.join(@export, "draft.jpg"), "")

    status, out = sync

    assert status.success?, out
    assert_path_exists File.join(@root, "pages/surface.html")
    assert_empty Dir.glob("{screenshots,*.png,*.jpg}", base: File.join(@root, "pages"))
  end

  test "a symlinked snapshot is replaced by the export's own" do
    checkout(kind: "project")
    project_export
    elsewhere = File.join(@root, "elsewhere")
    FileUtils.mkdir_p(elsewhere)
    File.write(File.join(elsewhere, "local.css"), "")
    FileUtils.mkdir_p(File.join(@root, "pages/_ds"))
    File.symlink(elsewhere, File.join(@root, "pages/_ds/shared"))

    status, out = sync

    assert status.success?, out
    refute File.symlink?(File.join(@root, "pages/_ds/shared"))
    assert_path_exists File.join(@root, "pages/_ds/shared/_ds_manifest.json")
    assert_path_exists File.join(elsewhere, "local.css"), "the checkout the link pointed at is left alone"
  end

  test "an export that disagrees with a file authored here is refused" do
    checkout(kind: "system", upstream: ["system/tokens/colors.css:tokens/colors.css"])
    system_export
    write(File.join(@root, "system/tokens/colors.css"), "--accent: blue;")
    File.write(File.join(@export, "tokens/colors.css"), "--accent: red;")

    status, out = sync

    refute status.success?
    assert_includes out, "tokens/colors.css"
    assert_equal "--accent: blue;", File.read(File.join(@root, "system/tokens/colors.css"))
  end

  # A product repository mirrors into pages/ and authors its palette under system/: the guard reads
  # the authored file where it lives, not under the export folder.
  test "an authored palette outside the export folder is compared with the export's copy" do
    checkout(kind: "project", upstream: ["system/tokens/colors.css:_ds/shared/tokens/colors.css"])
    project_export
    write(File.join(@root, "system/tokens/colors.css"), "--accent: blue;")
    write(File.join(@export, "_ds/shared/tokens/colors.css"), "--accent: blue;")

    status, out = sync

    assert status.success?, out
    assert_path_exists File.join(@root, "pages/surface.html")

    FileUtils.rm_rf(File.join(@root, "pages"))
    File.write(File.join(@export, "_ds/shared/tokens/colors.css"), "--accent: red;")

    status, out = sync

    refute status.success?
    assert_includes out, "_ds/shared/tokens/colors.css"
    refute_path_exists File.join(@root, "pages")
  end

  private

  def checkout(kind:, upstream: [], required: [])
    @root = Dir.mktmpdir("design-repo-sync")
    FileUtils.mkdir_p(File.join(@root, "bin"))
    script = File.read(SCRIPT)
      .sub(/^KIND=".*"$/, %(KIND="#{kind}"))
      .sub(/^UPSTREAM=\(.*\)$/, "UPSTREAM=(#{upstream.map { |entry| %("#{entry}") }.join(' ')})")
      .sub(/^REQUIRED_ROOT_FILES=\(.*\)$/, "REQUIRED_ROOT_FILES=(#{required.join(' ')})")
    File.write(File.join(@root, "bin/sync"), script)
    File.chmod(0o755, File.join(@root, "bin/sync"))
    @export = File.join(@root, "export")
  end

  def project_export
    write(File.join(@export, "_ds/shared/_ds_manifest.json"), "{}")
    write(File.join(@export, "surface.html"), "<main></main>")
  end

  def system_export
    write(File.join(@export, "_ds_manifest.json"), "{}")
    write(File.join(@export, "components/button.css"), ".btn{}")
    write(File.join(@export, "tokens/colors.css"), "--accent: blue;")
  end

  def write(path, body)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, body)
  end

  def sync
    out, err, status = Open3.capture3(File.join(@root, "bin/sync"), @export)
    [status, out + err]
  end
end
