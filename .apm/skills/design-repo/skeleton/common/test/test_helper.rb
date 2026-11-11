# frozen_string_literal: true

require "minitest/autorun"

module Minitest
  class Test
    # `test "a rule" do … end` names a test for the rule it holds, so the names read back as the
    # specification: `grep 'test "' test/*_test.rb`.
    def self.test(name, &block)
      method = "test_#{name.gsub(/\s+/, '_')}"
      raise ArgumentError, "two tests are named #{name.inspect}" if method_defined?(method)

      define_method(method, &block)
    end
  end
end
