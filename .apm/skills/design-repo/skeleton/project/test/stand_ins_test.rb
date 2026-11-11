# frozen_string_literal: true

require_relative "test_helper"
require "fileutils"
require "json"
require "open3"
require "tmpdir"

# How bin/stand-ins tells where each STAND-IN in pages/ is on its way into the shared system.
#
# A stand-in is deleted only against a _ds/ copy that carries what it stands in for, and a copy
# carries it only once the project refreshes it. A component already listed does not mean the
# stand-in landed: one that extends it has landed only when its classes are defined. A request is
# open while an open brief in the shared system names the component. Each test builds a throwaway
# project, copy and shared system.
class StandInsTest < Minitest::Test
  SCRIPT = File.expand_path("../bin/stand-ins", __dir__)

  def teardown
    FileUtils.rm_rf(@dir) if @dir
  end

  test "a stand-in the copy carries has landed" do
    project(stand_in: callout, copy: callout_system, shared: callout_system)

    out, status = run_script

    refute status.success?
    assert_match(%r{^landed +Callout +pages/components\.css:1 }, out)
  end

  test "a stand-in only the shared system carries waits on a refresh" do
    project(stand_in: callout, copy: {}, shared: callout_system)

    assert_match(/^upstream +Callout /, run_script.first)
  end

  test "a stand-in with an open brief is requested and needs nothing" do
    project(stand_in: callout, copy: {}, shared: {}, briefs: { "feedback.brief.md" => "# Feedback\n\n## Callout\n" })

    out, status = run_script

    assert status.success?, out
    assert_match(/^requested +Callout /, out)
  end

  test "a brief that names a component only in passing does not request it" do
    project(stand_in: callout, copy: {}, shared: {}, briefs: { "density.brief.md" => "# Density\n\nThe Callout above keeps its own padding.\n" })

    out, status = run_script

    refute status.success?
    assert_match(/^unrequested\s+Callout/, out)
  end

  test "a selector list split across lines lands only when every class in it does" do
    stand_in = "/* STAND-IN — delete when the design system lands Callout */\n.callout,\n.callout-body { padding: 4px; }\n"
    copy = { components: ["Callout"], css: ".callout-body { padding: 4px; }" }
    project(stand_in: stand_in, copy: copy, shared: copy)

    out, status = run_script

    refute status.success?
    refute_match(/^landed/, out)
  end

  test "a stand-in with no brief is unrequested" do
    project(stand_in: callout, copy: {}, shared: {}, briefs: { "feedback.brief.md" => "# Feedback\n\n## Callouts row\n" })

    out, status = run_script

    refute status.success?
    assert_match(/^unrequested +Callout /, out)
  end

  test "a stand-in extending a listed component lands only when its classes do" do
    extension = "/* STAND-IN — delete when the design system lands Shell */\n.shell-aside{display:flex}\n"
    project(stand_in: extension,
            copy: { components: ["Shell"], css: ".shell{display:flex}" },
            shared: { components: ["Shell"], css: ".shell{display:flex}\n.shell-aside{display:flex}" })

    assert_match(/^upstream +Shell /, run_script.first)
  end

  test "an unnamed stand-in is judged by its classes" do
    unnamed = "/* STAND-IN — a disclosure */\n.shell-aside{display:flex}\n@media (max-width:899px){.shell .shell-aside{gap:0}}\n"
    project(stand_in: unnamed, copy: { css: ".shell{}\n.shell-aside{display:flex}" }, shared: {})

    assert_match(%r{^landed +\? +pages/components\.css:1  a disclosure$}, run_script.first)
  end

  test "a project with no stand-in needs nothing" do
    project(stand_in: ".button{}\n", copy: {}, shared: {})

    out, status = run_script

    assert status.success?
    assert_match(/\Anone/, out)
  end

  private

  def callout
    "/* STAND-IN — delete when the design system lands Callout */\n.callout{display:flex}\n.callout.is-open{color:red}\n"
  end

  def callout_system
    { components: ["Callout"], css: ".callout{display:flex}\n.callout.is-open{color:red}" }
  end

  def project(stand_in:, copy:, shared:, briefs: {})
    @dir = Dir.mktmpdir("stand-ins")
    write(File.join(@dir, "repo/pages/components.css"), stand_in)
    write_system(File.join(@dir, "repo/pages/_ds/shared-1234"), **copy)
    write_system(File.join(@dir, "shared/system"), **shared)
    briefs.each { |name, body| write(File.join(@dir, "shared/briefs/proposed", name), body) }
    FileUtils.mkdir_p(File.join(@dir, "repo/bin"))
    FileUtils.cp(SCRIPT, File.join(@dir, "repo/bin/stand-ins"))
  end

  def write_system(dir, components: [], css: "")
    write(File.join(dir, "_ds_manifest.json"), JSON.generate("components" => components.map { |name| { "name" => name } }))
    write(File.join(dir, "styles.css"), css)
  end

  def write(path, body)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, body)
  end

  def run_script
    out, _err, status = Open3.capture3("ruby", File.join(@dir, "repo/bin/stand-ins"), File.join(@dir, "shared"))
    [out, status]
  end
end
