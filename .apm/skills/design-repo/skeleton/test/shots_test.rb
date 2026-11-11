# frozen_string_literal: true

require_relative "test_helper"
require "fileutils"
require "open3"
require "tmpdir"
require "zlib"

# What bin/shots captures from a page, and which pages it refuses.
#
# A page is a snapshot of the application: one surface, every state reached from a state bar, and
# nothing that describes the application beside it. The shots are what a reader looks at, so they
# hold the surface alone — a paragraph drawn next to it, or the design chrome that switches states,
# never reaches one — and a page that does not keep the contract is named rather than shot. Each
# test runs the script over throwaway pages.
#
# A state is named "<Family> · <state>", or the bare family for its family's first, and its family
# is the name before the separator: the markup carries no other grouping. Each state is reached at
# its address, #state=<family>/<state>, and the State row must then name it. A family split apart, a
# bare family that is not its family's first state, or a state repeating its family is named, since
# the switcher steps through them in page order.
#
# It needs node and a browser, which a fresh clone and CI may not have; then it skips and says so.
class ShotsTest < Minitest::Test
  SCRIPT = File.expand_path("../bin/shots", __dir__)

  def setup
    @dir = Dir.mktmpdir("design-repo-shots")
    @pages = File.join(@dir, "pages")
    @out = File.join(@dir, "shots")
    FileUtils.mkdir_p(@pages)
  end

  def teardown
    FileUtils.rm_rf(@dir)
  end

  test "every state a page names is shot from its state bar and named for it" do
    page "surface.html", states: ["Empty", "Long data"]

    out, status = shots

    assert status.success?, out
    assert_equal %w[01-empty.png 02-long-data.png], Dir.children(File.join(@out, "surface")).sort
  end

  test "a shot holds the application surface alone, never the prose beside it" do
    page "surface.html", states: ["Empty"], prose: "<p style='height:400px'>The list empties when its last row goes.</p>"

    out, status = shots

    assert status.success?, out
    assert_equal [600, 400], png_size(File.join(@out, "surface/01-empty.png")), "the surface is 300x200 CSS pixels at 2x"
  end

  test "the design chrome is hidden in every shot" do
    File.write(File.join(@pages, "surface.html"), <<~HTML)
      <!doctype html><meta charset="utf-8"><body style="margin:0">
      <div data-design-chrome style="position:fixed;top:0;left:0;width:300px;height:200px;background:rgb(255,0,0)"></div>
      <main data-surface style="width:300px;background:rgb(255,255,255)">
        <section data-state="Empty" style="height:200px"></section>
      </main>
    HTML

    out, status = shots

    assert status.success?, out
    assert_equal [255, 255, 255], first_pixel(File.join(@out, "surface/01-empty.png")), "the chrome drawn over the surface"
  end

  test "a surface that scrolls inside the viewport is shot whole, not cut at the fold" do
    File.write(File.join(@pages, "surface.html"), <<~HTML)
      <!doctype html><meta charset="utf-8"><body style="margin:0">
      <main data-surface style="width:300px;height:100vh;overflow-y:auto">
        <section data-state="List" style="height:2000px">List</section>
      </main>
    HTML

    out, status = shots

    assert status.success?, out
    assert_equal [600, 4000], png_size(File.join(@out, "surface/01-list.png")), "the 2000px state at 2x"
  end

  test "a surface taller than one screenshot can hold is shot to that height, and the run finishes" do
    File.write(File.join(@pages, "surface.html"), <<~HTML)
      <!doctype html><meta charset="utf-8"><body style="margin:0">
      <main data-surface style="width:300px;height:100vh;overflow-y:auto">
        <section data-state="List" style="height:24000px">List</section>
      </main>
    HTML
    File.write(File.join(@pages, "later.html"), %(<!doctype html><main data-surface><section data-state="Empty">Empty</section></main>))

    out, status = shots

    assert status.success?, out
    assert_path_exists File.join(@out, "surface/01-list.png")
    assert_path_exists File.join(@out, "later/01-empty.png")
    assert_includes out, "surface.html: the List state is cut"
  end

  test "a page with several states and no state bar is refused and named" do
    page "surface.html", states: %w[Empty Error], bar: false

    out, status = shots

    assert_equal 1, status.exitstatus
    assert_match(/surface\.html: has 2 states and no state bar/, out)
  end

  test "a page with no surface is refused and named" do
    page "surface.html", states: ["Empty"], surface: false

    out, status = shots

    assert_equal 1, status.exitstatus
    assert_match(/surface\.html: has 0 \[data-surface\] elements/, out)
  end

  test "a state bar that does not name the state shown is refused" do
    page "surface.html", states: ["List", "List · Error"], tabs: %w[Default Failed]

    out, status = shots

    assert_equal 1, status.exitstatus
    assert_match(/surface\.html: at the "List · Error" state, its state bar reads "Failed"/, out)
  end

  test "a state its address does not show is refused" do
    page "surface.html", states: ["List", "List · Error"], addressable: false

    out, status = shots

    assert_equal 1, status.exitstatus
    assert_match(%r{surface\.html: its address #state=list/error does not show the "List · Error" state}, out)
  end

  test "a state named Family · state belongs to the family before the separator" do
    page "surface.html", states: ["List", "List · Filtered", "Record · Read", "Record · Edit"]

    out, status = shots

    assert status.success?, out
    assert_equal %w[01-list.png 02-list-filtered.png 03-record-read.png 04-record-edit.png],
                 Dir.children(File.join(@out, "surface")).sort
  end

  test "a family whose states do not sit together is refused" do
    page "surface.html", states: ["List", "Record · Read", "List · Filtered"]

    out, status = shots

    assert_equal 1, status.exitstatus
    assert_match(/surface\.html: its "List" family is split/, out)
  end

  test "a bare family that is not its family's first state is refused" do
    page "surface.html", states: ["List · Filtered", "List"]

    out, status = shots

    assert_equal 1, status.exitstatus
    assert_match(/surface\.html: its state "List" is the bare family but not the "List" family's first/, out)
  end

  test "a state repeating its family is refused" do
    page "surface.html", states: ["Record", "Record · Sparse record", "List"]

    out, status = shots

    assert_equal 1, status.exitstatus
    assert_match(/surface\.html: its state "Record · Sparse record" repeats its family/, out)
  end

  private

  # The bar behaves as a design system's state switcher does, in design chrome above the surface: the
  # address #state=family/state shows that state, and the State row holds the shown family's tabs, the
  # shown one selected. tabs: replaces the labels it draws; addressable: false ignores the address.
  def page(name, states:, bar: true, surface: true, tabs: nil, prose: "", addressable: true)
    labels = tabs || states.map { |s| s.include?(" · ") ? s.split(" · ", 2).last : "Default" }
    panels = states.each_with_index.map do |state, i|
      %(<section data-state="#{state}" data-slug="#{state_slug(state)}" data-fam="#{state.split(' · ').first}") +
        %( data-label="#{labels[i]}"#{' hidden' unless i.zero?} style="height:200px">#{state}</section>)
    end
    File.write(File.join(@pages, name), <<~HTML)
      <!doctype html><meta charset="utf-8"><body style="margin:0">
      #{%(<div data-design-chrome style="height:40px"><div role="tablist" aria-label="State"></div></div>) if bar}
      <main #{'data-surface' if surface} style="width:300px">#{panels.join}</main>
      #{prose}
      <script>
        const panels = [...document.querySelectorAll("[data-state]")];
        const row = document.querySelector('[role="tablist"]');
        const show = (p) => {
          panels.forEach((q) => (q.hidden = q !== p));
          if (row) row.innerHTML = panels.filter((q) => q.dataset.fam === p.dataset.fam).map((q) =>
            `<button role="tab" aria-label="${q.dataset.state}" aria-selected="${q === p}">${q.dataset.label}</button>`).join("");
        };
        const go = () => {
          const m = location.hash.match(/state=(.+)/);
          const p = m && panels.find((q) => q.dataset.slug === m[1]);
          if (p) show(p);
        };
        #{'addEventListener("hashchange", go);' if addressable}
        show(panels[0]);
      </script>
    HTML
  end

  def state_slug(state)
    state.split(" · ", 2).map { |part| part.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "") }.join("/")
  end

  def shots
    out, err, status = Open3.capture3(SCRIPT, @pages, @out)
    skip "bin/shots cannot run here — #{err.lines.first&.strip}" if status.exitstatus == 2
    [out + err, status]
  end

  def png_size(path)
    File.binread(path, 24, 16).unpack("NN")
  end

  # The RGB of the top-left pixel of an 8-bit, non-interlaced PNG. On the first row every filter
  # predicts from zero, so the first pixel is the filtered bytes as they are, plus nothing.
  def first_pixel(path)
    data = File.binread(path)
    idat = +""
    pos = 8
    while pos < data.bytesize
      length, type = data[pos, 8].unpack("Na4")
      idat << data[pos + 8, length] if type == "IDAT"
      pos += 12 + length
    end
    Zlib::Inflate.inflate(idat).bytes[1, 3]
  end
end
