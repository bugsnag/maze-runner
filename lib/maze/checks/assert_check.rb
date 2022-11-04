# frozen_string_literal: true
require 'test/unit'

module Maze
  module Checks
    # Assertion-backed data verification checks
    class AssertCheck
      include Test::Unit::Assertions

      def true(test, message = nil)
        assert_true(test, message)
      end

      def false(test, message = nil)
        assert_false(test, message)
      end

      def nil(test, message = nil)
        assert_nil(test, message)
      end

      def not_nil(test, message = nil)
        assert_not_nil(test, message)
      end

      def match(pattern, string, message = nil)
        regexp = if pattern.class == Regexp
                   pattern
                 else
                   Regexp.new(pattern)
                 end
        if message.nil?
          message = "<#{string}> was not matched by regex <#{pattern}>"
        end
        assert_match(regexp, string, message)
      end

      def equal(expected, act, message = nil)
        assert_equal(expected, act, message)
      end

      def not_equal(expected, act, message = nil)
        assert_not_equal(expected, act, message)
      end

      def operator(operand1, operator, operand2, message = nil)
        assert_operator(operand1, operator, operand2, message)
      end

      def kind_of(klass, object, message = nil)
        assert_kind_of(klass, object, message)
      end

      def block(message = 'block failed', &block)
        assert_block(message, &block)
      end

      def include(collection, object, message = nil)
        assert_include(collection, object, message)
      end
      alias includes include

      def not_include(collection, object, message = nil)
        assert_not_include(collection, object, message)
      end
      alias not_includes not_include
    end
  end
end
