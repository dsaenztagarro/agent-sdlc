# frozen_string_literal: true

require "minitest/autorun"
require "fileutils"
require "json"
require "open3"
require "tmpdir"

# How bin/ds-status tells whether this project's copy of the shared design system is current.
#
# Claude Design writes a _ds_manifest.json into the shared system and into each project's _ds/
# copy of it. The copy is frozen when it is made, so a token or component that lands in the shared
# system reaches a project only when the project refreshes its copy; until then a stand-in it
# retires must stay. Each test runs the script against throwaway manifests.
class DsStatusTest < Minitest::Test
  SCRIPT = File.expand_path("../bin/ds-status", __dir__)

  def teardown
    FileUtils.rm_rf(@dir) if @dir
  end

  def test_a_copy_listing_everything_the_shared_system_lists_is_current
    manifests(copy: { tokens: { "--surface" => "#fff" }, components: ["Button"] },
              shared: { tokens: { "--surface" => "#fff" }, components: ["Button"] })

    out, status = run_script

    assert status.success?
    assert_match(/\Acurrent/, out)
  end

  def test_a_token_the_copy_lacks_makes_it_stale
    manifests(copy: { tokens: { "--surface" => "#fff" }, components: [] },
              shared: { tokens: { "--surface" => "#fff", "--surface-readonly" => "#FBFCFD" }, components: [] })

    out, status = run_script

    refute status.success?
    assert_match(/^  token +--surface-readonly$/, out)
  end

  def test_a_component_the_copy_lacks_makes_it_stale
    manifests(copy: { tokens: {}, components: ["Button"] },
              shared: { tokens: {}, components: ["Button", "AppShell"] })

    out, status = run_script

    refute status.success?
    assert_match(/^  component +AppShell$/, out)
  end

  def test_a_token_whose_value_moved_makes_it_stale
    manifests(copy: { tokens: { "--accent" => "#3B40CC" }, components: [] },
              shared: { tokens: { "--accent" => "#2F33A8" }, components: [] })

    out, status = run_script

    refute status.success?
    assert_match(/--accent  #3B40CC -> #2F33A8/, out)
  end

  private

  def manifests(copy:, shared:)
    @dir = Dir.mktmpdir("ds-status")
    write_manifest(File.join(@dir, "repo/pages/_ds/shared-1234/_ds_manifest.json"), **copy)
    write_manifest(File.join(@dir, "shared/system/_ds_manifest.json"), **shared)
    FileUtils.mkdir_p(File.join(@dir, "repo/bin"))
    FileUtils.cp(SCRIPT, File.join(@dir, "repo/bin/ds-status"))
  end

  def write_manifest(path, tokens:, components:)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.generate(
      "tokens" => tokens.map { |name, value| { "name" => name, "value" => value } },
      "components" => components.map { |name| { "name" => name } }
    ))
  end

  def run_script
    out, _err, status = Open3.capture3("ruby", File.join(@dir, "repo/bin/ds-status"), File.join(@dir, "shared"))
    [out, status]
  end
end
