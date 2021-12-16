# frozen_string_literal: true

module Maze
  module Checks
    # Assertion-backed data verification checks
    class AssertCheck
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

      def match(test, message = nil)
        assert_match(test, message)
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
        assert_kind_of(klass, object, message = nil)
      end
    end
  end
end
