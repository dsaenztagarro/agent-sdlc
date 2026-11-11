# frozen_string_literal: true

require_relative "test_helper"
require "fileutils"
require "net/http"
require "socket"
require "tmpdir"

# What bin/serve offers: every page in this repository, from a real origin.
#
# The index is walked on every request, never generated and committed, because a second list of
# what exists goes stale the first time a page is added. A page is served over http rather than
# opened from file://, whose null origin blocks a page that fetches anything. Each test runs a copy
# of the script in a throwaway checkout, on a free port.
class ServeTest < Minitest::Test
  SCRIPT = File.expand_path("../bin/serve", __dir__)

  def setup
    @root = Dir.mktmpdir("design-repo-serve")
    FileUtils.mkdir_p(File.join(@root, "bin"))
    FileUtils.cp(SCRIPT, File.join(@root, "bin/serve"))
    write("pages/list.html", "<main>the list</main>")
    write("pages/_ds/shared/button.card.html", "<main>a button</main>")
    @port = free_port
    @server = Process.spawn("ruby", File.join(@root, "bin/serve"), @port.to_s, out: File::NULL, err: File::NULL)
    wait_for_server
  end

  def teardown
    if @server
      Process.kill("TERM", @server)
      Process.wait(@server)
    end
    FileUtils.rm_rf(@root)
  end

  test "the index lists every page present when it is requested" do
    assert_includes get("/").body, %(href="/pages/list.html")

    write("pages/record.html", "<main>a record</main>")

    index = get("/").body
    assert_includes index, %(href="/pages/record.html")
    assert_includes index, %(href="/pages/_ds/shared/button.card.html")
  end

  test "a page is served from its path, with its media type" do
    response = get("/pages/list.html")

    assert_equal "200", response.code
    assert_equal "text/html; charset=utf-8", response["content-type"]
    assert_equal "<main>the list</main>", response.body
  end

  test "a page whose name holds a plus is served from the link the index gives it" do
    write("pages/a+b.html", "<main>a and b</main>")

    assert_includes get("/").body, %(href="/pages/a+b.html")
    assert_equal "<main>a and b</main>", get("/pages/a+b.html").body
  end

  test "a path outside the repository is never served" do
    assert_equal "404", get("/../../../../../../etc/hosts").code
    assert_equal "404", get("/%2e%2e/%2e%2e/%2e%2e/%2e%2e/%2e%2e/etc/hosts").code
    assert_equal "404", get("/pages/missing.html").code
  end

  private

  def write(path, body)
    full = File.join(@root, path)
    FileUtils.mkdir_p(File.dirname(full))
    File.write(full, body)
  end

  def free_port
    server = TCPServer.new("127.0.0.1", 0)
    server.addr[1]
  ensure
    server&.close
  end

  def wait_for_server
    50.times do
      TCPSocket.new("127.0.0.1", @port).close
      return
    rescue Errno::ECONNREFUSED
      sleep 0.1
    end
    flunk "bin/serve did not listen on #{@port}"
  end

  def get(path)
    Net::HTTP.start("127.0.0.1", @port) { |http| http.request(Net::HTTP::Get.new(path)) }
  end
end
