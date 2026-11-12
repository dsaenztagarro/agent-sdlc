# frozen_string_literal: true

require_relative "test_helper"
require "fileutils"
require "open3"
require "tmpdir"

# What bin/sync lets into this repository.
#
# The mirror is `rsync --delete`, so whatever an export carries becomes this repository's truth,
# and every refusal has to happen before anything is copied: an incomplete export, the other kind,
# a note beside the pages, an edit to a file this repository authors. Authoring screenshots never cross.
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

  # templates/ holds the starter layouts a Design System offers the projects that use it: it is
  # part of the system, never one application's pages.
  test "a design system export carrying templates/ is mirrored into system/" do
    checkout(kind: "system")
    system_export
    write(File.join(@export, "templates/app.html"), "<main></main>")

    status, out = sync

    assert status.success?, out
    assert_path_exists File.join(@root, "system/templates/app.html")
    refute_path_exists File.join(@root, "pages")
  end

  test "a design system export is refused by a project repository" do
    checkout(kind: "project")
    system_export

    status, out = sync

    refute status.success?
    assert_includes out, "system export"
    refute_path_exists File.join(@root, "pages")
  end

  test "a project export is refused by a design system repository" do
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

  # A request written into the export reaches no brief, and the next export can delete it unseen.
  test "an export carrying a note beside its pages is refused, and nothing is mirrored" do
    checkout(kind: "project")
    project_export
    File.write(File.join(@export, "promote-table-loading.md"), "# Promote the loading rows\n")
    write(File.join(@export, "notes/plan.md"), "")

    status, out = sync

    refute status.success?
    assert_includes out, "promote-table-loading.md"
    assert_includes out, "notes/plan.md"
    assert_includes out, "open brief"
    assert_includes out, "PROJECT_FILES", "a file the project keeps on purpose has a remedy besides deletion"
    refute_path_exists File.join(@root, "pages")
  end

  test "a note is refused whatever its Markdown extension is spelled" do
    checkout(kind: "project")
    project_export
    write(File.join(@export, "home/PLAN.MD"), "")
    write(File.join(@export, "home/plan.markdown"), "")

    status, out = sync

    refute status.success?
    assert_includes out, "home/PLAN.MD"
    assert_includes out, "home/plan.markdown"
    refute_path_exists File.join(@root, "pages")
  end

  test "the project's own readme, AGENTS and CLAUDE files are mirrored" do
    checkout(kind: "project")
    project_export
    %w[readme.md AGENTS.md CLAUDE.md].each { |file| File.write(File.join(@export, file), "") }

    status, out = sync

    assert status.success?, out
    %w[readme.md AGENTS.md CLAUDE.md].each { |file| assert_path_exists File.join(@root, "pages", file) }
  end

  test "the project's own files are recognised whatever their case" do
    checkout(kind: "project")
    project_export
    File.write(File.join(@export, "README.md"), "")

    status, out = sync

    assert status.success?, out
    assert_path_exists File.join(@root, "pages/README.md")
  end

  test "a note inside the design-system snapshot is mirrored" do
    checkout(kind: "project")
    project_export
    write(File.join(@export, "_ds/shared/components/tables/Table.prompt.md"), "")

    status, out = sync

    assert status.success?, out
    assert_path_exists File.join(@root, "pages/_ds/shared/components/tables/Table.prompt.md")
  end

  # A design system's export documents each component in Markdown of its own, wherever it sits.
  test "a pattern in the project's own files reaches every folder" do
    checkout(kind: "system", project_files: ["readme.md", "*.prompt.md"])
    system_export
    write(File.join(@export, "components/buttons/Button.prompt.md"), "")

    status, out = sync

    assert status.success?, out
    assert_path_exists File.join(@root, "system/components/buttons/Button.prompt.md")
  end

  test "a note in a folder the mirror never copies is not judged" do
    checkout(kind: "project")
    project_export
    FileUtils.mkdir_p(File.join(@export, "scraps"))
    File.write(File.join(@export, "scraps/idea.md"), "")

    status, out = sync

    assert status.success?, out
    assert_path_exists File.join(@root, "pages/surface.html")
  end

  test "authoring screenshots in an export are never mirrored" do
    checkout(kind: "project")
    project_export
    FileUtils.mkdir_p(File.join(@export, "screenshots"))
    File.write(File.join(@export, "screenshots/list.txt"), "")
    File.write(File.join(@export, "draft.png"), "")

    status, out = sync

    assert status.success?, out
    assert_path_exists File.join(@root, "pages/surface.html")
    assert_empty Dir.glob("{screenshots,*.png}", base: File.join(@root, "pages"))
  end

  test "a photograph a page draws is mirrored with it" do
    checkout(kind: "project")
    project_export
    write(File.join(@export, "assets/photo.jpg"), "")
    File.write(File.join(@export, "surface.html"), %(<main><img src="assets/photo.jpg"></main>))

    status, out = sync

    assert status.success?, out
    assert_path_exists File.join(@root, "pages/assets/photo.jpg")
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

  test "an authored file missing on either side is named as missing" do
    checkout(kind: "system", upstream: ["system/tokens/colors.css:tokens/colors.css"])
    system_export

    status, out = sync

    refute status.success?
    assert_includes out, "system/tokens/colors.css is missing from this repository"
    refute_path_exists File.join(@root, "system/components")

    write(File.join(@root, "system/tokens/colors.css"), "--accent: blue;")
    FileUtils.rm(File.join(@export, "tokens/colors.css"))

    status, out = sync

    refute status.success?
    assert_includes out, "the export is missing tokens/colors.css"
    refute_path_exists File.join(@root, "system/components")
  end

  test "an upstream entry that does not name its path in the export is refused" do
    checkout(kind: "system", upstream: ["tokens/colors.css"])
    system_export

    status, out = sync

    refute status.success?
    assert_includes out, "<path in this repository>:<path in the export>"
    refute_path_exists File.join(@root, "system/components")
  end

  private

  def checkout(kind:, upstream: [], required: [], project_files: nil)
    @root = Dir.mktmpdir("design-repo-sync")
    FileUtils.mkdir_p(File.join(@root, "bin"))
    script = File.read(SCRIPT)
      .sub(/^KIND=".*"$/, %(KIND="#{kind}"))
      .sub(/^UPSTREAM=\(.*\)$/, "UPSTREAM=(#{upstream.map { |entry| %("#{entry}") }.join(' ')})")
      .sub(/^REQUIRED_ROOT_FILES=\(.*\)$/, "REQUIRED_ROOT_FILES=(#{required.join(' ')})")
    script = script.sub(/^PROJECT_FILES=\(.*\)$/, "PROJECT_FILES=(#{project_files.map { |p| %('#{p}') }.join(' ')})") if project_files
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
