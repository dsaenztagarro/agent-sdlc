# The pull request title check.
#
# Contract: a pull request's title is a Conventional Commit header,
# `<type>(<scope>)!: <subject>`, and the check runs again whenever the title
# is edited. The repository squashes with the title as the commit subject, and
# the release is versioned from its type; a prose title leaves the next
# version uncomputable.
#
# Run: ruby test/pr_title_test.rb

require "minitest/autorun"
require "open3"
require "yaml"

class PrTitleTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  SCRIPT = File.join(ROOT, ".github/scripts/pr-title")
  WORKFLOW = File.join(ROOT, ".github/workflows/pr-title.yml")

  def check(title)
    Open3.capture3(SCRIPT, title)
  end

  def test_a_title_of_the_form_type_scope_bang_subject_passes_the_title_check
    ["feat: add a thing", "fix(sync): keep the pin", "docs!: drop the old route"].each do |title|
      _out, err, status = check(title)
      assert status.success?, "#{title.inspect} was refused: #{err}"
    end
  end

  def test_a_title_with_no_type_an_unknown_type_or_an_empty_subject_fails_the_title_check
    ["Ship a thing", "feature: x", "fix:", "fix: "].each do |title|
      _out, err, status = check(title)
      refute status.success?, "#{title.inspect} was accepted"
      assert_includes err, "Expected: <type>(<scope>)!: <subject>"
    end
  end

  def test_editing_a_pull_requests_title_re_runs_the_title_check
    workflow = YAML.safe_load_file(WORKFLOW)
    # Psych reads the bare key `on` as true.
    triggers = workflow.fetch("on") { workflow.fetch(true) }
    assert_includes triggers.dig("pull_request", "types"), "edited"
  end
end
